use Apache::TestRequest 'GET_BODY_ASSERT';

use Apache::Test;
use Apache::TestUtil;

use ModPerl::Const -compile => 'EXIT';

my $location = "/TestModperl__exit";

plan tests => 3;

{
    ok t_cmp('exited',
             GET_BODY_ASSERT("$location?noneval"),
             "exit in non eval context");

}
{
    my $exit_excpt = ModPerl::EXIT;
    my $body = GET_BODY_ASSERT("$location?eval");
    ok t_cmp(qr/^ModPerl::Util::exit: ($exit_excpt) exit was called/,
             $body,
             "exit in eval context");

    ok !t_cmp(qr/must not be reached/,
             $body,
             "exit in eval context");

}
