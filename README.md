Getolicious
===========

The not quite [Mojolicious::Lite](http://mojolicio.us/perldoc/Mojolicious/Lite) request response framework for older systems. If you can run Mojolicious you probably should. I couldn't so I made this. Getolicious provides a request and response objects and a middleware layer. Its inspired by but not nearly as nice as sinatra or connect. It's designed to be run via apache's mod-perl but any server capbale of running your script as a cgi should suffice.

Features
===========
  - URL routing
  - Middleware
  - Not much else

Dependencies
===========
Any old version of the following should suffice. The versions listed are the versions I've used.
  - CGI 3.15
  - HTML::Entities 1.35
  - File::stat
  - File::Spec 0.82
  - Carp 1.04
  - JSON 2.15
  - Data::Dumper

