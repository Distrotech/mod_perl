# Copyright 2003-2004 The Apache Software Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package ModPerl::BuildMM;

use strict;
use warnings;

use ExtUtils::MakeMaker ();
use Cwd ();
use File::Spec::Functions qw(catdir catfile splitdir);
use File::Basename;
use File::Find;

use Apache::Build ();
use ModPerl::MM;

our %PM; #add files to installation

# MM methods that this package overrides
no strict 'refs';
my $stash = \%{__PACKAGE__ . '::MY::'};
my @methods = grep *{$stash->{$_}}{CODE}, keys %$stash;
ModPerl::MM::override_eu_mm_mv_all_methods(@methods);
use strict 'refs';

my $apache_test_dir = catdir Cwd::getcwd(), "Apache-Test", "lib";

#to override MakeMaker MOD_INSTALL macro
sub mod_install {
    q{$(PERL) -I$(INST_LIB) -I$(PERL_LIB) \\}."\n" .
    qq{-I$apache_test_dir -MModPerl::BuildMM \\}."\n" .
    q{-e "ModPerl::MM::install({@ARGV},'$(VERBINST)',0,'$(UNINST)');"}."\n";
}

sub build_config {
    my $key = shift;
    my $build = Apache::Build->build_config;
    return $build unless $key;
    $build->{$key};
}

#the parent WriteMakefile moves MY:: methods into a different class
#so alias them each time WriteMakefile is called in a subdir

sub my_import {
    no strict 'refs';
    my $stash = \%{__PACKAGE__ . '::MY::'};
    for my $sym (keys %$stash) {
        next unless *{$stash->{$sym}}{CODE};
        my $name = "MY::$sym";
        undef &$name if defined &$name;
        *$name = *{$stash->{$sym}}{CODE};
    }
}

sub WriteMakefile {
    my %args = @_;

    my $build = build_config();
    ModPerl::MM::my_import(__PACKAGE__);

    my $inc = $build->inc;
    if (my $glue_inc = $build->{MP_XS_GLUE_DIR}) {
        for (split /\s+/, $glue_inc) {
            $inc .= " -I$_";
        }
    }

    my $libs;
    my @libs = ();
    if (Apache::Build::BUILD_APREXT) {
        # in order to decouple APR/APR::* from mod_perl.so,
        # link these modules against the static MP_APR_LIB lib,
        # rather than the mod_perl lib (which would demand mod_perl.so
        # be available). For other modules, use mod_perl.lib as
        # usual. This is done for APR in xs/APR/APR/Makefile.PL.
        my $name = $args{NAME};
        if ($name =~ /^APR::\w+$/) {
            @libs = ($build->apache_libs, $build->mp_apr_lib);
        }
        else {
            @libs = ($build->apache_libs, $build->modperl_libs);
        }
    }
    else {
        @libs = ($build->apache_libs, $build->modperl_libs);
    }
    $libs = join ' ', @libs;

    my $ccflags = $build->perl_ccopts . $build->ap_ccopts;

    my @opts = (
        INC       => $inc,
        CCFLAGS   => $ccflags,
        OPTIMIZE  => $build->perl_config('optimize'),
        LDDLFLAGS => $build->perl_config('lddlflags'),
        LIBS      => $libs,
        dynamic_lib => { OTHERLDFLAGS => $build->otherldflags },
    );

    my @typemaps;
    my $pwd = Cwd::fastcwd();
    for ('xs', $pwd, "$pwd/..") {
        my $typemap = $build->file_path("$_/typemap");
        if (-e $typemap) {
            push @typemaps, $typemap;
        }
    }
    push @opts, TYPEMAPS => \@typemaps if @typemaps;

    my $clean_files = (exists $args{clean} && exists $args{clean}{FILES}) ?
        $args{clean}{FILES} : '';
    $clean_files .= " glue_pods"; # cleanup the dependency target
    $args{clean}{FILES} = $clean_files;

    ExtUtils::MakeMaker::WriteMakefile(@opts, %args);
}

