use Test::More 'no_plan';
use strict;
use warnings;

package T1;
use Simo;

sub a1{ ac }

sub m1{
    my ( $self, @args ) = @_;
    $self->a1( \@args );
}

sub m2{
    my $self = shift;
    wantarray ? @{ $self->a1 } : $self->a1;
}

package main;
use Simo::Util 'run_methods';

{
    my $ret = run_methods(
        T1->new,
        m1 => [ 1, 2 ],
        'm2'
    );
    is_deeply( $ret, [ 1, 2 ], 'scalar context' );
}

{
    my @rets = run_methods(
        T1->new,
        m1 => [ 1, 2 ],
        'm2'
    );
    is_deeply( [ @rets ], [ 1, 2 ], 'list context' );
}

{
    eval{ run_methods( T1->new, {} ) };
    like( $@, qr/is bad\. Method name must be string and args must be array ref/, 'bad method name' );
    
    eval{ run_methods( T1->new, '1' ) };
    like( $@, qr/1 is not exist/, 'method not exist' );
}

{
    eval{ run_methods( '###', m1 => [ 1, 2 ] ) };
    
    like( $@, qr/'run_methods' must be called from object/, 'not object' );
}
