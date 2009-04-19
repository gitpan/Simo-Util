use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

sub m1{ ac default => 5 }
sub m2{ ac }

package main;
use Simo::Util 'new_and_validate';

{
    my $t1 = new_and_validate(
        'T1',
        m1 => 1, sub{ 1 },
        m2 => 2, sub{ 1 },
    );
    
    isa_ok( $t1, 'T1' );
    is_deeply( $t1, { m1 => 1, m2 => 2 }, 'get instant' );
}

{
    my $t1 = new_and_validate(
        T1->new,
        m1 => 1, sub{ 1 },
        m2 => 2, sub{ 1 },
    );
    
    isa_ok( $t1, 'T1' );
    is_deeply( $t1, { m1 => 1, m2 => 2 }, 'get instant( from object )' );
}
{
    eval{
        my $t1 = new_and_validate(
            'T1',
            1
        );
    };
    like( $@, qr/key-value-validator pairs must be passed to 'new_and_validate'./, 'args count is 1' );
}

{
    eval{
        my $t1 = new_and_validate(
            'T1',
            1, 2
        );
    };
    like( $@, qr/key-value-validator pairs must be passed to 'new_and_validate'./, 'args count is 2' );
}

{
    my $hash = { m1 => 1, m2 => 2 };
    my $validator = { m1 => sub{ 1 } };
    my $t1 = new_and_validate( 'T1', $hash, $validator );
    
    isa_ok( $t1, 'T1' );
    is_deeply( $t1, { m1 => 1, m2 => 2 }, 'hash and validator' );
}

{
    my $hash = { m1 => 1, m2 => 2 };
    my $validator = { m1 => sub{ 0 } };
    eval{ new_and_validate( 'T1', $hash, $validator ) };
    ok( $@, 'hash and validator invalid' );
}

