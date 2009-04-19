use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

sub x{ ac default => 1 }
sub y{ ac default => 2 }

package main;
use Simo::Util 'get_values';

{
    my $t = T1->new;
    
    my( $x, $y ) = get_values( $t, 'x', 'y' );
    is_deeply( [ $x, $y ], [ 1, 2 ], 'pass array, list context' );
}

{
    my $t = T1->new;
    my( $x, $y ) = get_values( $t, [ 'x', 'y' ] );
    is_deeply( [ $x, $y ], [ 1, 2 ], 'pass array ref, list context' );
}

{
    my $t = T1->new;
    
    my $x = get_values( $t, 'x' );
    is( $x, 1, 'pass array ref, scalar context' );
}

{
    my $t = T1->new;
    
    eval{ get_values( $t, 'z' ) };
    
    like( $@, qr/Invalid key 'z' is passed to get_values/, 'no exist key' );
}

{
    eval{ get_values( 'T1', ['x'] ) };
    
    like( $@, qr/'get_values' must be called from object/, 'not object' );
}


