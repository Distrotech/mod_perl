#include "mod_perl.h"

#define EnvMgObj SvMAGIC((SV*)GvHV(PL_envgv))->mg_ptr

static MP_INLINE
void modperl_env_hv_store(pTHX_ HV *hv, apr_table_entry_t *elt)
{
    I32 klen = strlen(elt->key);
    SV **svp = hv_fetch(hv, elt->key, klen, FALSE);

    if (svp) {
        sv_setpv(*svp, elt->val);
    }
    else {
        SV *sv = newSVpv(elt->val, 0);
        hv_store(hv, elt->key, klen, sv, FALSE);
        svp = &sv;
    }

    SvTAINTED_on(*svp);
}

typedef struct {
    const char *key;
    I32 klen;
    const char *val;
    I32 vlen;
    U32 hash;
} modperl_env_ent_t;

#define MP_ENV_ENT(k,v) \
{ k, sizeof(k)-1, v, sizeof(v)-1, 0 }

static const modperl_env_ent_t modperl_env_const_vars[] = {
    MP_ENV_ENT("GATEWAY_INTERFACE", "CGI-Perl/1.1"),
    { NULL }
};

void modperl_env_request_populate(pTHX_ request_rec *r)
{
    HV *hv = GvHV(PL_envgv);
    int i;
    U32 mg_flags;
    apr_array_header_t *array = apr_table_elts(r->subprocess_env);
    apr_table_entry_t *elts = (apr_table_entry_t *)array->elts;

    ap_add_common_vars(r);
    ap_add_cgi_vars(r);

    modperl_env_untie(mg_flags);

    for (i = 0; i < array->nelts; i++) {
	if (!elts[i].key || !elts[i].val) {
            continue;
        }
        modperl_env_hv_store(aTHX_ hv, &elts[i]);
    }    

    for (i = 0; modperl_env_const_vars[i].key; i++) {
        const modperl_env_ent_t *ent = &modperl_env_const_vars[i];

        hv_store(hv, ent->key, ent->klen,
                 newSVpvn(ent->val, ent->vlen), ent->hash);
    }
                 
    modperl_env_tie(mg_flags);
}

static int modperl_env_request_set(pTHX_ SV *sv, MAGIC *mg)
{
    const char *key, *val;
    STRLEN klen, vlen;
    request_rec *r = (request_rec *)EnvMgObj;

    key = (const char *)MgPV(mg,klen);
    val = (const char *)SvPV(sv,vlen);

    apr_table_set(r->subprocess_env, key, val);

    /*return magic_setenv(sv, mg);*/

    return 0;
}

#ifdef MP_PERL_HV_GMAGICAL_AWARE
static int modperl_env_request_get(pTHX_ SV *sv, MAGIC *mg)
{
    const char *key, *val;
    STRLEN klen;
    request_rec *r = (request_rec *)EnvMgObj;

    key = (const char *)MgPV(mg,klen);

    if ((val = apr_table_get(r->subprocess_env, key))) {
        sv_setpv(sv, val);
    }
    else {
        sv_setsv(sv, &PL_sv_undef);
    }

    return 0;
}
#endif

#define MpDirSeenSETUP_ENV(dcfg) \
    (dcfg->flags->opts_seen & MpDir_f_SETUP_ENV)

void modperl_env_request_tie(pTHX_ request_rec *r)
{
    MP_dDCFG;

    if (MpDirSETUP_ENV(dcfg) || !MpDirSeenSETUP_ENV(dcfg)) {
        modperl_env_request_populate(aTHX_ r);
    }

    EnvMgObj = (char *)r;

    PL_vtbl_envelem.svt_set = MEMBER_TO_FPTR(modperl_env_request_set);
#ifdef MP_PERL_HV_GMAGICAL_AWARE
    SvGMAGICAL_on((SV*)GvHV(PL_envgv));
    PL_vtbl_envelem.svt_get = MEMBER_TO_FPTR(modperl_env_request_get);
#endif
}

void modperl_env_request_untie(pTHX_ request_rec *r)
{
    PL_vtbl_envelem.svt_set = MEMBER_TO_FPTR(Perl_magic_setenv);
#ifdef MP_PERL_HV_GMAGICAL_AWARE
    SvGMAGICAL_off((SV*)GvHV(PL_envgv));
    PL_vtbl_envelem.svt_get = 0;
#endif
}
