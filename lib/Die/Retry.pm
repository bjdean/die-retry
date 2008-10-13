#!/usr/bin/env perl

use strict;
use warnings;

#
# Die::Retry
#
# Easy retry handler for exceptions
#
# Version: $Id$
#

######################################################################
# Module Declaration
#

package Die::Retry;
use base 'Exporter';

our $VERSION = '0.01';

our @EXPORT_OK = qw(retry);

######################################################################
# Modules
#

use Carp;

######################################################################
# Functions
#

sub retry {
  my ($code_sub, %config_override) = @_;

  # $code_sub must be CODE
  croak "First parameter must be a code ref" unless ( ref $code_sub eq 'CODE' );

  # Override defaults with %config
  # XXX Update the POD if the defaults are changed
  my %config = ( # How many times the eval is retried
                 "times" => 3,
                 # How long between retries (seconds)
                 "delay" => 1,
                 # Override the config with user options
                 %config_override );

  # Retry the code sub
  my $retries = 0;
  while ( $retries < $config{times} ) {
    my $return_value = eval { $code_sub->() };
    return $return_value unless $@;

    # Sleep if 
    select(undef, undef, undef, $config{delay})
      if $config{delay} != 0;
  }
  continue {
    $retries++;
  }

  # If we retried too many times, throw an exception
  croak "Too many retries (${retries}) - the last exception was: $@";
}

######################################################################
# Obligatory return value of 1
#
1;

######################################################################
# Documentation
#
__END__

=head1 NAME

Die::Retry - Easy retry handler for exceptions

=head1 SYNOPSIS

 # Call some_func_with_exceptions($param1, $param2), capturing
 # exceptions up to three times. 
 # There will be no delay between retries.

 use Die::Retry qw( retry );
 my $retval = retry( sub { some_func_with_exceptions($param1, $param2)
                   , times => 3
                   , delay => 0
                   );

=head1 DESCRIPTION

Easy retry handler for exceptions

=head1 FUNCTIONS

=over 8

=item B<retry( $code_ref, %config )>

This function provides and easy way to retry a call to a code ref while
catching exceptions multiple times.

No particular exception handling is possible so this function should not be
used if side-effects to exceptions need to be catered for.

The way the function operates is alterable by setting the C<%config> hash - the
configuration parameters available are:

=over 

=item B<times>

The number of times the code ref will be retried if exceptions are thrown.

The default is: 3

=item B<delay>

The delay between retries in seconds (sub second delays can be given).

The default is: 1.0s

=back

The function returns a scalar which is returned by the code ref. If the code
ref returns anything other than a scalar then the scalar context of that value
will be returned.

=back

=head1 DEPENDENCIES

The module is implemented using core libraries and has no other
module dependencies.

=head1 LIMITATIONS

Only scalars can be returned by the code block. This is not particularly
limiting given that an array ref or hash ref could be returned if an array
or hash was desired.

=head1 AUTHOR

Bradley Dean (perl@bjdean.id.au)

=head1 SPONSORED

Thanks where thanks are due - the original version of this library was paid for
by L<http://www.home.co.uk>.

=head1 COPYRIGHT

       Copyright (c) 2008, Bradley Dean. All Rights Reserved.
    This program is free software. It may be used, redistributed
        and/or modified under the same terms as Perl itself.

=cut
