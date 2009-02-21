#!perl -T

use Test::More tests => 3;

BEGIN {
	use_ok( 'Simo::Util' );
	use_ok( 'Simo::Wrapper');
	use_ok( 'Simo::Error' );
}

diag( "Testing Simo::Util $Simo::Util::VERSION, Perl $], $^X" );
