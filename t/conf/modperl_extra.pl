use Socket (); #test DynaLoader vs. XSLoader workaround for 5.6.x
use IO::File ();

use Apache2 ();

use ModPerl::Util (); #for CORE::GLOBAL::exit

use Apache::RequestRec ();
use Apache::RequestIO ();
use Apache::RequestUtil ();

use Apache::Server ();
use Apache::ServerUtil ();
use Apache::Connection ();
use Apache::Log ();

use Apache::Const -compile => ':common';
use APR::Const -compile => ':common';

use APR::Table ();

unless ($ENV{MOD_PERL}) {
    die '$ENV{MOD_PERL} not set!';
}

#see t/modperl/methodobj
use TestModperl::methodobj ();
$TestModperl::MethodObj = TestModperl::methodobj->new;

#see t/response/TestModperl/env.pm
$ENV{MODPERL_EXTRA_PL} = __FILE__;

my $ap_mods = scalar grep { /^Apache/ } keys %INC;
my $apr_mods = scalar grep { /^APR/ } keys %INC;

Apache::Log->info("$ap_mods Apache:: modules loaded");
Apache::Server->log->info("$apr_mods APR:: modules loaded");

{
    my $server = Apache->server;
    my $vhosts = 0;
    for (my $s = $server->next; $s; $s = $s->next) {
        $vhosts++;
    }
    $server->log->info("base server + $vhosts vhosts ready to run tests");
}

# testing $s->add_config()
my $conf = <<'EOC';
# must use PerlModule here to check for segfaults
PerlModule Apache::TestHandler
<Location /apache/add_config>
  SetHandler perl-script
  PerlResponseHandler Apache::TestHandler::ok1
</Location>
EOC
Apache->server->add_config([split /\n/, $conf]);

# test a directive that triggers an early startup, so we get an
# attempt to use perl's mip  early
Apache->server->add_config(['<Perl >', '1;', '</Perl>']);

use constant IOBUFSIZE => 8192;

use Apache::Const -compile => qw(MODE_READBYTES);
use APR::Const    -compile => qw(SUCCESS BLOCK_READ);

sub ModPerl::Test::read_post {
    my $r = shift;
    my $debug = shift || 0;

    my @data = ();
    my $seen_eos = 0;
    my $filters = $r->input_filters();
    my $ba = $r->connection->bucket_alloc;
    my $bb = APR::Brigade->new($r->pool, $ba);

    do {
        my $rv = $filters->get_brigade($bb,
            Apache::MODE_READBYTES, APR::BLOCK_READ, IOBUFSIZE);
        if ($rv != APR::SUCCESS) {
            return $rv;
        }

        while (!$bb->empty) {
            my $buf;
            my $b = $bb->first;

            $b->remove;

            if ($b->is_eos) {
                warn "EOS bucket:\n" if $debug;
                $seen_eos++;
                last;
            }

            my $status = $b->read($buf);
            warn "DATA bucket: [$buf]\n" if $debug;
            if ($status != APR::SUCCESS) {
                return $status;
            }
            push @data, $buf;
        }

        $bb->destroy;

    } while (!$seen_eos);

    return join '', @data;
}

sub ModPerl::Test::add_config {
    my $r = shift;

    #test adding config at request time
    my $errmsg = $r->add_config(['require valid-user']);
    die $errmsg if $errmsg;

    Apache::OK;
}

sub ModPerl::Test::exit_handler {
    my($p, $s) = @_;

    $s->log->info("Child process pid=$$ is exiting");
}

END {
    warn "END in modperl_extra.pl, pid=$$\n";
}

1;
