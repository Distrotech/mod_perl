#include "mod_perl.h"

void *modperl_config_dir_create(apr_pool_t *p, char *dir)
{
    modperl_config_dir_t *dcfg = modperl_config_dir_new(p);

    dcfg->location = dir;
    
#ifdef USE_ITHREADS
    /* defaults to per-server scope */
    dcfg->interp_scope = MP_INTERP_SCOPE_UNDEF;
#endif

    return dcfg;
}

#define merge_item(item) \
    mrg->item = add->item ? add->item : base->item

/* take the 'base' values, and override with 'add' values if any */
#define merge_table_overlap_item(item) \
    { \
        apr_array_header_t *arr = apr_table_elts(base->item); \
        apr_table_entry_t *entries  = (apr_table_entry_t *)arr->elts; \
        int i; \
        mrg->item = apr_table_copy(p, add->item); \
        for (i = 0; i < arr->nelts; i++) { \
            char *val; \
            if ((val = (char *)apr_table_get(add->item, entries[i].key))){ \
                continue; \
            } \
            else if ((val = (char *)apr_table_get(base->item, entries[i].key))){ \
                apr_table_set(mrg->item, entries[i].key, val); \
            } \
        } \
    }

#define merge_handlers(merge_flag, array) \
    if (merge_flag(mrg)) { \
        mrg->array = modperl_handler_array_merge(p, \
                                                 base->array, \
                                                 add->array); \
    } \
    else { \
        merge_item(array); \
    }

void *modperl_config_dir_merge(apr_pool_t *p, void *basev, void *addv)
{
    int i;
    modperl_config_dir_t
        *base = (modperl_config_dir_t *)basev,
        *add  = (modperl_config_dir_t *)addv,
        *mrg  = modperl_config_dir_new(p);

    MP_TRACE_d(MP_FUNC, "basev==0x%lx, addv==0x%lx\n", 
               (unsigned long)basev, (unsigned long)addv);

#ifdef USE_ITHREADS
    merge_item(interp_scope);
#endif

    mrg->flags = modperl_options_merge(p, base->flags, add->flags);

    merge_item(location);
    
    merge_table_overlap_item(SetVar);

    /* XXX: check if Perl*Handler is disabled */
    for (i=0; i < MP_HANDLER_NUM_PER_DIR; i++) {
        merge_handlers(MpDirMERGE_HANDLERS, handlers_per_dir[i]);
    }

    return mrg;
}

modperl_config_req_t *modperl_config_req_new(request_rec *r)
{
    modperl_config_req_t *rcfg = 
        (modperl_config_req_t *)apr_pcalloc(r->pool, sizeof(*rcfg));

    rcfg->wbucket.r = r;

    MP_TRACE_d(MP_FUNC, "0x%lx\n", (unsigned long)rcfg);

    return rcfg;
}

modperl_config_srv_t *modperl_config_srv_new(apr_pool_t *p)
{
    modperl_config_srv_t *scfg = (modperl_config_srv_t *)
        apr_pcalloc(p, sizeof(*scfg));

    scfg->flags = modperl_options_new(p, MpSrvType);
    MpSrvENABLE_On(scfg); /* mod_perl enabled by default */
    MpSrvHOOKS_ALL_On(scfg); /* all hooks enabled by default */

    scfg->PerlModule  = apr_array_make(p, 2, sizeof(char *));
    scfg->PerlRequire = apr_array_make(p, 2, sizeof(char *));

    scfg->argv = apr_array_make(p, 2, sizeof(char *));

    scfg->SetVar = apr_table_make(p, 2);
    
    modperl_config_srv_argv_push((char *)ap_server_argv0);

    MP_TRACE_d(MP_FUNC, "0x%lx\n", (unsigned long)scfg);

    return scfg;
}

modperl_config_dir_t *modperl_config_dir_new(apr_pool_t *p)
{
    modperl_config_dir_t *dcfg = (modperl_config_dir_t *)
        apr_pcalloc(p, sizeof(modperl_config_dir_t));

    dcfg->flags = modperl_options_new(p, MpDirType);

    dcfg->SetVar = apr_table_make(p, 2);
    
    MP_TRACE_d(MP_FUNC, "0x%lx\n", (unsigned long)dcfg);

    return dcfg;
}

#ifdef MP_TRACE
static void dump_argv(modperl_config_srv_t *scfg)
{
    int i;
    char **argv = (char **)scfg->argv->elts;
    fprintf(stderr, "modperl_config_srv_argv_init =>\n");
    for (i=0; i<scfg->argv->nelts; i++) {
        fprintf(stderr, "   %d = %s\n", i, argv[i]);
    }
}
#endif

char **modperl_config_srv_argv_init(modperl_config_srv_t *scfg, int *argc)
{
    modperl_config_srv_argv_push("-e;0");
    
    *argc = scfg->argv->nelts;

    MP_TRACE_g_do(dump_argv(scfg));

    return (char **)scfg->argv->elts;
}

