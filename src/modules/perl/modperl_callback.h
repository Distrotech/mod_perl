#ifndef MODPERL_CALLBACK_H
#define MODPERL_CALLBACK_H

/* alias some hook names to match Perl*Handler names */
#define ap_hook_trans  ap_hook_translate_name
#define ap_hook_access ap_hook_access_checker
#define ap_hook_authen ap_hook_check_user_id
#define ap_hook_authz  ap_hook_auth_checker
#define ap_hook_type   ap_hook_type_checker
#define ap_hook_fixup  ap_hook_fixups
#define ap_hook_log    ap_hook_log_transaction

#define MP_HANDLER_TYPE_PER_DIR    1
#define MP_HANDLER_TYPE_PER_SRV    2
#define MP_HANDLER_TYPE_CONNECTION 3
#define MP_HANDLER_TYPE_PROCESS    4
#define MP_HANDLER_TYPE_FILES      5

modperl_handler_t *modperl_handler_new(apr_pool_t *p, const char *name);

modperl_handler_t *modperl_handler_dup(apr_pool_t *p,
                                       modperl_handler_t *h);

void modperl_handler_make_args(pTHX_ AV **avp, ...);

int modperl_callback(pTHX_ modperl_handler_t *handler, apr_pool_t *p,
                     AV *args);

int modperl_run_handlers(int idx, request_rec *r, conn_rec *c,
                         server_rec *s, int type, ...);

void modperl_process_callback(int idx, apr_pool_t *p, server_rec *s);

void modperl_files_callback(int idx,
                            apr_pool_t *pconf, apr_pool_t *plog,
                            apr_pool_t *ptemp, server_rec *s);

int modperl_per_dir_callback(int idx, request_rec *r);

int modperl_per_srv_callback(int idx, request_rec *r);

int modperl_connection_callback(int idx, conn_rec *c);

#endif /* MODPERL_CALLBACK_H */
