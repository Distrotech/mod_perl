#include "mod_perl.h"

PerlInterpreter *modperl_startup(server_rec *s, ap_pool_t *p)
{
    MP_dSCFG(s);
    PerlInterpreter *perl;
    int status;
    char **argv;
    int argc;

#ifdef MP_USE_GTOP
    MP_TRACE_m_do(
        scfg->gtop = modperl_gtop_new(p);
        modperl_gtop_do_proc_mem_before(MP_FUNC ": perl_parse");
    );
#endif

    argv = modperl_srv_config_argv_init(scfg, &argc);

    if (!(perl = perl_alloc())) {
        perror("perl_alloc");
        exit(1);
    }

    perl_construct(perl);

    status = perl_parse(perl, xs_init, argc, argv, NULL);

    if (status) {
        perror("perl_parse");
        exit(1);
    }

    perl_run(perl);

#ifdef MP_USE_GTOP
    MP_TRACE_m_do(
        modperl_gtop_do_proc_mem_after(MP_FUNC ": perl_parse");
    );
#endif

    return perl;
}

void modperl_init(server_rec *base_server, ap_pool_t *p)
{
    server_rec *s;
    modperl_srv_config_t *base_scfg =
      (modperl_srv_config_t *)
        ap_get_module_config(base_server->module_config, &perl_module);
    PerlInterpreter *base_perl;

    MP_TRACE_d_do(MpSrv_dump_flags(base_scfg,
                                   base_server->server_hostname));

    if (!MpSrvENABLED(base_scfg)) {
        /* how silly */
        return;
    }

    base_perl = modperl_startup(base_server, p);

#ifdef USE_ITHREADS
    modperl_interp_init(base_server, p, base_perl);
    MpInterpBASE_On(base_scfg->mip->parent);
#endif

    for (s=base_server->next; s; s=s->next) {
        MP_dSCFG(s);
        PerlInterpreter *perl = base_perl;

        MP_TRACE_d_do(MpSrv_dump_flags(scfg, s->server_hostname));

        /* if alloc flags is On, virtual host gets its own parent perl */
        if (MpSrvPARENT(scfg)) {
            perl = modperl_startup(s, p);
            MP_TRACE_i(MP_FUNC, "modperl_startup() server=%s\n",
                       s->server_hostname);
        }

#ifdef USE_ITHREADS

        if (!MpSrvENABLED(scfg)) {
            scfg->mip = NULL;
            continue;
        }

        /* if alloc flags is On or clone flag is On,
         *  virtual host gets its own mip
         */
        if (MpSrvPARENT(scfg) || MpSrvCLONE(scfg)) {
            MP_TRACE_i(MP_FUNC, "modperl_interp_init() server=%s\n",
                       s->server_hostname);
            modperl_interp_init(s, p, perl);
        }

        /* if we allocated a parent perl, mark it to be destroyed */
        if (MpSrvPARENT(scfg)) {
            MpInterpBASE_On(scfg->mip->parent);
        }

        if (!scfg->mip) {
            /* since mips are created after merge_server_configs()
             * need to point to the base mip here if this vhost
             * doesn't have its own
             */
            scfg->mip = base_scfg->mip;
        }

#endif /* USE_ITHREADS */

    }
}

void modperl_hook_init(ap_pool_t *pconf, ap_pool_t *plog, 
                       ap_pool_t *ptemp, server_rec *s)
{
    modperl_init(s, pconf);
}

void modperl_pre_config_handler(ap_pool_t *p, ap_pool_t *plog,
                                ap_pool_t *ptemp)
{
}

void modperl_register_hooks(void)
{
    /* XXX: should be pre_config hook or 1.xx logic */
    ap_hook_open_logs(modperl_hook_init, NULL, NULL, AP_HOOK_MIDDLE);
    modperl_register_handler_hooks();
}

static command_rec modperl_cmds[] = {  
    MP_SRV_CMD_ITERATE("PerlSwitches", switches, "Perl Switches"),
    MP_SRV_CMD_ITERATE("PerlOptions", options, "Perl Options"),
#ifdef MP_TRACE
    MP_SRV_CMD_TAKE1("PerlTrace", trace, "Trace level"),
#endif
#ifdef USE_ITHREADS
    MP_SRV_CMD_TAKE1("PerlInterpStart", interp_start,
                     "Number of Perl interpreters to start"),
    MP_SRV_CMD_TAKE1("PerlInterpMax", interp_max,
                     "Max number of running Perl interpreters"),
    MP_SRV_CMD_TAKE1("PerlInterpMaxSpare", interp_max_spare,
                     "Max number of spare Perl interpreters"),
    MP_SRV_CMD_TAKE1("PerlInterpMinSpare", interp_min_spare,
                     "Min number of spare Perl interpreters"),
    MP_SRV_CMD_TAKE1("PerlInterpMaxRequests", interp_max_requests,
                     "Max number of requests per Perl interpreters"),
#endif
    MP_CMD_ENTRIES,
    { NULL }, 
}; 

static handler_rec modperl_handlers[] = {
    { NULL },
};

module MODULE_VAR_EXPORT perl_module = {
    STANDARD20_MODULE_STUFF, 
    modperl_create_dir_config, /* dir config creater */
    modperl_merge_dir_config,  /* dir merger --- default is to override */
    modperl_create_srv_config, /* server config */
    modperl_merge_srv_config,  /* merge server config */
    modperl_cmds,              /* table of config file commands       */
    modperl_handlers,          /* handlers */
    modperl_register_hooks,    /* register hooks */
};
