package TestError::runtime;

use strict;
use warnings FATAL => 'all';

use Apache::RequestRec ();
use Apache::RequestIO ();
use Apache::Connection ();
use APR::Socket ();

use Apache::TestUtil;

use Apache::Const -compile => qw(OK);
use APR::Const    -compile => qw(TIMEUP);

use constant SIZE => 2048;

sub handler {
    my $r = shift;
    my $socket = $r->connection->client_socket;
    my $args = $r->args;

    $r->content_type('text/plain');

    # set timeout to 0 to make sure that any socket read call will
    # fail
    $socket->timeout_set(0);

    no strict 'refs';
    $args->($r, $socket);

    return Apache::OK;
}

sub plain_mp_error {
    my($r, $socket) = @_;
    t_server_log_error_is_expected();
    mp_error($socket);
}

sub plain_non_mp_error {
    my($r, $socket) = @_;
    t_server_log_error_is_expected();
    non_mp_error($socket);
}

sub die_hook_confess_mp_error {
    my($r, $socket) = @_;
    local $SIG{__DIE__} = \&APR::Error::confess;
    t_server_log_error_is_expected();
    mp_error($socket);
}

sub die_hook_confess_non_mp_error {
    my($r, $socket) = @_;
    local $SIG{__DIE__} = \&APR::Error::confess;
    t_server_log_error_is_expected();
    non_mp_error($socket);
}

sub die_hook_custom_mp_error {
    my($r, $socket) = @_;
    local $SIG{__DIE__} = sub { die "custom die hook: $_[0]" };
    t_server_log_error_is_expected();
    mp_error($socket);
}

sub die_hook_custom_non_mp_error {
    my($r, $socket) = @_;
    local $SIG{__DIE__} = sub { die "custom die hook: $_[0]" };
    t_server_log_error_is_expected();
    non_mp_error($socket);
}

sub eval_block_mp_error {
    my($r, $socket) = @_;
    eval { mp_error($socket) };
    if ($@ && ref($@) && $@ == APR::TIMEUP) {
        $r->print("ok eval_block_mp_error");
    }
    else {
        die "eval block has failed: $@";
    }
}

sub eval_string_mp_error {
    my($r, $socket) = @_;
    eval "\$socket->recv(SIZE)";
    if ($@ && ref($@) && $@ == APR::TIMEUP) {
        $r->print("ok eval_string_mp_error");
    }
    else {
        die "eval string has failed: $@";
    }
}

sub eval_block_non_mp_error {
    my($r, $socket) = @_;
    eval { non_mp_error($socket) };
    if ($@ && !ref($@)) {
        $r->print("ok eval_block_non_mp_error");
    }
    else {
        die "eval eval_non_mp_error has failed: $@";
    }
}

sub eval_block_non_error {
    my($r, $socket) = @_;
    eval { 1; };
    if ($@) {
        die "eval eval_block_non_mp_error has failed";
    }
    $r->print("ok eval_block_non_error");
}

sub non_mp_error {
    no_such_func();
}

# fails because of the timeout set earlier in the handler
sub mp_error {
    my $socket = shift;
    $socket->recv(SIZE);
}

1;
__END__

