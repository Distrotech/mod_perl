#ifndef MODPERL_CALLBACK_H
#define MODPERL_CALLBACK_H

modperl_handler_t *modperl_handler_new(ap_pool_t *p, void *h, int type);

ap_status_t modperl_handler_cleanup(void *data);

void modperl_handler_cache_cv(pTHX_ modperl_handler_t *handler, CV *cv);

int modperl_handler_lookup(pTHX_ modperl_handler_t *handler,
                           char *class, char *name);

void modperl_handler_unparse(pTHX_ modperl_handler_t *handler);

int modperl_handler_parse(pTHX_ modperl_handler_t *handler);

int modperl_callback(pTHX_ modperl_handler_t *handler);

void modperl_process_callback(int idx, ap_pool_t *p, server_rec *s);

void modperl_files_callback(int idx,
                            ap_pool_t *pconf, ap_pool_t *plog,
                            ap_pool_t *ptemp, server_rec *s);

int modperl_per_dir_callback(int idx, request_rec *r);

int modperl_per_srv_callback(int idx, request_rec *r);

int modperl_connection_callback(int idx, conn_rec *c);

#endif /* MODPERL_CALLBACK_H */
