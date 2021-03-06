use strict;
use warnings FATAL => 'all';

use Apache::TestRequest qw(GET_BODY_ASSERT);
use Apache::Test;
use Apache::TestUtil;

my $module = 'TestModperl::merge';
my $url    = Apache::TestRequest::module2url($module, {path => '/merge2/'});

# test server-to-container merging (with overrides) for:
#   PerlSetEnv
#   PerlPassEnv
#   PerlSetVar
#   PerlAddVar

t_debug("connecting to $url");
print GET_BODY_ASSERT $url;
