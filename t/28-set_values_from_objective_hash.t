use strict;
use warnings;
use Test::More 'no_plan';

package T1;
use Simo;

sub x{ ac }
sub y{ ac }
sub m1{ ac }
sub m2{ ac }
sub m3{ ac }
sub m4{ ac }
sub m5{ ac }

package T2;
use Simo;

sub create{
    return shift->SUPER::new( @_ );
}

sub m1{ ac }
sub m2{ ac }

package main;
use Simo::Util 'set_values_from_objective_hash';

{
    my $t = T1->new;
    my $ret = set_values_from_objective_hash( $t, x => 1, y => 2 );
    
    is_deeply( $t, { x => 1, y => 2 }, 'pass hash' );
    
    set_values_from_objective_hash( $t, { x => 3, y => 4 } );
    is_deeply( $t, { x => 3, y => 4 }, 'pass hash ref' );
    
    eval{ set_values_from_objective_hash( $t, 1 ) };
    like( $@, qr/key-value pairs must be passed to 'set_values_from_objective_hash'/, 'no key value pairs' );
    
    eval{ set_values_from_objective_hash( $t, z => 1 ) };
    like( $@, qr/Invalid key 'z' is passed to 'set_values_from_objective_hash'/, 'invalid key' );
    
    is( set_values_from_objective_hash( $t ), 1, 'retrun value is 1' );
}

{
    eval{ set_values_from_objective_hash( 'T1', x => 1 ) };
    
    like( $@, qr/'set_values_from_objective_hash' must be called from object/, 'not object' );
}

{
    my $hash = {
        __CLASS => 'Dummy',
        __CLASS_CONSTRUCTOR => 'Dummy',
        m1 => 1,
        m2 => { a => 2, b => 3 },
        m3 => 4,
        m4 => { __CLASS => 'T2', __CLASS_CONSTRUCTOR => 'create',  m1 => 1, m2 => 2 },
        m5 => 5
    };
    
    my $t1 = T1->new;
    set_values_from_objective_hash( $t1, $hash );
    
    is_deeply( $t1, { m1 => 1, m2 => { a => 2, b => 3 }, m3 => 4, m4 => { m1 => 1, m2 => 2 }, m5 => 5 }, 'internal data' );
    isa_ok( $t1, 'T1' );
    isa_ok( $t1->m4, 'T2' );
    
}

