#!/usr/bin/perl -w

use strict;
use warnings;

use Data::Dumper 'Dumper';
use List::Util 'sum';

use constant {

    MAX_VAL => 1000,
};

my ( $num ) = @ARGV;

chomp( $num //= '' );

my %h = (

    a => ( ( ( $num % 3 ) == 0 )
        ? { data => [ map( { int( rand( MAX_VAL ) ) } 1 .. 500000 ), map( { int( rand( MAX_VAL ) ) + 500000 } 1 .. 500000 ) ], sum => 0, cnt => 0 }
        : { data => [ map( { int( rand( MAX_VAL ) ) } 1 .. 1000000 ) ], sum => 0, cnt => 0 } ),
    b => ( ( ( $num % 7 ) == 0 )
        ? { data => [ map( { int( rand( MAX_VAL ) ) + 500000 } 1 .. 10 ), map( { int( rand( MAX_VAL ) ) } 1 .. 700000 ), map( { int( rand( MAX_VAL ) ) + 250000 } 1 .. 10 ) ], sum => 0, cnt => 0 }
        : { data => [ map( { int( rand( MAX_VAL ) ) } 1 .. 10 ) ], sum => 0, cnt => 0 } ),
    c => ( ( ( $num % 4 ) == 0 )
        ? { data => [ map( { int( rand( MAX_VAL ) ) } 1 .. 3333 ), map( { int( rand( MAX_VAL ) ) + 6000 } 1 .. 3333 ), map( { int( rand( MAX_VAL ) ) + ( ( int( rand( 2 ) ) == 1 ) ? 500000 : 12000 ) } 1 .. 3333 ) ], sum => 0, cnt => 0 }
        : { data => [ map( { int( rand( MAX_VAL ) ) } 1 .. 10000 ) ], sum => 0, cnt => 0 } ),
);

my @all = ();
my $all_cnt = 0;
my $all_sum = 0;
my %some_lists = ();
my %means_of_percs = ();

while( my ( undef, $data ) = each( %h ) ) {

    @{ $data -> { 'data' } } = sort( { $a <=> $b } @{ $data -> { 'data' } } );

    foreach my $node ( @{ $data -> { 'data' } } ) {

        ++$data -> { 'cnt' };
        $data -> { 'sum' } += $node;

        push( @all, $node );

        ++$all_cnt;
        $all_sum += $node;
    }

    if( $data -> { 'cnt' } > 0 ) {

        $data -> { 'avg' } = ( $data -> { 'sum' } / $data -> { 'cnt' } );
        my $sum1 = 0;
        my $sum2 = 0;

        foreach my $node ( @{ $data -> { 'data' } } ) {

            $sum1 += ( ( $node - $data -> { 'avg' } ) ** 2 );
            $sum2 += ( ( $node - $data -> { 'avg' } ) ** 3 );
        }

        $data -> { 'stddev' } = sqrt( $sum1 / $data -> { 'cnt' } );
        $data -> { 'skew' } = ( ( $sum2 / $data -> { 'cnt' } ) / ( $data -> { 'stddev' } ** 3 ) );

        $data -> { 'kind' } = ( ( abs( $data -> { 'skew' } ) > 1 ) ? 'asymmetric' : 'symmetric' );

        my @percentiles = ();

        foreach my $percentile ( 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100 ) {

            my $rank = ( ( $percentile / 100 ) * $data -> { 'cnt' } );
            my $k = int( $rank );
            my @values = ();

            if( $k == 0 ) {

                push( @values, $data -> { 'data' } -> [ 0 ] );

            } elsif( $k == $data -> { 'cnt' } ) {

                push( @values, $data -> { 'data' } -> [ $data -> { 'cnt' } - 1 ] );

            } elsif( ( $rank - $k ) == 0 ) {

                push( @values, $data -> { 'data' } -> [ $k - 1 ] );

            } else {

                push( @values, map( { $data -> { 'data' } -> [ $_ ] } ( ( $k - 1 ), $k ) ) );
            }

            my $val = $data -> { 'perc' } -> { $percentile } = ( sum( @values ) / scalar( @values ) );
            my $dest = $means_of_percs{ $percentile } //= { sum => 0, cnt => 0 };

            ++$dest -> { 'cnt' };
            $dest -> { 'sum' } += $val;

            push( @{ $some_lists{ $percentile } -> { 'data' } }, ( $val ) x $data -> { 'cnt' } );
        }
    }

    delete( $data -> { 'data' } );
}

while( my ( undef, $data ) = each( %means_of_percs ) ) {

    $data -> { 'avg' } = ( $data -> { 'sum' } / $data -> { 'cnt' } );
}

@all = sort( { $a <=> $b } @all );
my %all_perc = ();

foreach my $percentile ( 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100 ) {

    my $rank = ( ( $percentile / 100 ) * $all_cnt );
    my $k = int( $rank );
    my @values = ();

    if( $k == 0 ) {

        push( @values, $all[ 0 ] );

    } elsif( $k == $all_cnt ) {

        push( @values, $all[ $all_cnt - 1 ] );

    } elsif( ( $rank - $k ) == 0 ) {

        push( @values, $all[ $k - 1 ] );

    } else {

        push( @values, map( { $all[ $_ ] } ( ( $k - 1 ), $k ) ) );
    }

    $all_perc{ $percentile } = ( sum( @values ) / scalar( @values ) );
}

while( my ( $percentile, $data ) = each( %some_lists ) ) {

    @{ $data -> { 'data' } } = sort( { $a <=> $b } @{ $data -> { 'data' } } );

    foreach my $node ( @{ $data -> { 'data' } } ) {

        ++$data -> { 'cnt' };
        $data -> { 'sum' } += $node;
    }

    if( $data -> { 'cnt' } > 0 ) {

        $data -> { 'avg' } = ( $data -> { 'sum' } / $data -> { 'cnt' } );

        my $rank = ( ( $percentile / 100 ) * $data -> { 'cnt' } );
        my $k = int( $rank );
        my @values = ();

        if( $k == 0 ) {

            push( @values, $data -> { 'data' } -> [ 0 ] );

        } elsif( $k == $data -> { 'cnt' } ) {

            push( @values, $data -> { 'data' } -> [ $data -> { 'cnt' } - 1 ] );

        } elsif( ( $rank - $k ) == 0 ) {

            push( @values, $data -> { 'data' } -> [ $k - 1 ] );

        } else {

            push( @values, map( { $data -> { 'data' } -> [ $_ ] } ( ( $k - 1 ), $k ) ) );
        }

        $data -> { 'value' } = ( sum( @values ) / scalar( @values ) );
    }

    delete( $data -> { 'data' } );
}

0 && print Dumper( {

    slices => \%h,
    all_percs => \%all_perc,
    means_of_percs => \%means_of_percs,
    percs_of_percs => \%some_lists,
} );

my %table = ();

while( my ( $percentile, $value ) = each( %all_perc ) ) {

    $table{ $percentile } -> { 'all_percs' } = $value;
}

while( my ( $percentile, $data ) = each( %means_of_percs ) ) {

    $table{ $percentile } -> { 'means_of_percs' } = $data -> { 'avg' };
}

while( my ( $percentile, $data ) = each( %some_lists ) ) {

    $table{ $percentile } -> { 'percs_of_percs' } = $data -> { 'value' };
}

while( my ( $percentile, $data ) = each( %table ) ) {

    if( $data -> { 'all_percs' } != $data -> { 'percs_of_percs' } ) {

        die( 'all_percs is not equal to percs_of_percs for percentile ' . $percentile . ': ' . Dumper( [
        
            data => $data,
            table => \%table,
            slices => \%h,

        ] ) );
    }
}

print Dumper( [

    table => \%table,
    slices => \%h,
] );

exit 0;

__END__
