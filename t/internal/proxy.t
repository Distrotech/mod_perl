
use Apache::test;

skip_test unless 
    $net::callback_hooks{PERL_TRANS} and 
    $net::callback_hooks{PERL_STACKED_HANDLERS} and
    $net::callback_hooks{MMN} > 19980270;

my $url = "http://$net::httpserver/"."proxytest";
my $ua = LWP::UserAgent->new;
$ua->proxy([qw(http)], "http://$net::httpserver");

my $request = HTTP::Request->new('GET', $url);
my $response = $ua->request($request, undef, undef);
print $response->content;      
  
