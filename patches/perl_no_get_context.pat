for interpreter pool support, apply the patch below and configure Perl
5.6.0 like so:
./Configure -des -Dusethreads -Accflags=-DPERL_NO_GET_CONTEXT

Date: Fri, 14 Apr 2000 16:23:51 -0700 (PDT)
From: Doug MacEachern <dougm@covalent.net>
To: Gurusamy Sarathy <gsar@ActiveState.com>
Cc: perl5-porters@perl.org
Subject: Re: -Dusethread woes 
In-Reply-To: <200004142247.PAA04706@maul.ActiveState.com>
Message-ID: <Pine.LNX.4.10.10004141610140.368-100000@mojo.covalent.net>

wow, that was fast, thanks!!
i also had to define PERL_NO_GET_CONTEXT when building libperl.a for this
to work.  which in turn required the patch below.  my test program works
again, yay!!  and, so does mod_perl-2.0-dev's PerlInterpreter pool, that
maps a perl_clone()'d interpreter to an Apache-2.0 thread,
concurrently calling back into each in the same process, wheeeeeeeeeee!

--- ext/DB_File/version.c~      Sun Jan 23 05:15:45 2000
+++ ext/DB_File/version.c       Fri Apr 14 16:08:53 2000
@@ -28,6 +28,7 @@
 void
 __getBerkeleyDBInfo()
 {
+    dTHX;
     SV * version_sv = perl_get_sv("DB_File::db_version", GV_ADD|GV_ADDMULTI) ;
     SV * ver_sv = perl_get_sv("DB_File::db_ver", GV_ADD|GV_ADDMULTI) ;
     SV * compat_sv = perl_get_sv("DB_File::db_185_compat", GV_ADD|GV_ADDMULTI) ;
