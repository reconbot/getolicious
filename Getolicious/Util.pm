=pod

=head1 Getolicious::Util

=head2 The Getolicious http request/response framework

=cut

package Getolicious::Util;

use strict;
use warnings;
use JSON -convert_blessed_universally;
use Data::Dumper;

BEGIN {
  # Specify exportable methods.
  use Exporter;
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

  $VERSION     = "0.1";
  @ISA         = qw(Exporter);
  @EXPORT      = qw();
  @EXPORT_OK   = qw(toJson fromJson fromQueryString fromUrlEncoded ); 
  %EXPORT_TAGS = ();
}



sub toJson{
    my $str = JSON->new->ascii(1)->pretty(0)->allow_nonref->allow_blessed(1)->convert_blessed(1)->escape_slash->encode(shift);
    $str =~ s/</\\u003c/g;
    $str =~ s/>/\\u003e/g;
    $str =~ s/&/\\u0026/g;
    $str =~ s/=/\\u003d/g;
    return $str;
}

sub fromJson{
    my $json = shift;
    my $obj;
    eval{
        $obj = JSON->new->utf8->allow_nonref->decode($json);
    };
    return $obj;
}

# with thanks to mojolisious
sub fromQueryString{
  my ($string) = @_;
  my $obj = {};
  for my $pair (split /[\&\;]+/, $string) {
    $pair =~ /^([^\=]*)(?:=(.*))?$/;
    my $name  = $1 || '';
    my $value = $2 || '';

    # Replace "+" with whitespace
    $name  =~ s/\+/\ /g;
    $value =~ s/\+/\ /g;

    # Unescape
    if (index($name, '%') >= 0) {
      $name = urlUnescape $name;
      $name =~ s/\[\]$//;
    }
    if (index($value, '%') >= 0) {
      $value = urlUnescape $value;
    }
    if(!exists $obj->{$name}){
      $obj->{$name} = $value;
    }elsif(ref $obj->{$name} ne 'ARRAY'){
      $obj->{$name} = [ $obj->{$name} , $value];
    }else{
      push @{$obj->{$name}}, $value;
    }
  }
  return $obj;
}

sub fromUrlEncoded{
  return fromQueryString(urlUnescape(shift));
}

sub fromMultiPart{
  return shift;
}

sub urlEscape {
  my ($string, $pattern) = @_;
  $pattern ||= 'A-Za-z0-9\-\.\_\~';
  return $string unless $string =~ /[^$pattern]/;
  $string =~ s/([^$pattern])/sprintf('%%%02X',ord($1))/ge;
  return $string;
}

sub urlUnescape {
  my $string = shift;
  return $string if index($string, '%') == -1;
  $string =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;
  return $string;
}

1;
