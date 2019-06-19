package Calendar::DatesRoles::DataUser::CalendarVar;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny;
use Role::Tiny::With;
no strict 'refs'; # Role::Tiny imports strict for us

with 'Calendar::DatesRoles::PublicInterface::Basic';
requires 'prepare_data';

sub _calc_min_max_year {
    my $mod = shift;

    return if defined ${"$mod\::_CD_DATAUSER_CALENDARVAR_CACHE_MIN_YEAR"};
    $mod->prepare_data;

    my $cal = ${"$mod\::CALENDAR"};
    my ($min, $max);
    for my $e (@{ $cal->{entries} }) {
        my $year;
        $e->{date} =~ /\A(\d{4})-(\d{2})-(\d{2})(?:T|\z)/a
            or die "BUG: $mod has an entry that doesn't have valid date: ".
            ($e->{date} // 'undef');
        $e->{year}  //= $1;
        $e->{month} //= $2 + 0;
        $e->{day}   //= $3 + 0;
        $min = $e->{year} if !defined($min) || $min > $e->{year};
        $max = $e->{year} if !defined($max) || $max < $e->{year};
    }
    ${"$mod\::_CD_DATAUSER_CALENDARVAR_CACHE_MIN_YEAR"} = $min;
    ${"$mod\::_CD_DATAUSER_CALENDARVAR_CACHE_MAX_YEAR"} = $max;
}

sub get_min_year {
    my $mod = shift;

    $mod->_calc_min_max_year();
    return ${"$mod\::_CD_DATAUSER_CALENDARVAR_CACHE_MIN_YEAR"};
}

sub get_max_year {
    my $mod = shift;

    $mod->_calc_min_max_year();
    return ${"$mod\::_CD_DATAUSER_CALENDARVAR_CACHE_MAX_YEAR"};
}

sub get_entries {
    my $mod = shift;
    my ($year, $month, $day) = @_;

    die "Please specify year" unless defined $year;
    my $min = $mod->get_min_year;
    die "Year is less than earliest supported year $min" if $year < $min;
    my $max = $mod->get_max_year;
    die "Year is greater than latest supported year $max" if $year > $max;

    my $cal = ${"$mod\::CALENDAR"};
    my @res;
    for my $e (@{ $cal->{entries} }) {
        next unless $e->{year} == $year;
        next if defined $month && $e->{month} != $month;
        next if defined $day   && $e->{day}   != $day;
        push @res, $e;
    }

    \@res;
}

1;
# ABSTRACT: Provide Calendar::Dates interface from consumer's $CALENDAR

=head1 DESCRIPTION

This role provides L<Calendar::Dates> interface to consumer that has
C<$CALENDAR> package variable. The variable should contain a L<DefHash>.
Relevant keys include: C<default_lang>, C<entries>.

C<entries> is an array of entries, where each entry is a DefHash. Required keys
include: C<date>. C<year>, C<month>, C<day> keys required by Calendar::Dates
will be taken from C<date> to let you be DRY.


=head1 METHODS

=head2 get_min_year

=head2 get_max_year

=head2 get_entries


=head1 SEE ALSO

L<Calendar::Dates>

L<Calendar::DatesRoles::DataProvider::CalendarVar::FromDATA::Simple>

L<Calendar::DatesRoles::DataProvider::CalendarVar::FromDATA::CSVJF>
