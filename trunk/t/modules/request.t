use strict;
use Apache::test;

my $Is_dougm = (defined($ENV{USER}) && ($ENV{USER} eq "dougm"));

skip_test unless have_module "Apache::Request", '0.20';

require HTTP::Request::Common; 
require CGI;

$HTTP::Request::Common::VERSION ||= '1.00'; #-w 
unless ($CGI::VERSION >= 2.39 and  
	$HTTP::Request::Common::VERSION >= 1.08) {
    print "CGI.pm: $CGI::VERSION\n";
    print "HTTP::Request::Common: $HTTP::Request::Common::VERSION\n";
    skip_test;
} 

my $test_pods = $ENV{UPLOAD_PODS} || ($Is_dougm ? 20 : 3);
my $tests = 2;
$tests += ($test_pods * 2);

print "1..$tests\n";
my $i = 0;
my $ua = LWP::UserAgent->new;

use DirHandle ();

for my $cv (\&post_test, \&get_test) {
    $cv->();
}

if ($Is_dougm) {
    #try various sizes
    my $dir = "";
    for my $path (@INC) {
	last if -d ($dir = "$path/pod");
    }
    my $dh = DirHandle->new($dir) or die $!;
    my $num = $test_pods;
    for ($dh->read) {
	next unless /\.pod$/;
	last unless $num-- > 0;
	upload_test($_);
    }
}
else {
    for (qw(perlfunc.pod perlpod.pod perlxs.pod)) {
	upload_test($_);
    }
}

sub post_test {
    my $enc = 'application/x-www-form-urlencoded';
    param_test(sub {
	my($url, $data) = @_;
        HTTP::Request::Common::POST($url, 
				    Content_Type => $enc,
				    Content      => $data,
				    );
    });
}

sub get_test {
    my $enc = 'application/x-www-form-urlencoded';

    param_test(sub {
	my($url, $data) = @_;
        HTTP::Request::Common::GET("$url?$data");
    });
}

sub param_test {
    my $cv = shift;
    my $url = "http://$net::httpserver$net::perldir/request-param.pl";
    my $data = 
	"ONE=ONE_value&TWO=TWO_value&" .
	"THREE=M1&THREE=M2&THREE=M3";
		
    my $response = $ua->request($cv->($url, $data));

    my $page = $response->content;
    print $response->as_string unless $response->is_success;
    my $expect = <<EOF;
param ONE => ONE_value
param TWO => TWO_value
param THREE => M1,M2,M3
EOF
    my $ok = $page eq $expect;
    test ++$i, $ok;
    print $response->as_string unless $ok;
}

sub upload_test {
    my $podfile = shift || "func";
    my $url = "http://$net::httpserver$net::perldir/request-upload.pl";
    my $file = "";
    for my $path (@INC) {
	last if -e ($file = "$path/pod/$podfile");
    }

    $file = $0 unless -e $file;
    my $lines = 0;
    local *FH;
    open FH, $file or die "open $file $!";
    ++$lines while (<FH>);
    close FH;

    my $response = $ua->request(HTTP::Request::Common::POST($url,
		   Content_Type => 'multipart/form-data',
		   Content      => [count => 'count lines',
				    filename  => [$file],
				    ]));

    my $page = $response->content;
    print $response->as_string unless $response->is_success;
    test ++$i, ($page =~ m/Lines:\s+(\d+)/m);
    print "$file should have $lines lines (request-upload.pl says: $1)\n"
	unless $1 == $lines;
    test ++$i, $1 == $lines;
}
