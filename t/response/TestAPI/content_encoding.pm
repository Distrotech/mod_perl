package TestAPI::content_encoding;

# tests: $r->content_encoding("gzip");

use strict;
use warnings FATAL => 'all';

use Apache::RequestRec ();
use Apache::RequestUtil ();

use Apache::Const -compile => qw(OK DECLINED);

sub handler {
    my $r = shift;

    return Apache::DECLINED unless $r->method_number == Apache::M_POST;

    my $data = ModPerl::Test::read_post($r);

    require Compress::Zlib;

    $r->content_type("text/plain");
    $r->content_encoding("gzip");

    $r->print(Compress::Zlib::memGzip($data));

    Apache::OK;
}

1;
__END__