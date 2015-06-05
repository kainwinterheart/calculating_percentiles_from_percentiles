#!/usr/bin/perl -w

use strict;
use warnings;

my $diff_sum = 0;
my $diff_cnt = 0;
my $total_cnt = 0;

my $all_percs = undef;
my $percs_of_percs = undef;

my $first = 1;

while( defined( my $l = readline( STDIN ) ) ) {

    if( $first ) {

        $first = 0;

    } else {

        chomp( $l );

        if( $l =~ m/'all_percs'/ ) {

            ( $all_percs ) = ( $l =~ m/([0-9]+(?:\.[0-9]+)?)/ );
        
        } elsif( $l =~ m/'percs_of_percs'/ ) {

            ( $percs_of_percs ) = ( $l =~ m/([0-9]+(?:\.[0-9]+)?)/ );
        }

        if( defined $all_percs && defined $percs_of_percs ) {

            my $diff = abs( $all_percs - $percs_of_percs );

            if( $diff > 0 ) {

                $diff_sum += $diff;
                ++$diff_cnt;

                if( defined $ENV{ 'DIFFLIMIT' } && ( $diff > $ENV{ 'DIFFLIMIT' } ) ) {

                    print "diff: ${all_percs} - ${percs_of_percs} = ${diff}\n";
                }
            }

            ++$total_cnt;

            undef $all_percs;
            undef $percs_of_percs;
        }
    }
}

if( $diff_cnt > 0 ) {

    print 'Average difference is ', ( $diff_sum / $diff_cnt ), ', ', ( ( $diff_cnt * 100 ) / $total_cnt ), '% of records are not equal', "\n";

} elsif( $total_cnt > 0 ) {

    print "There are no different records\n";

} else {

    print "No data\n";
}

exit 0;

__END__
