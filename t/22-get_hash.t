use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

sub x{ ac default => 1 }
sub y{ ac default => 2 }

package main;
use Simo::Util 'get_hash';

{
    my $t = T1->new;
    
    my $point = get_hash( $t, 'x', 'y' );
    is_deeply( $point, { x => 1, y => 2 }, 'scalar context' );
}

{
    eval{ get_hash( 'T1', 'x' ) };
    
    like( $@, qr/'get_hash' must be called from object/, 'not object' );
}

