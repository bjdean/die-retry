#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Die::Retry' );
}

diag( "Testing Die::Retry $Die::Retry::VERSION, Perl $], $^X" );
