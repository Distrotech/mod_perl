package TestVhost::config;

# Test whether under threaded mpms (and not) a vhost with 'PerlOptions
# +Parent', can run <Perl> sections, which call into config again via
# add_config().

use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;

use Apache::RequestUtil ();
use APR::Table ();

use File::Spec::Functions qw(catdir);

use Apache::Const -compile => 'OK';

# using a different from 'handler' name on purpose, to make sure
# that the module is preloaded at the server startup
sub my_handler {
    my $r = shift;

    plan $r, tests => 1;

    {
        my $expected = $r->document_root;
        my $received = $r->dir_config->get('DocumentRootCheck');
        ok t_cmp($expected, $received, "DocumentRoot");
    }

    Apache::OK;
}

1;
__END__
<NoAutoConfig>
<VirtualHost TestVhost::config>
    DocumentRoot @documentroot@/vhost

    <IfDefine PERL_USEITHREADS>
        # a new interpreter pool
        PerlOptions +Parent
    </IfDefine>

    # use test system's @INC
    PerlSwitches -I@serverroot@

    # mp2 modules
    PerlRequire "@serverroot@/conf/modperl_inc.pl"

    # private to this vhost stuff
    PerlRequire "@documentroot@/vhost/startup.pl"

    # <Location /TestVhost__config> container is added via add_config
    # in t/htdocs/vhost/startup.pl
</VirtualHost>
</NoAutoConfig>