void *modperl_config_srv_create(apr_pool_t *p, server_rec *s)
{
    modperl_config_srv_t *scfg = modperl_config_srv_new(p);

    ap_mpm_query(AP_MPMQ_IS_THREADED, &scfg->threaded_mpm);

#ifdef USE_ITHREADS

    scfg->interp_pool_cfg = 
        (modperl_tipool_config_t *)
        apr_pcalloc(p, sizeof(*scfg->interp_pool_cfg));

    scfg->interp_scope = MP_INTERP_SCOPE_REQUEST;

    /* XXX: determine reasonable defaults */
    scfg->interp_pool_cfg->start = 3;
    scfg->interp_pool_cfg->max_spare = 3;
    scfg->interp_pool_cfg->min_spare = 3;
    scfg->interp_pool_cfg->max = 5;
    scfg->interp_pool_cfg->max_requests = 2000;
#endif /* USE_ITHREADS */

    return scfg;
}

/* XXX: this is not complete */
void *modperl_config_srv_merge(apr_pool_t *p, void *basev, void *addv)
{
    int i;
    modperl_config_srv_t
        *base = (modperl_config_srv_t *)basev,
        *add  = (modperl_config_srv_t *)addv,
        *mrg  = modperl_config_srv_new(p);

    MP_TRACE_d(MP_FUNC, "basev==0x%lx, addv==0x%lx\n", 
               (unsigned long)basev, (unsigned long)addv);

    merge_item(PerlModule);
    merge_item(PerlRequire);

    merge_table_overlap_item(SetVar);
 
    merge_item(threaded_mpm);

#ifdef USE_ITHREADS
    merge_item(mip);
    merge_item(interp_pool_cfg);
    merge_item(interp_scope);
#else
    merge_item(perl);
#endif

    if (add->argv->nelts == 2 &&
        strEQ(((char **)add->argv->elts)[1], "+inherit"))
    {
        /* only inherit base PerlSwitches if explicitly told to */
        mrg->argv = base->argv;
    }
    else {
        mrg->argv = add->argv;
    }

    mrg->flags = modperl_options_merge(p, base->flags, add->flags);

    /* XXX: check if Perl*Handler is disabled */
    for (i=0; i < MP_HANDLER_NUM_PER_SRV; i++) {
        merge_handlers(MpSrvMERGE_HANDLERS, handlers_per_srv[i]);
    }
    for (i=0; i < MP_HANDLER_NUM_FILES; i++) {
        merge_handlers(MpSrvMERGE_HANDLERS, handlers_files[i]);
    }
    for (i=0; i < MP_HANDLER_NUM_PROCESS; i++) {
        merge_handlers(MpSrvMERGE_HANDLERS, handlers_process[i]);
    }
    for (i=0; i < MP_HANDLER_NUM_CONNECTION; i++) {
        merge_handlers(MpSrvMERGE_HANDLERS, handlers_connection[i]);
    }

    return mrg;
}

void *modperl_get_perl_module_config(ap_conf_vector_t *cv)
{
    return ap_get_module_config(cv, &perl_module);
}

void modperl_set_perl_module_config(ap_conf_vector_t *cv, void *cfg)
{
    ap_set_module_config(cv, &perl_module, cfg);
}

int modperl_config_apply_PerlModule(server_rec *s,
                                    modperl_config_srv_t *scfg,
                                    PerlInterpreter *perl, apr_pool_t *p)
{
    char **entries;
    int i;
    dTHXa(perl);

    entries = (char **)scfg->PerlModule->elts;
    for (i = 0; i < scfg->PerlModule->nelts; i++){
        if (modperl_require_module(aTHX_ entries[i], TRUE)){
            MP_TRACE_d(MP_FUNC, "loaded Perl module %s for server %s\n",
                       entries[i], modperl_server_desc(s,p));
        }
        else {
            ap_log_error(APLOG_MARK, APLOG_ERR, 0, s,
                         "Can't load Perl module %s for server %s, exiting...\n",
                         entries[i], modperl_server_desc(s,p));
            return FALSE;
        }
    }

    return TRUE;
}

int modperl_config_apply_PerlRequire(server_rec *s,
                                     modperl_config_srv_t *scfg,
                                     PerlInterpreter *perl, apr_pool_t *p)
{
    char **entries;
    int i;
    dTHXa(perl);

    entries = (char **)scfg->PerlRequire->elts;
    for (i = 0; i < scfg->PerlRequire->nelts; i++){
        if (modperl_require_file(aTHX_ entries[i], TRUE)){
            MP_TRACE_d(MP_FUNC, "loaded Perl file: %s for server %s\n",
                       entries[i], modperl_server_desc(s,p));
        }
        else {
            ap_log_error(APLOG_MARK, APLOG_ERR, 0, s,
                         "Can't load Perl file: %s for server %s, exiting...\n",
                         entries[i], modperl_server_desc(s,p));
            return FALSE;
        }
    }

    return TRUE;
}
