#!perl -T

use Test::More 'no_plan';

package T1;
sub new{ return bless {}, 'T1' }
sub m1{ return 1 };

package main;

use Simo::Util qw( o );

my $ret = o('T1')->new->run_methods( 'm1' );
is( $ret, 1, 'success' );

