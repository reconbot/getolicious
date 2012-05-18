=pod

=head1 Getolicious

=head2 The Getolicious http request/response framework

=cut

package Getolicious;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use Getolicious::Request;
use Getolicious::Response;

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

=pod

=head1 GLOBALS

    @Getolicious::methods = qw(GET POST PUT DELETE); #supported methods for route dispatching could be anything if your frisky
    $Getolicious::postmax = 1024 * 4; # set on request object

=cut

our $AUTOLOAD;
our @methods = qw(GET POST PUT DELETE ANY);
our $postmax = 1024 * 4;

=pod

=item new Getolicious($opt)

$opt is a hashref with the following keys:
#   postmax       (optional) - sets postmax on the Request object defaults to $Getolicious::postmax;

=cut

sub new {
    my ($class, $opt) = @_;
    my $self = {
      'req' => new Getolicious::Request({
        'postmax' => exists $opt->{'postmax'} ? $opt->{'postmax'} : $postmax,
      }),
      'res' => new Getolicious::Response,
    };

    return bless $self, $class;
}

=pod

=head3 get() put() post() delete()
    
    $g->get qr/item/(\d)/, \%sub; 
    $g->get qr/item/(\d)/, $string;

=over

=item $resetCache if truthy clear the fields cache and hit the db for the latest fields

=item Returns a hashref of the latest field values from the netcool or historical db.

=back

=cut

sub AUTOLOAD{
  return if our $AUTOLOAD =~ /::DESTROY$/;
  my ($method, $self, @params) = ($AUTOLOAD, @_);
  $method =~ s/.*:://;
  $method = uc($method);
  if(grep {$_ eq $method} @methods ){
    return $self->dispatch($method, @params);
  }
  croak "Unknown method $method";
}


sub dispatch{
    my ($self, $method, $url, $action) = @_;

    if(!defined $action){
      ($self, $method, $action) = @_;
      $url = qw/.*/;
    }

    my $req = $self->{'req'};
    my $res = $self->{'res'};
    if($req->method ne $method && $method ne 'ANY'){ return $self;}


    my @match = $req->url =~ /$url/;
    if(@match){
      $req->{'urlparam'} = \@match;
      if(ref $action eq 'CODE'){
        $action->($req, $res);
      }elsif(ref $action && $action->can('dispatch')){
        $action->dispatch($req, $res);
      }elsif(!ref $action){
        $res->{'body'} .= $action;
      }
    }
    return $self;  
}

1;

