###
### Test Die::Retry
### $Id$
###

use strict;
use warnings;

use Test::More tests => 6;
#use Test::More qw{ no_plan };


### Use the module
BEGIN {
  use_ok( 'Die::Retry' );
}

### Test case functions

# This is a hack succeed-after-x-calls function - basically set the global
# variable to a count of failed returns before an success is returned
# (therefore only one set of use of this function is possible at a time)
my $succeed_after_count = 0;
sub succeed_after_x {
  if ( $succeed_after_count < 1 ) {
    return 'success';
  }
  else {
    $succeed_after_count--;
    die "succeed_after_x";
  }
}

# Make sure this works
my $retval;
$succeed_after_count = 1;
$retval = eval { succeed_after_x() };
like( $@
    , qr/^succeed_after_x /
    , 'succeed_after_x died when expected'
    );

$retval = eval { succeed_after_x() };
is( $retval
  , 'success'
  , 'succeed_after_x succeeded when expected'
  );

### Now we know the test function works, set up a test of retry

# This should retry twice and then succeed
$succeed_after_count = 2;
$retval = eval { Die::Retry::retry( sub { succeed_after_x() }
                                      , times => 3
                                      , delay => 0
                                      ) };
is( $retval
  , 'success'
  , 'retry retried until expected success'
  );

# This should retry three times then stop trying
$succeed_after_count = 4;
$retval = eval { Die::Retry::retry( sub { succeed_after_x() }
                                      , times => 3
                                      , delay => 0
                                      ) };
like( $@
    , qr/^Too many retries \(3\) - the last exception was: succeed_after_x /
    , 'retry failed after too many exceptions'
    );

# Make sure this can be called like a builtin
use Die::Retry qw( retry );
eval {
  retry { die } delay => 0, times => 42;
};
like( $@
    , qr/^Too many retries \(42\) - the last exception was: /
    , 'retry can be used like a builtin'
    );

