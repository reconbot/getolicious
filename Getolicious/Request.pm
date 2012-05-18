=pod

=head1 Getolicious::Request

=head2 The Getolicious http request/response framework

=cut

package Getolicious::Request;

use strict;
use warnings;
use Data::Dumper;
use CGI::Cookie;
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
    'postmax' => $opt->{'postmax'}, 
  };
  return bless $self, $class;
}

sub method{
  if(exists $ENV{'X-HTTP-METHOD-OVERRIDE'}){
    return $ENV{'X-HTTP-METHOD-OVERRIDE'};
  }
  return undef unless exists $ENV{'REQUEST_METHOD'};
  return $ENV{'REQUEST_METHOD'};
}

sub contentType{
  if(exists $ENV{'CONTENT_TYPE'}){
    return $ENV{'CONTENT_TYPE'};
  }
  return undef;
}

sub url{
  if(exists $ENV{'PATH_INFO'}){
    return $ENV{'PATH_INFO'};
  }
  return undef;
}

sub ajax{
  return undef unless exists $ENV{'HTTP_X_REQUESTED_WITH'};
  return lc($ENV{'HTTP_X_REQUESTED_WITH'}) eq lc('XMLHttpRequest');
}

sub queryString{
  return $ENV{'QUERY_STRING'};
}

sub cookie{
  return { CGI::Cookie->fetch()};  
}

sub param{
  my ($self) = @_;

  if(exists $self->{'param'}){
    return $self->{'param'};
  }

  if($ENV{'REQUEST_METHOD'} eq 'GET'){
     $self->{'param'} = Getolicious::Util::fromQueryString($self->queryString);
     return $self->{'param'};
  }
  
  my $data;
  read(STDIN, $data, $self->{'postmax'});
  
  # detect if we're posting application/json
  if(lc($self->contentType) =~ /application\/json/){
    $self->{'param'} = Getolicious::Util::fromJson($data);
    return $self->{'param'};
  }

  if(lc($self->contentType) =~ /application\/x-www-form-urlencoded/){
    $self->{'param'} = Getolicious::Util::fromUrlEncoded($data);
    return $self->{'param'};
  }
  
  if(lc($self->contentType) =~ /multipart\/form-data/){
    $self->{'param'} = Getolicious::Util::fromMultiPart($data);
    return $self->{'param'};
  }

  $self->{'param'} = $data;
  return $self->{'param'};
}

sub urlParam{
  my ($self) = @_;
  return $self->{'urlparam'};
}

1;
