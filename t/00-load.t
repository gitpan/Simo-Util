#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Simo::Util' );
	use_ok( 'Simo::Wrapper');
}

diag( "Testing Simo::Util $Simo::Util::VERSION, Perl $], $^X" );
