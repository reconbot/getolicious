=pod

=head1 Getolicious::Hacks

=head2 The Getolicious http request/response framework

=cut

package Getolicious::Hacks;
use strict;
use warnings;
use File::stat;
use HTML::Entities;

BEGIN {
  # Specify exportable methods.
  use Exporter;
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

  $VERSION     = "0.1";
  @ISA         = qw(Exporter);
  @EXPORT      = qw();
  @EXPORT_OK   = qw(); 
  %EXPORT_TAGS = ();
}

sub iemode{
  my($req,$res) = @_;
  $res->{'headers'}->{'X-UA-Compatible'} = 'IE=edge,chrome=1';
}

1;
