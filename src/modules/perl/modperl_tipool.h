#ifndef MODPERL_TIPOOL_H

#ifdef USE_ITHREADS

modperl_list_t *modperl_list_new(ap_pool_t *p);

modperl_list_t *modperl_list_last(modperl_list_t *list);

modperl_list_t *modperl_list_first(modperl_list_t *list);

modperl_list_t *modperl_list_append(modperl_list_t *list,
                                    modperl_list_t *new_list);

modperl_list_t *modperl_list_prepend(modperl_list_t *list,
                                     modperl_list_t *new_list);

modperl_list_t *modperl_list_remove(modperl_list_t *list,
                                    modperl_list_t *rlist);

modperl_tipool_t *modperl_tipool_new(ap_pool_t *p,
                                     modperl_tipool_config_t *cfg,
                                     modperl_tipool_vtbl_t *func,
                                     void *data);

void modperl_tipool_init(modperl_tipool_t *tipool);

void modperl_tipool_destroy(modperl_tipool_t *tipool);

void modperl_tipool_add(modperl_tipool_t *tipool, void *data);

void modperl_tipool_remove(modperl_tipool_t *tipool, modperl_list_t *listp);

modperl_list_t *modperl_tipool_pop(modperl_tipool_t *tipool);

void modperl_tipool_putback(modperl_tipool_t *tipool,
                            modperl_list_t *listp,
                            int num_requests);

void modperl_tipool_putback_data(modperl_tipool_t *tipool, void *data,
                                 int num_requests);

#define modperl_tipool_wait(tipool) \
    while (tipool->size == tipool->in_use) { \
        MP_TRACE_i(MP_FUNC, "waiting for available tipool item\n"); \
        MP_TRACE_i(MP_FUNC, "(%d items in use, %d alive)\n", \
                   tipool->in_use, tipool->size); \
        COND_WAIT(&tipool->available, &tipool->tiplock); \
    }

#define modperl_tipool_broadcast(tipool) \
    MP_TRACE_i(MP_FUNC, "broadcast available tipool item\n"); \
    COND_SIGNAL(&tipool->available)

#define modperl_tipool_lock(tipool) \
    MP_TRACE_i(MP_FUNC, "about to lock tipool\n"); \
    MUTEX_LOCK(&tipool->tiplock); \
    MP_TRACE_i(MP_FUNC, "aquired tipool lock\n")

#define modperl_tipool_unlock(tipool) \
    MP_TRACE_i(MP_FUNC, "about to unlock tipool\n"); \
    MUTEX_UNLOCK(&tipool->tiplock); \
    MP_TRACE_i(MP_FUNC, "released tipool lock\n")

#endif /* USE_ITHREADS */

#endif /* MODPERL_TIPOOL_H */
