package TestApache::send_cgi_header;

use strict;
use warnings FATAL => 'all';

use Apache::Response ();

use Apache::Const -compile => qw(OK);

sub handler {
    my $r = shift;

    # at the same time test the \0 binary at the beginning of the data
    my $response = <<EOF;
Content-type: text/plain
X-Foo: X-Bar
Set-Cookie: Bad Programmer, No cookie!

\000\000This not the end of the world\000\000
EOF

    # bah, we can send the header and the response here
    # don't tell anybody
    $r->send_cgi_header($response);

    Apache::OK;
}

1;
__END__
# this should work regardless whether parse headers is on or off
PerlOptions -ParseHeaders
