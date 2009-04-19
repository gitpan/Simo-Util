use strict;
use warnings;
use Test::More 'no_plan';

package T1;
use Simo;

sub x{ ac }
sub y{ ac }

package main;
use Simo::Util 'set_values';

{
    my $t = T1->new;
    my $ret = set_values( $t, x => 1, y => 2 );
    
    is_deeply( $t, { x => 1, y => 2 }, 'pass hash' );
    
    set_values( $t, { x => 3, y => 4 } );
    is_deeply( $t, { x => 3, y => 4 }, 'pass hash ref' );
    
    eval{ set_values( $t, 1 ) };
    like( $@, qr/key-value pairs must be passed to 'set_values'/, 'no key value pairs' );
    
    eval{ set_values( $t, z => 1 ) };
    like( $@, qr/Invalid key 'z' is passed to 'set_values'/, 'invalid key' );
    
    is( set_values( $t ), 1, 'retrun value is 1' );
}

{
    eval{ set_values( 'T1', x => 1 ) };
    
    like( $@, qr/'set_values' must be called from object/, 'not object' );
}

