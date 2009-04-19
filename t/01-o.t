use Test::More 'no_plan';

package T1;
sub new{ return bless {}, 'T1' }
sub m1{ return 1 };

package main;

use Simo::Util qw( o );

my $o = o('T1');
is( $o->obj, 'T1' );
isa_ok( $o, 'Simo::Wrapper' );

