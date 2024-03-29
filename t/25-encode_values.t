use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

use utf8;
sub a1{ ac default => 'あ' }
sub a2{ ac default =>  [ 'あ', 'い' ] }
sub a3{ ac default => { a => 'あ', b => 'い' } }
sub a4{ ac default => qr// }
sub a5{ ac default => [ [] ] }
sub a6{ ac default => { a => {} }, }
no utf8;

package main;
use Simo::Util 'encode_values';

{
    my $t = T1->new;
    encode_values( $t, 'utf8', 'a1' );
    is( $t->a1, 'あ', 'string encode' );
}

{
    my $t = T1->new;
    encode_values( $t, 'utf8', 'a2' );
    is_deeply( $t->a2, [ 'あ', 'い' ], 'array string encode' );
}

{
    my $t = T1->new;
    encode_values( $t, 'utf8', 'a3' );
    is_deeply( $t->a3, { a => 'あ', b => 'い' }, 'hash string encode' );
}

{
    my $t = T1->new;
    encode_values( $t, 'utf8', qw( a1 a2 a3 ) );
    is( $t->a1, 'あ', 'mutil attrs encode 1' );
    is_deeply( $t->a2, [ 'あ', 'い' ], 'mutil attrs encode 2' );
    is_deeply( $t->a3, { a => 'あ', b => 'い' }, 'mutil attrs encode 3' );
}

{
    my $t = T1->new;
    eval{ encode_values( 'T1', 'utf8', 'a1' ) };
    like( $@, qr/'encode_values' must be called from object/, 'called from not object' );
}

{
    my $t = T1->new;
    eval{ encode_values( $t, 'utf8', 'noexist' ) };
    like( $@, qr/'noexist' is not exist./, 'called from not object' );
}

{
    my $t = T1->new;
    my $warn;
    local $SIG{__WARN__} = sub{
        $warn = shift;
    };
    
    encode_values( $t, 'utf8', 'a4' );
    like( $warn, qr/\$self->{ 'a4' } must be string or array ref or hash ref\. Encode is not done/, 'not string' );
}

{
    my $t = T1->new;
    my $warn;
    local $SIG{__WARN__} = sub{
        $warn = shift;
    };
    
    encode_values( $t, 'utf8', 'a5' );
    like( $warn, qr/\$self->{ 'a5' }\[ 0 \] must be string\. Encode is not done/, 'not string' );
}

{
    my $t = T1->new;
    my $warn;
    local $SIG{__WARN__} = sub{
        $warn = shift;
    };
    
    encode_values( $t, 'utf8', 'a6' );
    like( $warn, qr/\$self->{ 'a6' }{ 'a' } must be string\. Encode is not done/, 'not string' );
}

__END__

