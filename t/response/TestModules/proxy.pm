package TestModules::proxy;

use strict;
use warnings FATAL => 'all';

use Apache::Test;

use Apache::Server ();
use Apache::RequestRec ();
use Apache::RequestIO ();

my $uri_real = "/TestModules__proxy_real";

use Apache::Const -compile => qw(DECLINED OK);

sub proxy {
    my $r = shift;

    return Apache::DECLINED if $r->proxyreq;
    return Apache::DECLINED unless $r->uri eq '/TestModules__proxy';

    my $s = $r->server;
    my $real_url = sprintf "http://%s:%d%s",
        $s->server_hostname, $s->port, $uri_real;

    $r->proxyreq(1);
    $r->uri($real_url);
    $r->filename("proxy:$real_url");
    $r->handler('proxy-server');

    return Apache::OK;
}

sub response {
    my $r = shift;

    $r->content_type('text/plain');
    $r->print("ok");

    return Apache::OK;
}

1;
__END__
<NoAutoConfig>
    <IfModule mod_proxy.c>
        <Proxy http://@servername@:@port@/*>
            # 2.0
            <IfModule mod_access.c>
                Order Deny,Allow
                Deny from all
                Allow from @servername@
            </IfModule>
            # 2.1
            <IfModule mod_authz_host.c>
                Order Deny,Allow
                Deny from all
                Allow from @servername@
            </IfModule>
        </Proxy>

        PerlModule TestModules::proxy
        PerlTransHandler TestModules::proxy::proxy
        <Location /TestModules__proxy_real>
            SetHandler modperl
            PerlResponseHandler TestModules::proxy::response
        </Location>
    </IfModule>
</NoAutoConfig>

