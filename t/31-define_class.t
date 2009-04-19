use strict;
use warnings;

use Test::More 'no_plan';

use Simo::Util 'define_class';

{
    define_class( 'T1', 'm1', 'm2' );
    
    my $t1 = T1->new( m1 => 1, m2 => 2 );
    is_deeply( $t1, { m1 => 1, m2 => 2 }, 'define ok' );
    isa_ok( $t1, 'T1' );
}

{
    eval{ define_class( '&' ) };
    like( $@, qr/'define_class' must be called from class name/, 'not class name' );
}

{
    eval{ define_class( 'T2', '3' ) };
    like( $@, qr/accessor must be method name/, 'not method name' );
}

