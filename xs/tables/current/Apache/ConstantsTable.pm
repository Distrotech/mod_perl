package Apache::ConstantsTable;

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! WARNING: generated by Apache::ParseSource/0.02
# !          Wed Apr 11 17:57:08 2001
# !          do NOT edit, any changes will be lost !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

$Apache::ConstantsTable = {
  'Apache' => {
    'http' => [
      'HTTP_CONTINUE',
      'HTTP_SWITCHING_PROTOCOLS',
      'HTTP_PROCESSING',
      'HTTP_OK',
      'HTTP_CREATED',
      'HTTP_ACCEPTED',
      'HTTP_NON_AUTHORITATIVE',
      'HTTP_NO_CONTENT',
      'HTTP_RESET_CONTENT',
      'HTTP_PARTIAL_CONTENT',
      'HTTP_MULTI_STATUS',
      'HTTP_MULTIPLE_CHOICES',
      'HTTP_MOVED_PERMANENTLY',
      'HTTP_MOVED_TEMPORARILY',
      'HTTP_SEE_OTHER',
      'HTTP_NOT_MODIFIED',
      'HTTP_USE_PROXY',
      'HTTP_TEMPORARY_REDIRECT',
      'HTTP_BAD_REQUEST',
      'HTTP_UNAUTHORIZED',
      'HTTP_PAYMENT_REQUIRED',
      'HTTP_FORBIDDEN',
      'HTTP_NOT_FOUND',
      'HTTP_METHOD_NOT_ALLOWED',
      'HTTP_NOT_ACCEPTABLE',
      'HTTP_PROXY_AUTHENTICATION_REQUIRED',
      'HTTP_REQUEST_TIME_OUT',
      'HTTP_CONFLICT',
      'HTTP_GONE',
      'HTTP_LENGTH_REQUIRED',
      'HTTP_PRECONDITION_FAILED',
      'HTTP_REQUEST_ENTITY_TOO_LARGE',
      'HTTP_REQUEST_URI_TOO_LARGE',
      'HTTP_UNSUPPORTED_MEDIA_TYPE',
      'HTTP_RANGE_NOT_SATISFIABLE',
      'HTTP_EXPECTATION_FAILED',
      'HTTP_UNPROCESSABLE_ENTITY',
      'HTTP_LOCKED',
      'HTTP_FAILED_DEPENDENCY',
      'HTTP_INTERNAL_SERVER_ERROR',
      'HTTP_NOT_IMPLEMENTED',
      'HTTP_BAD_GATEWAY',
      'HTTP_SERVICE_UNAVAILABLE',
      'HTTP_GATEWAY_TIME_OUT',
      'HTTP_VARIANT_ALSO_VARIES',
      'HTTP_INSUFFICIENT_STORAGE',
      'HTTP_NOT_EXTENDED'
    ],
    'options' => [
      'OPT_NONE',
      'OPT_INDEXES',
      'OPT_INCLUDES',
      'OPT_SYM_LINKS',
      'OPT_EXECCGI',
      'OPT_UNSET',
      'OPT_INCNOEXEC',
      'OPT_SYM_OWNER',
      'OPT_MULTI',
      'OPT_ALL'
    ],
    'methods' => [
      'M_GET',
      'M_PUT',
      'M_POST',
      'M_DELETE',
      'M_CONNECT',
      'M_OPTIONS',
      'M_TRACE',
      'M_PATCH',
      'M_PROPFIND',
      'M_PROPPATCH',
      'M_MKCOL',
      'M_COPY',
      'M_MOVE',
      'M_LOCK',
      'M_UNLOCK',
      'M_INVALID',
      'METHODS'
    ],
    'satisfy' => [
      'SATISFY_ALL',
      'SATISFY_ANY',
      'SATISFY_NOSPEC'
    ],
    'common' => [
      'DECLINED',
      'DONE',
      'OK',
      'NOT_FOUND',
      'FORBIDDEN',
      'AUTH_REQUIRED',
      'SERVER_ERROR'
    ],
    'override' => [
      'OR_NONE',
      'OR_LIMIT',
      'OR_OPTIONS',
      'OR_FILEINFO',
      'OR_AUTHCFG',
      'OR_INDEXES',
      'OR_UNSET',
      'ACCESS_CONF',
      'RSRC_CONF',
      'OR_ALL'
    ],
    'cmd_how' => [
      'RAW_ARGS',
      'TAKE1',
      'TAKE2',
      'ITERATE',
      'ITERATE2',
      'FLAG',
      'NO_ARGS',
      'TAKE12',
      'TAKE3',
      'TAKE23',
      'TAKE123',
      'TAKE13'
    ],
    'remotehost' => [
      'REMOTE_HOST',
      'REMOTE_NAME',
      'REMOTE_NOLOOKUP',
      'REMOTE_DOUBLE_REV'
    ]
  },
  'APR' => {
    'fileperms' => [
      'APR_UREAD',
      'APR_UWRITE',
      'APR_UEXECUTE',
      'APR_GREAD',
      'APR_GWRITE',
      'APR_GEXECUTE',
      'APR_WREAD',
      'APR_WWRITE',
      'APR_WEXECUTE'
    ],
    'shutdown_how' => [
      'APR_SHUTDOWN_READ',
      'APR_SHUTDOWN_WRITE',
      'APR_SHUTDOWN_READWRITE'
    ],
    'common' => [
      'APR_SUCCESS'
    ],
    'filepath' => [
      'APR_FILEPATH_NOTABOVEROOT',
      'APR_FILEPATH_SECUREROOTTEST',
      'APR_FILEPATH_SECUREROOT',
      'APR_FILEPATH_NOTRELATIVE',
      'APR_FILEPATH_NOTABSOLUTE',
      'APR_FILEPATH_NATIVE',
      'APR_FILEPATH_TRUENAME'
    ],
    'hook' => [
      'APR_HOOK_REALLY_FIRST',
      'APR_HOOK_FIRST',
      'APR_HOOK_MIDDLE',
      'APR_HOOK_LAST',
      'APR_HOOK_REALLY_LAST'
    ],
    'socket' => [
      'APR_SO_LINGER',
      'APR_SO_KEEPALIVE',
      'APR_SO_DEBUG',
      'APR_SO_NONBLOCK',
      'APR_SO_REUSEADDR',
      'APR_SO_TIMEOUT',
      'APR_SO_SNDBUF',
      'APR_SO_RCVBUF',
      'APR_SO_DISCONNECTED'
    ],
    'poll' => [
      'APR_POLLIN',
      'APR_POLLPRI',
      'APR_POLLOUT',
      'APR_POLLERR',
      'APR_POLLHUP',
      'APR_POLLNVAL'
    ],
    'flock' => [
      'APR_FLOCK_SHARED',
      'APR_FLOCK_EXCLUSIVE',
      'APR_FLOCK_TYPEMASK',
      'APR_FLOCK_NONBLOCK'
    ],
    'filemode' => [
      'APR_READ',
      'APR_WRITE',
      'APR_CREATE',
      'APR_APPEND',
      'APR_TRUNCATE',
      'APR_BINARY',
      'APR_EXCL',
      'APR_BUFFERED',
      'APR_DELONCLOSE'
    ],
    'error' => [
      'APR_ENOSTAT',
      'APR_ENOPOOL',
      'APR_ENOFILE',
      'APR_EBADDATE',
      'APR_EINVALSOCK',
      'APR_ENOPROC',
      'APR_ENOTIME',
      'APR_ENODIR',
      'APR_ENOLOCK',
      'APR_ENOPOLL',
      'APR_ENOSOCKET',
      'APR_ENOTHREAD',
      'APR_ENOTHDKEY',
      'APR_EGENERAL',
      'APR_ENOSHMAVAIL',
      'APR_EBADIP',
      'APR_EBADMASK',
      'APR_EDSOOPEN',
      'APR_EABSOLUTE',
      'APR_ERELATIVE',
      'APR_EINCOMPLETE',
      'APR_EABOVEROOT',
      'APR_EBADPATH',
      'APR_EOF',
      'APR_EINIT',
      'APR_ENOTIMPL',
      'APR_EMISMATCH',
      'APR_EACCES',
      'APR_EEXIST',
      'APR_ENAMETOOLONG',
      'APR_ENOENT',
      'APR_ENOTDIR',
      'APR_ENOSPC',
      'APR_ENOMEM',
      'APR_EMFILE',
      'APR_ENFILE',
      'APR_EBADF',
      'APR_EINVAL',
      'APR_ESPIPE',
      'APR_EAGAIN',
      'APR_EINTR',
      'APR_ENOTSOCK',
      'APR_ECONNREFUSED',
      'APR_EINPROGRESS',
      'APR_ECONNABORTED',
      'APR_ECONNRESET',
      'APR_ETIMEDOUT',
      'APR_EHOSTUNREACH',
      'APR_ENETUNREACH',
      'APR_END'
    ],
    'finfo' => [
      'APR_FINFO_LINK',
      'APR_FINFO_MTIME',
      'APR_FINFO_CTIME',
      'APR_FINFO_ATIME',
      'APR_FINFO_SIZE',
      'APR_FINFO_CSIZE',
      'APR_FINFO_DEV',
      'APR_FINFO_INODE',
      'APR_FINFO_NLINK',
      'APR_FINFO_TYPE',
      'APR_FINFO_USER',
      'APR_FINFO_GROUP',
      'APR_FINFO_UPROT',
      'APR_FINFO_GPROT',
      'APR_FINFO_WPROT',
      'APR_FINFO_ICASE',
      'APR_FINFO_NAME',
      'APR_FINFO_MIN',
      'APR_FINFO_IDENT',
      'APR_FINFO_OWNER',
      'APR_FINFO_PROT',
      'APR_FINFO_NORM',
      'APR_FINFO_DIRENT'
    ],
    'limit' => [
      'APR_LIMIT_CPU',
      'APR_LIMIT_MEM',
      'APR_LIMIT_NPROC'
    ]
  }
};


1;
