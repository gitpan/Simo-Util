use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

sub a1{ ac default => '1' }
sub a2{ ac default =>  [ '1', '2' ] }
sub a3{ ac default => { a => '1', b => '2' } }

package main;
use Simo::Util 'filter_values';

my $info_list = [];
sub f1{
    my ( $val, $info )  = @_;
    push @{ $info_list }, $info;
    return $val * 2;
}

{
    my $t = T1->new;
    $info_list = [];
    
    filter_values( $t, \&f1, 'a1' );
    is( $t->a1, 2, 'string filter' );
    is_deeply( $info_list, [ { type => 'SCALAR', attr => 'a1', self => $t } ], 'string filter info' );
}

{
    my $t = T1->new;
    $info_list = [];
    
    filter_values( $t, \&f1, 'a2' );
    is_deeply( $t->a2, [ 2, 4 ], 'array string filter' );
    is_deeply( 
        $info_list, 
        [ { type => 'ARRAY', attr => 'a2', index => 0, self => $t },
          { type => 'ARRAY', attr => 'a2', index => 1, self => $t } ],
        'array string filter info' 
    );
}

{
    my $t = T1->new;
    $info_list = [];

    filter_values( $t, \&f1, 'a3' );
    is_deeply( $t->a3, { a => 2, b => 4 }, 'hash string filter' );
    
    $info_list = [ sort { $a->{ key } cmp $b->{ key } } @{ $info_list } ];
    is_deeply( 
        $info_list, 
        [ { type => 'HASH', attr => 'a3', key => 'a', self => $t },
          { type => 'HASH', attr => 'a3', key => 'b', self => $t } ],
        'hash string filter info' 
    );
}

{
    my $t = T1->new;
    filter_values( $t, \&f1, qw( a1 a2 a3 ) );
    is( $t->a1, 2, 'mutil attrs filter 1' );
    is_deeply( $t->a2, [ 2, 4 ], 'mutil attrs filter 2' );
    is_deeply( $t->a3, { a => 2, b => 4 }, 'mutil attrs filter 3' );
}

{
    eval{ filter_values( 'Book', \&f1, 'a1' ) };
    like( $@, qr/'filter_values' must be called from object/, 'called from not object' );
}

{
    my $t = T1->new;
    eval{ filter_values( $t, {}, 'a1' ) };
    like( $@, qr/First argument must be code reference/, 'not pass code ref' );
}

{
    my $t = T1->new;
    eval{ filter_values( $t, \&f1, 'noexist' ) };
    like( $@, qr/'noexist' is not exist./, 'called from not object' );
}

__END__

