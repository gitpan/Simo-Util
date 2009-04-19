use strict;
use warnings;
use Storable;

use Test::More 'no_plan';

package T1;
use Simo;

sub a1{ ac default => 1 }
sub a2{ ac default => 2 }



package main;
use Simo::Util 'freeze';

{
    my $obj = T1->new;
    $obj->a1; # a1 is initialize;
    
    my $freezed = freeze( $obj );
    my $freezed_exp = Storable::freeze( $obj );
    
    is( $freezed, $freezed_exp, 'freezed data is same' );
}

{
    eval{ freeze( 'T1' ) };
    like( $@, qr/'freeze' must be called from object/, 'must be callsed from object' );
}

__END__

