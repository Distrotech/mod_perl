#include "mod_perl.h"

/*
 * modperl_bucket_sv code derived from mod_snake's ModSnakePyBucket
 * by Jon Travis
 */

typedef struct {
    apr_bucket_refcount refcount;
    SV *sv;
    PerlInterpreter *perl;
    apr_sms_t *sms;
} modperl_bucket_sv_t;

static apr_status_t
modperl_bucket_sv_read(apr_bucket *bucket, const char **str,
                       apr_size_t *len, apr_read_type_e block)
{
    modperl_bucket_sv_t *svbucket =
        (modperl_bucket_sv_t *)bucket->data;
    dTHXa(svbucket->perl);
    STRLEN n_a;
    char *pv = SvPV(svbucket->sv, n_a);

    *str = pv + bucket->start;
    *len = bucket->length;

    return APR_SUCCESS;
}

static void modperl_bucket_sv_destroy(void *data)
{
    modperl_bucket_sv_t *svbucket = 
        (modperl_bucket_sv_t *)data;
    dTHXa(svbucket->perl);

    if (!apr_bucket_shared_destroy(svbucket)) {
        MP_TRACE_f(MP_FUNC, "bucket refcnt=%d\n",
                   ((apr_bucket_refcount *)svbucket)->refcount);
        return;
    }

    MP_TRACE_f(MP_FUNC, "sv=0x%lx, refcnt=%d\n",
               (unsigned long)svbucket->sv, SvREFCNT(svbucket->sv));

    SvREFCNT_dec(svbucket->sv);

    apr_sms_free(svbucket->sms, svbucket);
}

static const apr_bucket_type_t modperl_bucket_sv_type = {
    "mod_perl SV bucket", 4,
    modperl_bucket_sv_destroy,
    modperl_bucket_sv_read,
    apr_bucket_setaside_notimpl,
    apr_bucket_shared_split,
    apr_bucket_shared_copy,
};

static apr_bucket *modperl_bucket_sv_make(pTHX_
                                          apr_bucket *bucket,
                                          SV *sv,
                                          int offset, int len)
{
    modperl_bucket_sv_t *svbucket; 

    svbucket = (modperl_bucket_sv_t *)apr_sms_malloc(bucket->sms,
                                                     sizeof(*svbucket));

    svbucket->sms = bucket->sms;

    bucket = apr_bucket_shared_make(bucket, svbucket, offset, offset+len);

    /* XXX: need to deal with PerlInterpScope */
#ifdef USE_ITHREADS
    svbucket->perl = aTHX;
#endif
    svbucket->sv = sv;

    if (!bucket) {
        apr_sms_free(svbucket->sms, svbucket);
        return NULL;
    }

    (void)SvREFCNT_inc(svbucket->sv);

    MP_TRACE_f(MP_FUNC, "sv=0x%lx, refcnt=%d\n",
               (unsigned long)sv, SvREFCNT(sv));

    bucket->type = &modperl_bucket_sv_type;

    return bucket;
}

apr_bucket *modperl_bucket_sv_create(pTHX_ SV *sv, int offset, int len)
{
    apr_sms_t *sms;
    apr_bucket *bucket;

    if (!apr_bucket_global_sms) {
        apr_sms_std_create(&apr_bucket_global_sms);
    }

    sms = apr_bucket_global_sms;
    bucket = (apr_bucket *)apr_sms_malloc(sms, sizeof(*bucket));
    APR_BUCKET_INIT(bucket);
    bucket->sms = sms;

    return modperl_bucket_sv_make(aTHX_ bucket, sv, offset, len);
}
