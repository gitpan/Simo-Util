use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

sub m1{ ac default => 5 }
sub m2{ ac }

package main;
use Simo::Util 'validate';

{
    my $t =T1->new;
    
    $@ = undef;
    my $ret = validate( $t, m1 => sub{ 1 }, m2 => sub{ 1 } );
    ok( !$@, 'value is valid' );
    is( $ret, 1, 'return 1' );
}

{
    my $t =T1->new;
    
    eval{ validate( $t, m1 => sub{ $_[1]->{a} = 1; $_[1]->{b} = $_[0]; return 0 } ) };
    isa_ok( $@, 'Simo::Error' );
    is_deeply( [ $@->type, $@->msg, $@->pkg, $@->attr, $@->val, $@->info->{ a }, $@->info->{ b } ],
               [ 'value_invalid', 'T1::m1 must be valid value', 'T1', 'm1', 5, 1, 5 ],
               'valdate' );
} 

{
    eval{ validate( 'T1' ) };
    like( $@, qr/Cannot call 'validate' from class/, 'called from pkg' );
}

{
    my $t =T1->new;
    eval{ validate( $t, 'm1' ) };
    like( $@, qr/key-value pairs must be passed to 'validate'/, 'called from pkg' );
}

{
    my $t =T1->new;
    eval{ validate( $t, noexist => sub{} ) };
    like( $@, qr/Attr 'noexist' is not exist/, 'called from pkg' );
}

{
    my $t =T1->new;
    eval{ validate( $t, m1 => [] ) };
    like( $@, qr/Value must be code reference/, 'called from pkg' );
}


