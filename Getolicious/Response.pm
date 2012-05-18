=pod

=head1 Getolicious::Response

=head2 The Getolicious http request/response framework

=cut

package Getolicious::Response;

use strict;
use warnings;
use Data::Dumper;
use Getolicious::Util;

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

sub new{
  my ($class, $opt) = @_;
  my $self = {
    'data' => {},
    'sent_headers' => 0,
    'headers' => {
      'Status' => '200',
      'Content-Type' => 'text/html',
    },
    'body' => '',
  };
  return bless $self, $class;
}

sub DESTROY{
  my ($self) = @_;
  $self->sendBody;
}

sub status{
  my ($self, $status) = @_;
  if($status){
    $self->{'headers'}->{'Status'} = $status;
  }
  return $self->{'headers'}->{'Status'};
}

sub headers{
  my ($self, $headers) = @_;
  if($headers && ref $headers eq 'HASH'){
    for(keys %$headers){
      $self->{'headers'}->{$_} = $headers->{$_};
    }
  }
  return $self->{'headers'};
}

sub sendHeaders{
  my ($self, $headers) = @_;
  return undef if $self->{'sent_headers'};
  $headers = $self->headers($headers);

  # Crazy defaults!
  if(!exists $headers->{'Content-Type'}){
    print "Content-Type: text/plain\n";
  }

  # not required behavior but it's kind to put these first
  for (qw(Status Content-Type)){
    if(exists $headers->{$_}){
      print "$_: " . $headers->{$_} . "\n";
      delete $headers->{$_};
    }
  }

  for(keys %$headers){
    print "$_: " . $headers->{$_} . "\n";
  }
  print "\n";

  $self->{'sent_headers'} = 1;
  return 1;
}

sub sendBody{
  my ($self, $body) = @_;
  return undef if $self->{'sent_body'};
  $self->sendHeaders;
  print ($body || $self->{'body'});
  $self->{'sent_body'} = 1;
  return 1;
}

sub sendRedirect{
    my ($self, $redirect) = @_;
    
    if(!$redirect =~ /(https?)\:\/\//){
        $redirect = "http://" . $ENV{'SERVER_NAME'} ."/" . $redirect;
    }
    
    return $self->sendHeaders({
      'Status' => '302 FOUND',
      'Location' => $redirect,
    });
}

sub sendJson{
    my ($self, $data) = @_;
    $self->sendHeaders({'Content-Type' => 'application/json'});
    return $self->sendBody(Getolicious::Util::toJson($data));
}

sub sendDumper{
  my$self = shift;
  $self->{'headers'}->{'Content-Type'} = 'text/plain';
  return $self->sendBody(scalar Dumper(@_));
}

1;

