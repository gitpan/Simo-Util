use strict;
use warnings;
use Storable;

use Test::More 'no_plan';

package T1;
use Simo;

sub a1{ ac default => 1 }
sub a2{ ac default => 2 }



package main;
use Simo::Util qw( clone );

{
    my $obj = T1->new;
    $obj->a1; # a1 is initialize;

    my $copy = clone( $obj );
    my $copy_exp = Storable::dclone( $obj );
    
    is_deeply( $copy, $copy_exp, 'object data is same' );
    is( ref $copy, 'T1', 'blessed class' );
}

{
    eval{ clone( 'T1' ) };
    like( $@, qr/'clone' must be called from object/, 'must be callsed from object' );
}

__END__