my %always_dynamic = map { $_, 1 }
  qw(ModPerl::Const Apache::Const APR::Const APR APR::PerlIO);

sub ModPerl::BuildMM::MY::constants {
    my $self = shift;
    my $build = build_config();

    #install everything relative to the Apache2/ subdir
    if ($build->{MP_INST_APACHE2}) {
        $self->{INST_ARCHLIB} = catdir $self->{INST_ARCHLIB}, 'Apache2';
        $self->{INST_LIB} = catdir $self->{INST_LIB}, 'Apache2';
    }

    #"discover" xs modules.  since there is no list hardwired
    #any module can be unpacked in the mod_perl-2.xx directory
    #and built static

    #this stunt also make it possible to leave .xs files where
    #they are, unlike 1.xx where *.xs live in src/modules/perl
    #and are copied to subdir/ if DYNAMIC=1

    if ($build->{MP_STATIC_EXTS}) {
        #skip .xs -> .so if we are linking static
        my $name = $self->{NAME};
        unless ($always_dynamic{$name}) {
            if (my($xs) = keys %{ $self->{XS} }) {
                $self->{HAS_LINK_CODE} = 0;
                print "$name will be linked static\n";
                #propagate static xs module to src/modules/perl/Makefile
                $build->{XS}->{$name} =
                  join '/', Cwd::fastcwd(), $xs;
                $build->save;
            }
        }
    }

    $self->MM::constants;
}

sub ModPerl::BuildMM::MY::top_targets {
    my $self = shift;
    my $string = $self->MM::top_targets;

    return $string;
}

sub ModPerl::BuildMM::MY::postamble {
    my $self = shift;

    my $doc_root = catdir Cwd::getcwd(), "docs", "api";

    my @targets = ();

    # reasons for glueing pods to the respective .pm files:
    # - manpages will get installed over the mp1 manpages and vice
    #   versa. glueing pods avoids creation of manpages, but may be we
    #   could just tell make to skip manpages creation?
    # if pods are installed directly they need to be also redirected,
    # some into Apache2/ others (e.g. Apache2) not

    # add the code to glue the existing pods to the .pm files in blib.
    # create a dependency on pm_to_blib subdirs linkext targets to
    # allow 'make -j'
    my @target = ('glue_pods: pm_to_blib subdirs linkext');

    if (-d $doc_root) {
        my $build = build_config();

        # those living in modperl-2.0/lib are already nicely mapped
        my %pms = %{ $self->{PM} };

        my $cwd = Cwd::getcwd();
        my $blib_dir = catdir qw(blib lib);
        $blib_dir = catdir $blib_dir, "Apache2"
            if $build->{MP_INST_APACHE2};

        # those autogenerated under WrapXS/
        # those living under xs/
        # those living under ModPerl-Registry/lib/
        my @src = ('WrapXS', 'xs', catdir(qw(ModPerl-Registry lib)));

        for my $base (@src) {
            chdir $base;
            my @files = ();
            find({ no_chdir => 1,
                   wanted => sub { push @files, $_ if /.pm$/ },
                 }, ".");
            chdir $cwd;

            for (@files) {
                my $pm = catfile $base, $_;
                my $blib;
                if ($base =~ /^(xs|WrapXS)/) {
                    my @segm = splitdir $_;
                    splice @segm, -2, 1; # xs/APR/Const/Const.pm
                    splice @segm, -2, 1 if /APR.pm/; # odd case
                    $blib = catfile $blib_dir, @segm;
                }
                else {
                    $blib = catfile $blib_dir, $_;
                }
                $pms{$pm} = $blib;
            }
        }

        while (my($pm, $blib) = each %pms) {
            my @segm = splitdir $blib;
            for my $i (1..2) {
                # try APR.pm and APR/Bucket.pm
                my $pod = catdir(@segm[-$i .. -1]);
                $pod =~ s/\.pm/\.pod/;
                my $podpath = catfile $doc_root, $pod;
                next unless -r $podpath;

                push @target, 
                    '$(FULLPERL) -I$(INST_LIB) ' .
                    "-I$apache_test_dir -MModPerl::BuildMM " .
                    "-e ModPerl::BuildMM::glue_pod $pm $podpath $blib";
            }
        }

        push @target, $self->{NOECHO} . '$(TOUCH) $@';
    }
    else {
        # we don't have the docs sub-cvs repository extracted, skip
        # the docs gluing
        push @target, $self->{NOECHO} . '$(NOOP)';
    }
    push @targets, join "\n\t", @target;

#    # next target: cleanup the dependency file
#    @target = ('glue_pods_clean:');
#    push @target, '$(RM_F) glue_pods';
#    push @targets, join "\n\t", @target;

    return join "\n\n", @targets, '';
}

