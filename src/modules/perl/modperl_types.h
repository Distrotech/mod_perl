/* aliases */

typedef ap_array_header_t MpAV;
typedef ap_table_t        MpHV;

/* xs typemap */

typedef request_rec *  Apache;
typedef request_rec *  Apache__SubRequest;
typedef conn_rec    *  Apache__Connection;
typedef server_rec  *  Apache__Server;

typedef cmd_parms   *  Apache__CmdParms;
typedef module      *  Apache__Module;
typedef handler_rec *  Apache__Handler;
typedef command_rec *  Apache__Command;

typedef ap_table_t   * Apache__table;
typedef ap_context_t * Apache__Context;

/* mod_perl structures */

typedef struct {
    PerlInterpreter *perl;
} modperl_runtime_t;

typedef struct {
    MpAV *handlers[MP_PROCESS_NUM_HANDLERS];
} modperl_process_config_t;

typedef struct {
    MpAV *handlers[MP_CONNECTION_NUM_HANDLERS];
} modperl_connection_config_t;

typedef struct {
    MpAV *handlers[MP_FILES_NUM_HANDLERS];
} modperl_files_config_t;

typedef struct {
    MpHV *SetVars;
    MpAV *PassEnv;
    MpAV *PerlRequire, *PerlModule;
    MpAV *handlers[MP_PER_SRV_NUM_HANDLERS];
    modperl_process_config_t *process_cfg;
    modperl_connection_config_t *connection_cfg;
    modperl_runtime_t *runtime;
    int flags;
} modperl_srv_config_t;

typedef struct {
    char *location;
    char *PerlDispatchHandler;
    MpAV *handlers[MP_PER_DIR_NUM_HANDLERS];
    MpHV *SetEnv;
    MpHV *SetVars;
    int flags;
} modperl_dir_config_t;

typedef struct {
    HV *pnotes;
} modperl_per_request_config_t;

typedef struct {
    SV *obj;
    CV *cv;
    char *name;
    int flags;
} modperl_handler_t;
