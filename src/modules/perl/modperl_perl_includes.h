#ifndef MODPERL_PERL_INCLUDES_H
#define MODPERL_PERL_INCLUDES_H

/* header files for Perl */

#ifndef PERL_NO_GET_CONTEXT
#   define PERL_NO_GET_CONTEXT
#endif

#define PERLIO_NOT_STDIO 0

/*
 * sizeof(struct PerlInterpreter) changes #ifdef USE_LARGE_FILES
 * apache-2.0 cannot be compiled with lfs because of sendfile.h
 * the PERL_CORE optimization is a no-no in this case
 */
#if defined(USE_ITHREADS) && !defined(USE_LARGE_FILES)
#   define PERL_CORE
#endif

#ifdef MP_SOURCE_SCAN
/* XXX: C::Scan does not properly remove __attribute__ within
 * function prototypes; so we just rip them all out via cpp
 */
#   undef __attribute__
#   define __attribute__(arg)

#   ifdef MP_SOURCE_SCAN_NEED_ITHREADS
/* just need to have pTHX_ defined for proper prototypes */
#      define USE_ITHREADS
#   endif
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef PERL_CORE
#   ifndef croak
#      define croak Perl_croak_nocontext
#   endif
#endif

/* avoiding namespace collisions */

/* from XSUB.h */
/* mod_perl.c calls exit() in a few places */
#undef exit
/* modperl_tipool.c references abort() */
#undef abort
/* these three clash with apr bucket structure member names */
#undef link
#undef read
#undef free
/* modperl_perl.c */
#undef getpid

#ifdef list
#   undef list
#endif

/* avoiding -Wall warning */

#undef dNOOP
#define dNOOP extern int __attribute__ ((unused)) Perl___notused

#ifndef G_METHOD
#   define G_METHOD 64
#endif

#ifndef PERL_MAGIC_tied
#   define PERL_MAGIC_tied 'P'
#endif

#endif /* MODPERL_PERL_INCLUDES_H */