sub glue_pod {

    die "expecting 3 arguments: pm, pod, dst" unless @ARGV == 3;
    my($pm, $pod, $dst) = @ARGV;

    # it's possible that the .pm file is not existing
    # (e.g. ThreadMutex.pm is not created on unless
    # $apr_config->{HAS_THREADS})
    return unless -e $pm && -e $dst;

    # have we already glued the doc?
    exit 0 unless -s $pm == -s $dst;

    # ExtUtils::Install::pm_to_blib removes the 'w' perms, so we can't
    # just append the doc there
    my $orig_mode = (stat $dst)[2];
    my $rw_mode   = 0666;

    chmod $rw_mode, $dst      or die "Can't chmod $rw_mode $dst: $!";
    open my $pod_fh, "<$pod"  or die "Can't open $pod: $!";
    open my $dst_fh, ">>$dst" or die "Can't open $dst: $!";
    print $dst_fh "\n"; # must add one line separation
    print $dst_fh (<$pod_fh>);
    close $pod_fh;
    close $dst_fh;
    # restore the perms
    chmod $orig_mode, $dst    or die "Can't chmod $orig_mode $dst: $!";
}

sub ModPerl::BuildMM::MY::post_initialize {
    my $self = shift;
    my $build = build_config();
    my $pm = $self->{PM};

    while (my($k, $v) = each %PM) {
        if (-e $k) {
            $pm->{$k} = $v;
        }
    }

    # prefix typemap with Apache/ so when installed in the
    # perl-lib-tree it won't be picked by non-mod_perl modules
    if (exists $pm->{'lib/typemap'} ) {
        $pm->{'lib/typemap'} = '$(INST_ARCHLIB)/auto/Apache/typemap';
    }

    #not everything in MakeMaker uses INST_LIB
    #so we have do fixup a few PMs to make sure *everything*
    #gets installed into Apache2/
    if ($build->{MP_INST_APACHE2}) {
        while (my($k, $v) = each %$pm) {
            #up one from the Apache2/ subdir
            #so it can be found for 'use Apache2 ()'
            next if $v =~ /Apache2\.pm$/;

            # another module generated by A-T that needs to go to the
            # normal @INC
            next if $v =~ /TestConfigData\.pm$/;

            #move everything else to the Apache2/ subdir
            #unless already specified with \$(INST_LIB)
            #or already in Apache2/
            unless ($v =~ /Apache2/) {
                $v =~ s{ (blib[/\\:]lib) }{ catdir $1, 'Apache2'}xe;
            }

            $pm->{$k} = $v;
        }
    }

    '';
}

sub ModPerl::BuildMM::MY::libscan {
    my($self, $path) = @_;

    my $apr_config = build_config()->get_apr_config();

    if ($path =~ m/(Thread|Global)Mutex/) {
        return unless $apr_config->{HAS_THREADS};
    }

    return '' if $path =~ m/\.(pl|cvsignore)$/;
    return '' if (basename dirname $path) eq 'CVS';
    return '' if $path =~ m/~$/;

    $path;
}

1;
