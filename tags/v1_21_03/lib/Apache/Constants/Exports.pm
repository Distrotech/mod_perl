package Apache::Constants::Exports;

use strict;

my(@common)     = qw(OK DECLINED DONE NOT_FOUND FORBIDDEN
		     AUTH_REQUIRED SERVER_ERROR);
my(@methods)    = qw(M_CONNECT M_DELETE M_GET M_INVALID M_OPTIONS
		     M_POST M_PUT M_TRACE 
		     M_PATCH M_PROPFIND M_PROPPATCH M_MKCOL M_COPY 
		     M_MOVE M_LOCK M_UNLOCK METHODS);
my(@options)    = qw(OPT_NONE OPT_INDEXES OPT_INCLUDES 
		     OPT_SYM_LINKS OPT_EXECCGI OPT_UNSET OPT_INCNOEXEC
		     OPT_SYM_OWNER OPT_MULTI OPT_ALL);
my(@server)     = qw(MODULE_MAGIC_NUMBER
		     SERVER_VERSION SERVER_BUILT);
my(@response)   = qw(DOCUMENT_FOLLOWS MOVED REDIRECT
		     USE_LOCAL_COPY
		     BAD_REQUEST
		     BAD_GATEWAY 
		     RESPONSE_CODES
		     NOT_IMPLEMENTED
		     NOT_AUTHORITATIVE
		     CONTINUE);
my(@satisfy)    = qw(SATISFY_ALL SATISFY_ANY SATISFY_NOSPEC);
my(@remotehost) = qw(REMOTE_HOST REMOTE_NAME
		     REMOTE_NOLOOKUP REMOTE_DOUBLE_REV);
my(@http)       = qw(HTTP_OK
		     HTTP_MOVED_TEMPORARILY
		     HTTP_MOVED_PERMANENTLY
		     HTTP_METHOD_NOT_ALLOWED 
		     HTTP_NOT_MODIFIED
		     HTTP_UNAUTHORIZED
		     HTTP_FORBIDDEN
		     HTTP_NOT_FOUND
		     HTTP_BAD_REQUEST
		     HTTP_INTERNAL_SERVER_ERROR
		     HTTP_NOT_ACCEPTABLE 
		     HTTP_NO_CONTENT
		     HTTP_PRECONDITION_FAILED
		     HTTP_SERVICE_UNAVAILABLE
		     HTTP_VARIANT_ALSO_VARIES);
my(@config)     = qw(DECLINE_CMD);
my(@types)      = qw(DIR_MAGIC_TYPE);
my(@override)    = qw(
		      OR_NONE
		      OR_LIMIT
		      OR_OPTIONS
		      OR_FILEINFO
		      OR_AUTHCFG
		      OR_INDEXES
		      OR_UNSET
		      OR_ALL
		      ACCESS_CONF
		      RSRC_CONF);
my(@args_how)    = qw(
		      RAW_ARGS
		      TAKE1
		      TAKE2
		      ITERATE
		      ITERATE2
		      FLAG
		      NO_ARGS
		      TAKE12
		      TAKE3
		      TAKE23
		      TAKE123);

my $rc = [@common, @response];

%Apache::Constants::EXPORT_TAGS = (
    common     => \@common,
    config     => \@config,
    response   => $rc,
    http       => \@http,
    options    => \@options,
    methods    => \@methods,
    remotehost => \@remotehost,
    satisfy    => \@satisfy,
    server     => \@server,				   
    types      => \@types, 
    args_how   => \@args_how,
    override   => \@override,
    #depreciated
    response_codes => $rc,
);

@Apache::Constants::EXPORT_OK = (
    @response,
    @http,
    @options,
    @methods,
    @remotehost,
    @satisfy,
    @server,
    @config,
    @types,
    @args_how,
    @override,
); 
   
*Apache::Constants::EXPORT = \@common;

sub gen_ctags {
    my @tags = ();
    my $pack = __PACKAGE__;
    print <<EOF;
/*
 * Generated by $pack\::gen_ctags, do not edit!!!
 */
EOF

    while(my($k,$v) = each %Apache::Constants::EXPORT_TAGS) {
	push @tags, $k;
	print "static char *ETAG_", $k, "[] = { \n",
	(map { qq(   "$_",\n) } @$v),
	"   NULL,\n};\n";
    }
    
    my %case_tags = ();
    for my $tag (@tags) {
	my $key = substr($tag, 0, 1);
	push @{ $case_tags{$key} }, $tag;
    }

    print "static char **export_tags(char *tag) {\n";
    print "   switch (*tag) {\n";
    for my $k (sort keys %case_tags) {
	my $v = $case_tags{$k};
	print "\tcase '$k':\n";
	for my $tag (@$v) {
	    print qq|\tif(strEQ("$tag", tag))\n\t   return ETAG_$tag;\n|;
	}
    }
    print qq|\tdefault:\n\tcroak("unknown tag `%s'", tag);\n|;
    print "   }\n}\n";
}

1;
__END__
