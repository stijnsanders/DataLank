unit LibMy;
{

  LibMy: libmysql.dll wrapper for MariaDB/MySQL

  https://github.com/stijnsanders/DataLank

  based on MariaDB 10.1.14
  include/mysql/mysql.ini

}

interface

type
  my_bool=type byte;
  Pmy_bool=^my_bool;
  my_socket=type pointer;

const
  //PROTOCOL_VERSION = 10;
  MYSQL_PORT = 3306;
  MYSQL_CONFIG_NAME = 'my';
  MYSQL50_TABLE_NAME_PREFIX = '#mysql50#';
  RPL_VERSION_HACK = '5.5.5-';//see mysql_com.h notice!
  MYSQL_NAMEDPIPE = 'MySQL';
  MYSQL_SERVICENAME = 'MySQL';

type
  MYSQL_SERVER_COMMAND=(
    COM_SLEEP, COM_QUIT, COM_INIT_DB, COM_QUERY, COM_FIELD_LIST,
    COM_CREATE_DB, COM_DROP_DB, COM_REFRESH, COM_SHUTDOWN, COM_STATISTICS,
    COM_PROCESS_INFO, COM_CONNECT, COM_PROCESS_KILL, COM_DEBUG, COM_PING,
    COM_TIME, COM_DELAYED_INSERT, COM_CHANGE_USER, COM_BINLOG_DUMP,
    COM_TABLE_DUMP, COM_CONNECT_OUT, COM_REGISTER_SLAVE,
    COM_STMT_PREPARE, COM_STMT_EXECUTE, COM_STMT_SEND_LONG_DATA, COM_STMT_CLOSE,
    COM_STMT_RESET, COM_SET_OPTION, COM_STMT_FETCH, COM_DAEMON,
    //
    COM_END);

const
  NOT_NULL_FLAG = 1;
  PRI_KEY_FLAG = 1 shl 1;
  UNIQUE_KEY_FLAG = 1 shl 2;
  MULTIPLE_KEY_FLAG = 1 shl 3;
  BLOB_FLAG = 1 shl 4;
  UNSIGNED_FLAG = 1 shl 5;
  ZEROFILL_FLAG = 1 shl 6;
  BINARY_FLAG = 1 shl 7;

  ENUM_FLAG = 1 shl 8;
  AUTO_INCREMENT_FLAG = 1 shl 9;
  TIMESTAMP_FLAG = 1 shl 10;
  SET_FLAG = 1 shl 11;
  NO_DEFAULT_VALUE_FLAG = 1 shl 12;
  ON_UPDATE_NOW_FLAG = 1 shl 13;
  NUM_FLAG = 1 shl 15;
  PART_KEY_FLAG = 1 shl 14;
  GROUP_FLAG = 1 shl 15;
  UNIQUE_FLAG = 1 shl 16;
  BINCMP_FLAG = 1 shl 17;
  GET_FIXED_FIELDS_FLAG = 1 shl 18;
  FIELD_IN_PART_FUNC_FLAG = 1 shl 19;

  FIELD_IN_ADD_INDEX = 1 shl 20;
  FIELD_IS_RENAMED = 1 shl 21;
  FIELD_FLAGS_STORAGE_MEDIA = 22;
  FIELD_FLAGS_STORAGE_MEDIA_MASK = 3 shl FIELD_FLAGS_STORAGE_MEDIA;
  FIELD_FLAGS_COLUMN_FORMAT = 24;
  FIELD_FLAGS_COLUMN_FORMAT_MASK = 3 shl FIELD_FLAGS_COLUMN_FORMAT;
  FIELD_IS_DROPPED = 1 shl 26;
  HAS_EXPLICIT_VALUE = 1 shl 27;

  REFRESH_GRANT           = 1;
  REFRESH_LOG             = 1 shl 1;
  REFRESH_TABLES          = 1 shl 2;
  REFRESH_HOSTS           = 1 shl 3;
  REFRESH_STATUS          = 1 shl 4;
  REFRESH_THREADS         = 1 shl 5;
  REFRESH_SLAVE           = 1 shl 6;
  REFRESH_MASTER          = 1 shl 7;

  REFRESH_ERROR_LOG       = 1 shl 8;
  REFRESH_ENGINE_LOG      = 1 shl 9;
  REFRESH_BINARY_LOG      = 1 shl 10;
  REFRESH_RELAY_LOG       = 1 shl 11;
  REFRESH_GENERAL_LOG     = 1 shl 12;
  REFRESH_SLOW_LOG        = 1 shl 13;

  REFRESH_READ_LOCK       = 1 shl 14;
  REFRESH_CHECKPOINT      = 1 shl 15;

  REFRESH_QUERY_CACHE     = 1 shl 16;
  REFRESH_QUERY_CACHE_FREE = 1 shl 17;
  REFRESH_DES_KEY_FILE    = 1 shl 18;
  REFRESH_USER_RESOURCES  = 1 shl 19;
  REFRESH_FOR_EXPORT      = 1 shl 20;

  REFRESH_GENERIC         = 1 shl 30;
  REFRESH_FAST            = 1 shl 31;

  CLIENT_LONG_PASSWORD = 1;
  CLIENT_FOUND_ROWS = 1 shl 1;
  CLIENT_LONG_FLAG = 1 shl 2;
  CLIENT_CONNECT_WITH_DB = 1 shl 3;
  CLIENT_NO_SCHEMA = 1 shl 4;
  CLIENT_COMPRESS = 1 shl 5;
  CLIENT_ODBC = 1 shl 6;
  CLIENT_LOCAL_FILES = 1 shl 7;
  CLIENT_IGNORE_SPACE = 1 shl 8;
  CLIENT_PROTOCOL_41 = 1 shl 9;
  CLIENT_INTERACTIVE = 1 shl 10;
  CLIENT_SSL = 1 shl 11;
  CLIENT_IGNORE_SIGPIPE = 1 shl 12;
  CLIENT_TRANSACTIONS = 1 shl 13;
  CLIENT_RESERVED = 1 shl 14;
  CLIENT_SECURE_CONNECTION = 1 shl 15;
  CLIENT_MULTI_STATEMENTS = 1 shl 16;
  CLIENT_MULTI_RESULTS = 1 shl 17;
  CLIENT_PS_MULTI_RESULTS = 1 shl 18;

  CLIENT_PLUGIN_AUTH = 1 shl 19;
  CLIENT_CONNECT_ATTRS = 1 shl 20;
  CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA = 1 shl 21;
  CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS = 1 shl 22;

  CLIENT_PROGRESS = 1 shl 29;
  CLIENT_SSL_VERIFY_SERVER_CERT = 1 shl 30;
  CLIENT_REMEMBER_OPTIONS = 1 shl 31;

  SERVER_STATUS_IN_TRANS = 1;
  SERVER_STATUS_AUTOCOMMIT = 1 shl 1;
  SERVER_MORE_RESULTS_EXISTS = 1 shl 3;
  SERVER_QUERY_NO_GOOD_INDEX_USED = 1 shl 4;
  SERVER_QUERY_NO_INDEX_USED = 1 shl 5;
  SERVER_STATUS_CURSOR_EXISTS = 1 shl 6;
  SERVER_STATUS_LAST_ROW_SENT = 1 shl 7;
  SERVER_STATUS_DB_DROPPED = 1 shl 8;
  SERVER_STATUS_NO_BACKSLASH_ESCAPES = 1 shl 9;
  SERVER_STATUS_METADATA_CHANGED = 1 shl 10;
  SERVER_QUERY_WAS_SLOW = 1 shl 11;
  SERVER_PS_OUT_PARAMS = 1 shl 12;
  SERVER_STATUS_IN_TRANS_READONLY = 1 shl 13;

  SERVER_STATUS_CLEAR_SET =
    SERVER_QUERY_NO_GOOD_INDEX_USED or
    SERVER_QUERY_NO_INDEX_USED or
    SERVER_MORE_RESULTS_EXISTS or
    SERVER_STATUS_METADATA_CHANGED or
    SERVER_QUERY_WAS_SLOW or
    SERVER_STATUS_DB_DROPPED or
    SERVER_STATUS_CURSOR_EXISTS or
    SERVER_STATUS_LAST_ROW_SENT;

  MYSQL_ERRMSG_SIZE	= 1 shl 9;

type
  MYSQL_NET=record
    vio:pointer;
    buff,buff_end,write_pos,read_pos:PAnsiChar;
    fc:my_socket;
    remain_in_buf,length, buf_length, where_b,
    max_packet,max_packet_size:cardinal;
    pkt_nr,compress_pkt_nr,
    write_timeout, read_timeout, retry_count: cardinal;
    fcntl:cardinal;
    return_status:PCardinal;
    reading_or_writing:byte;
    save_char:byte;
    net_skip_rest_factor:byte;
    thread_specific_malloc,
    compress,unused3:my_bool;
    //
    thd:pointer;
    last_errno:cardinal;
    error:byte;
    unused4,unused5:my_bool;
    last_error:array[0..512] of AnsiChar;
    sqlstate:array[0..5] of byte;
    extension:pointer;
  end;

  MYSQL_FIELD_TYPE=(
      MYSQL_TYPE_DECIMAL,  MYSQL_TYPE_TINY,
			MYSQL_TYPE_SHORT,    MYSQL_TYPE_LONG,
			MYSQL_TYPE_FLOAT,    MYSQL_TYPE_DOUBLE,
			MYSQL_TYPE_NULL,     MYSQL_TYPE_TIMESTAMP,
			MYSQL_TYPE_LONGLONG, MYSQL_TYPE_INT24,
			MYSQL_TYPE_DATE,     MYSQL_TYPE_TIME,
			MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR,
			MYSQL_TYPE_NEWDATE,  MYSQL_TYPE_VARCHAR,
			MYSQL_TYPE_BIT,
                        MYSQL_TYPE_TIMESTAMP2,
                        MYSQL_TYPE_DATETIME2,
                        MYSQL_TYPE_TIME2,

      MYSQL_TYPE_NEWDECIMAL=246,
			MYSQL_TYPE_ENUM=247,
			MYSQL_TYPE_SET=248,
			MYSQL_TYPE_TINY_BLOB=249,
			MYSQL_TYPE_MEDIUM_BLOB=250,
			MYSQL_TYPE_LONG_BLOB=251,
			MYSQL_TYPE_BLOB=252,
			MYSQL_TYPE_VAR_STRING=253,
			MYSQL_TYPE_STRING=254,
			MYSQL_TYPE_GEOMETRY=255
  );

const
  MYSQL_SHUTDOWN_KILLABLE_CONNECT    = 1;
  MYSQL_SHUTDOWN_KILLABLE_TRANS      = 1 shl 1;
  MYSQL_SHUTDOWN_KILLABLE_LOCK_TABLE = 1 shl 2;
  MYSQL_SHUTDOWN_KILLABLE_UPDATE     = 1 shl 3;

  SHUTDOWN_DEFAULT = 0;
  SHUTDOWN_WAIT_CONNECTIONS= MYSQL_SHUTDOWN_KILLABLE_CONNECT;
  SHUTDOWN_WAIT_TRANSACTIONS= MYSQL_SHUTDOWN_KILLABLE_TRANS;
  SHUTDOWN_WAIT_UPDATES= MYSQL_SHUTDOWN_KILLABLE_UPDATE;
  SHUTDOWN_WAIT_ALL_BUFFERS= MYSQL_SHUTDOWN_KILLABLE_UPDATE shl 1;
  SHUTDOWN_WAIT_CRITICAL_BUFFERS= MYSQL_SHUTDOWN_KILLABLE_UPDATE shl 1 or 1;

  CURSOR_TYPE_NO_CURSOR= 0;
  CURSOR_TYPE_READ_ONLY= 1;
  CURSOR_TYPE_FOR_UPDATE= 2;
  CURSOR_TYPE_SCROLLABLE= 4;

  MYSQL_OPTION_MULTI_STATEMENTS_ON=0;
  MYSQL_OPTION_MULTI_STATEMENTS_OFF=1;

{
my_bool	my_net_init(NET *net, Vio* vio, void *thd, unsigned int my_flags);
void	my_net_local_init(NET *net);
void	net_end(NET *net);
void	net_clear(NET *net, my_bool clear_buffer);
my_bool net_realloc(NET *net, size_t length);
my_bool	net_flush(NET *net);
my_bool	my_net_write(NET *net,const unsigned char *packet, size_t len);
my_bool	net_write_command(NET *net,unsigned char command,
			  const unsigned char *header, size_t head_len,
			  const unsigned char *packet, size_t len);
int	net_real_write(NET *net,const unsigned char *packet, size_t len);
unsigned long my_net_read_packet(NET *net, my_bool read_from_server);
  my_net_read(A) my_net_read_packet((A), 0)

#ifdef MY_GLOBAL_INCLUDED
void my_net_set_write_timeout(NET *net, uint timeout);
void my_net_set_read_timeout(NET *net, uint timeout);
#endif

struct sockaddr;
int my_connect(my_socket s, const struct sockaddr *name, unsigned int namelen,
	       unsigned int timeout);
struct my_rnd_struct;

}

const
  STRING_RESULT=0;
  REAL_RESULT=1;
  INT_RESULT=2;
  ROW_RESULT=3;
  DECIMAL_RESULT=4;
  TIME_RESULT=5;

type
  UDF_ARGS=record
    arg_count:cardinal;
    Item_result:PInteger;
    args:PPAnsiChar;
    lengths:PCardinal;
    maybe_null:Pmy_bool;
    attributes:PPAnsiChar;
    attribute_lengths:PCardinal;
    extension:pointer;
  end;

  UDF_INIT=record
    maybe_null:my_bool;
    decimals:cardinal;
    max_length:integer;
    ptr:PAnsiChar;
    const_item:my_bool;
    extension:pointer;
  end;

  my_rnd_struct=type pointer;

{
procedure create_random_string(to_:PAnsiChar; length: integer;
  rand_st:my_rnd_struct); cdecl;

void hash_password(unsigned long *to, const char *password, unsigned int password_len);
void make_scrambled_password_323(char *to, const char *password);
void scramble_323(char *to, const char *message, const char *password);
my_bool check_scramble_323(const unsigned char *reply, const char *message,
                           unsigned long *salt);
void get_salt_from_password_323(unsigned long *res, const char *password);
void make_scrambled_password(char *to, const char *password);
void scramble(char *to, const char *message, const char *password);
my_bool check_scramble(const unsigned char *reply, const char *message,
                       const unsigned char *hash_stage2);
void get_salt_from_password(unsigned char *res, const char *password);
char *octet2hex(char *to, const char *str, unsigned int len);

char *get_tty_password(const char *opt_message);
void get_tty_password_buff(const char *opt_message, char *to, size_t length);
const char *mysql_errno_to_sqlstate(unsigned int mysql_errno);

}

function my_thread_init:my_bool; cdecl;
procedure my_thread_end; cdecl;

const
  MYSQL_TIMESTAMP_NONE     = -2;
  MYSQL_TIMESTAMP_ERROR    = -1;
  MYSQL_TIMESTAMP_DATE     =  0;
  MYSQL_TIMESTAMP_DATETIME =  1;
  MYSQL_TIMESTAMP_TIME     =  2;

type
  my_time_t=type cardinal;

  MYSQL_TIME=record
    year, month, day, hour, minute, second: integer;
    second_part: cardinal;
    time_type: integer;//MYSQL_TIMESTAMP_*
  end;
  PMYSQL_TIME=^MYSQL_TIME;

//?
//extern unsigned int mariadb_deinitialize_ssl;
//extern unsigned int mysql_port;
//extern char *mysql_unix_port;


  PLIST=^LIST;
  LIST=record
    prev,next:PLIST;
    data:pointer;
  end;

{
typedef int (*list_walk_action)(void *,void *);

extern LIST *list_add(LIST *root,LIST *element);
extern LIST *list_delete(LIST *root,LIST *element);
extern LIST *list_cons(void *data,LIST *root);
extern LIST *list_reverse(LIST *root);
extern void list_free(LIST *root,unsigned int free_data);
extern unsigned int list_length(LIST *);
extern int list_walk(LIST *,list_walk_action action,unsigned char * argument);

#define list_rest(a) ((a)->next)
#define list_push(a,b) (a)=list_cons((b),(a))
#define list_pop(A) {LIST *old=(A); (A)=list_delete(old,old); my_free(old);
}

//?
//extern unsigned int mariadb_deinitialize_ssl;
//extern unsigned int mysql_port;
//extern char *mysql_unix_port;

type
  MYSQL_FIELD=record
    name,org_name,table,org_table,db,catalog,def:PAnsiChar;
    length,max_length:cardinal;
    name_length,org_name_length,table_length,org_table_length,
    db_length,catalog_length,def_length,flags,decimals,charsetnr:integer;
    type_:MYSQL_FIELD_TYPE;
    extension:pointer;
  end;
  PMYSQL_FIELD=^MYSQL_FIELD;

  MYSQL_ROW_FIELDDATA=array[0..$FFF] of PAnsiChar;
  MYSQL_ROW=^MYSQL_ROW_FIELDDATA;//PPAnsiChar;
  MYSQL_FIELD_OFFSET=cardinal;
  my_ulonglong=int64;

  PMYSQL_ROWS=^MYSQL_ROWS;
  MYSQL_ROWS=record
    next:PMYSQL_ROWS;
    data:MYSQL_ROW;
    length:cardinal;
  end;
  MYSQL_ROW_OFFSET=PMYSQL_ROWS;

  size_t=cardinal;//TODO: machine-width-integer

  PUSED_MEM=^USED_MEM;
  USED_MEM=record
    next:PUSED_MEM;
    left,size:size_t;
  end;

  MEM_ROOT=record
    free,used,pre_alloc:PUSED_MEM;
    min_malloc,block_size:size_t;
    block_num:cardinal;
    first_block_usage:cardinal;
    error_handler:pointer;//TProcedureCDecl;
  end;

  EMBEDDED_QUERY_RESULT=record end;
  PEMBEDDED_QUERY_RESULT=^EMBEDDED_QUERY_RESULT;

  MYSQL_DATA=record
    data:PMYSQL_ROWS;
    embedded_info:PEMBEDDED_QUERY_RESULT;
    alloc:MEM_ROOT;
    rows:my_ulonglong;
    fields:cardinal;
    extension:pointer;
  end;
  PMYSQL_DATA=^MYSQL_DATA;

  MYSQL_OPTION=(
    MYSQL_OPT_CONNECT_TIMEOUT, MYSQL_OPT_COMPRESS, MYSQL_OPT_NAMED_PIPE,
    MYSQL_INIT_COMMAND, MYSQL_READ_DEFAULT_FILE, MYSQL_READ_DEFAULT_GROUP,
    MYSQL_SET_CHARSET_DIR, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_LOCAL_INFILE,
    MYSQL_OPT_PROTOCOL, MYSQL_SHARED_MEMORY_BASE_NAME, MYSQL_OPT_READ_TIMEOUT,
    MYSQL_OPT_WRITE_TIMEOUT, MYSQL_OPT_USE_RESULT,
    MYSQL_OPT_USE_REMOTE_CONNECTION, MYSQL_OPT_USE_EMBEDDED_CONNECTION,
    MYSQL_OPT_GUESS_CONNECTION, MYSQL_SET_CLIENT_IP, MYSQL_SECURE_AUTH,
    MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT,
    MYSQL_OPT_SSL_VERIFY_SERVER_CERT, MYSQL_PLUGIN_DIR, MYSQL_DEFAULT_AUTH,
    MYSQL_OPT_BIND,
    MYSQL_OPT_SSL_KEY, MYSQL_OPT_SSL_CERT,
    MYSQL_OPT_SSL_CA, MYSQL_OPT_SSL_CAPATH, MYSQL_OPT_SSL_CIPHER,
    MYSQL_OPT_SSL_CRL, MYSQL_OPT_SSL_CRLPATH,
    MYSQL_OPT_CONNECT_ATTR_RESET, MYSQL_OPT_CONNECT_ATTR_ADD,
    MYSQL_OPT_CONNECT_ATTR_DELETE,
    MYSQL_SERVER_PUBLIC_KEY,
    MYSQL_ENABLE_CLEARTEXT_PLUGIN,
    MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS,

    MYSQL_PROGRESS_CALLBACK=5999,
    MYSQL_OPT_NONBLOCK,
    MYSQL_OPT_USE_THREAD_SPECIFIC_MEMORY
  );

  TMYSQL_OPTIONS=record
    connect_timeout, read_timeout, write_timeout,
    port, protocol, client_flag: cardinal;
    host,user,password,unix_socket,db:PAnsiChar;
    init_commands:pointer;//Pst_dynamic_array;
    my_cnf_file,my_cnf_group,charset_dir,charset_name:PAnsiChar;
    ssl_key,ssl_cert,ssl_ca,ssl_capath,ssl_cipher,shared_memory_base_name:PAnsiChar;
    max_allowed_packet:cardinal;
    use_ssl,compress,named_pipe,use_thread_specific_memory,
    unused2,unused3,unused4:my_bool;
    methods_to_use:mysql_option;
    client_ip:PAnsiChar;
    secure_auth,report_data_truncation:my_bool;
    {
    int (*local_infile_init)(void **, const char *, void *);
    int (*local_infile_read)(void *, char *, unsigned int);
    void (*local_infile_end)(void *);
    int (*local_infile_error)(void *, char *, unsigned int);
    void *local_infile_userdata;
    }
    local_infile_init,local_infile_read,local_infile_end,
    local_infile_error,local_infile_userdata:pointer;
    extension:pointer;//Pst_mysql_options_extention;
  end;

  mysql_status=(
    MYSQL_STATUS_READY, MYSQL_STATUS_GET_RESULT, MYSQL_STATUS_USE_RESULT,
    MYSQL_STATUS_STATEMENT_GET_RESULT
  );

  mysql_protocol_type=(
    MYSQL_PROTOCOL_DEFAULT, MYSQL_PROTOCOL_TCP, MYSQL_PROTOCOL_SOCKET,
    MYSQL_PROTOCOL_PIPE, MYSQL_PROTOCOL_MEMORY
  );

  MY_CHARSET_INFO=record
    number,state:cardinal;
    csname,name,comment,dir:PAnsiChar;
    mbminlen,mbmaxlen:cardinal;
  end;
  PMY_CHARSET_INFO=^MY_CHARSET_INFO;

  st_mysql_methods=record end;
  Pst_mysql_methods=^st_mysql_methods;
  st_mysql_stmt=record end;
  Pst_mysql_stmt=^st_mysql_stmt;

  MYSQL=record
    net:MYSQL_NET;
    connector_fd:PAnsiChar;
    host,user,passwd,unix_socket,server_version,host_info,info,db:PAnsiChar;
    charset:PMY_CHARSET_INFO;
    fields:PMYSQL_FIELD;
    field_alloc:MEM_ROOT;
    affected_rows,insert_id,extra_info:my_ulonglong;
    thread_id,packet_length:cardinal;
    port:cardinal;
    client_flag,server_capabilities:cardinal;
    protocol_version,
    field_count,
    server_status,
    server_language,
    warning_count:cardinal;
    options:TMYSQL_OPTIONS;
    status:mysql_status;
    free_me,reconnect:my_bool;
    scramble:array[0..20] of AnsiChar;
    unused1:my_bool;
    unused2,unused3,unused4,unused5:pointer;
    stmts:pointer;//LIST*
    methods:pointer;//st_mysql_methods *
    thd:pointer;
    unbuffered_fetch_owner:Pmy_bool;
    info_buffer:PAnsiChar;
    extension:pointer;
  end;
  PMYSQL=^MYSQL;

  MYSQL_RES=record
    row_count:my_ulonglong;
    fields:PMYSQL_FIELD;
    data:PMYSQL_DATA;
    data_cursor:PMYSQL_ROWS;
    lengths:PCardinal;
    unknown1,unknown2,unknown3,unknown4,//?
    unknown5,unknown6,unknown7,unknown8,unknown9:pointer;
    field_count,current_field:integer;
    unknown10,unknown11,unknown12:pointer;
  end;
  PMYSQL_RES=^MYSQL_RES;

  MYSQL_PARAMETERS=record
    p_max_allowed_packet,p_net_buffer_length:PCardinal;
    extension:pointer;
  end;
  PMYSQL_PARAMETERS=^MYSQL_PARAMETERS;

const
  MYSQL_WAIT_READ = 1;
  MYSQL_WAIT_WRITE = 2;
  MYSQL_WAIT_EXCEPT = 4;
  MYSQL_WAIT_TIMEOUT = 8;

function mysql_library_init(argc:cardinal;argv,groups:PPAnsiChar):cardinal; stdcall;
procedure mysql_library_end; stdcall;
function mysql_get_parameters:PMYSQL_PARAMETERS; stdcall;

function mysql_thread_init:my_bool; stdcall;
procedure mysql_thread_end; stdcall;

function mysql_num_rows(res:PMYSQL_RES):my_ulonglong; stdcall;
function mysql_num_fields(res:PMYSQL_RES):cardinal; stdcall;
function mysql_eof(res:PMYSQL_RES):my_bool; stdcall;
function mysql_fetch_field_direct(res:PMYSQL_RES;fieldnr:cardinal):PMYSQL_FIELD; stdcall;
function mysql_fetch_fields(res:PMYSQL_RES):PMYSQL_FIELD; stdcall;
function mysql_row_tell(res:PMYSQL_RES):MYSQL_ROW_OFFSET; stdcall;
function mysql_field_tell(res:PMYSQL_RES):MYSQL_FIELD_OFFSET; stdcall;

function mysql_field_count(mysql:PMYSQL):cardinal; stdcall;
function mysql_affected_rows(mysql:PMYSQL):my_ulonglong; stdcall;
function mysql_insert_id(mysql:PMYSQL):my_ulonglong; stdcall;
function mysql_errno(mysql:PMYSQL):cardinal; stdcall;
function mysql_error(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_sqlstate(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_warning_count(mysql:PMYSQL):cardinal; stdcall;
function mysql_info(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_thread_id(mysql:PMYSQL):cardinal; stdcall;
function mysql_character_set_name(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_set_character_set(mysql:PMYSQL;csname:PAnsiChar):integer; stdcall;

function mysql_init(mysql:PMYSQL):PMYSQL;  stdcall;
function mysql_ssl_set(mysql:PMYSQL;key,cert,ca,capath,cipher:PAnsiChar):my_bool; stdcall;
function mysql_get_ssl_cipher(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_change_user(mysql:PMYSQL;user,passwd,db:PAnsiChar):my_bool; stdcall;
function mysql_real_connect(mysql:PMYSQL;host,user,passwd,db:PAnsiChar;
  port:cardinal;unix_socket:PAnsiChar;clientflag:cardinal):PMYSQL; stdcall;
function mysql_select_db(mysql:PMYSQL;db:PAnsiChar):integer; stdcall;
function mysql_query(mysql:PMYSQL;q:PAnsiChar):integer; stdcall;
function mysql_send_query(mysql:PMYSQL;q:PAnsiChar;length:cardinal):integer; stdcall;
function mysql_real_query(mysql:PMYSQL;q:PAnsiChar;length:cardinal):integer; stdcall;
function mysql_store_result(mysql:PMYSQL):PMYSQL_RES; stdcall;
function mysql_use_result(mysql:PMYSQL):PMYSQL_RES; stdcall;

procedure mysql_get_character_set_info(mysql:PMYSQL;charset:PMY_CHARSET_INFO); stdcall;

procedure mysql_set_local_infile_handler(mysql:PMYSQL;{
                               int (*local_infile_init)(void **, const char *,
                            void *),
                               int (*local_infile_read)(void *, char *,
							unsigned int),
                               void (*local_infile_end)(void *),
                               int (*local_infile_error)(void *, char*,
							 unsigned int),
                               void *}a,b,c,d,e:pointer); cdecl;

procedure mysql_set_local_infile_default(mysql:PMYSQL); cdecl;

function mysql_shutdown(mysql:PMYSQL;shutdown_level:integer):integer; stdcall;
function mysql_dump_debug_info(mysql:PMYSQL):integer; stdcall;
function mysql_refresh(mysql:PMYSQL;refresh_options:cardinal):integer; stdcall;
function mysql_kill(mysql:PMYSQL;pid:cardinal):integer; stdcall;
function mysql_set_server_option(mysql:PMYSQL;option:integer):integer; stdcall;
function mysql_ping(mysql:PMYSQL):integer; stdcall;
function mysql_stat(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_get_server_info(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_get_server_name(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_get_client_info:PAnsiChar; stdcall;
function mysql_get_client_version:cardinal; stdcall;
function mysql_get_host_info(mysql:PMYSQL):PAnsiChar; stdcall;
function mysql_get_server_version(mysql:PMYSQL):cardinal; stdcall;
function mysql_get_proto_info(mysql:PMYSQL):cardinal; stdcall;
function mysql_list_dbs(mysql:PMYSQL;wild:PAnsiChar):PMYSQL_RES; stdcall;
function mysql_list_tables(mysql:PMYSQL;wild:PAnsiChar):PMYSQL_RES; stdcall;
function mysql_list_processes(mysql:PMYSQL):PMYSQL_RES; stdcall;
function mysql_options(mysql:PMYSQL;option:MYSQL_OPTION;arg:pointer):integer; stdcall;
function mysql_options4(mysql:PMYSQL;option:MYSQL_OPTION;arg1,arg2:pointer):integer; stdcall;
procedure mysql_free_result(res:PMYSQL_RES); stdcall;
procedure mysql_data_seek(res:PMYSQL_RES;offset:my_ulonglong); stdcall;
function mysql_row_seek(res:PMYSQL_RES;offset:MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET; stdcall;
function mysql_field_seek(res:PMYSQL_RES;offset:MYSQL_FIELD_OFFSET):MYSQL_FIELD_OFFSET; stdcall;
function mysql_fetch_row(res:PMYSQL_RES):MYSQL_ROW; stdcall;
function mysql_fetch_lengths(res:PMYSQL_RES):PCardinal; stdcall;
function mysql_fetch_field(res:PMYSQL_RES):PMYSQL_FIELD; stdcall;
function mysql_list_fields(mysql:PMYSQL;table,wild:PAnsiChar):PMYSQL_RES; stdcall;
function mysql_escape_string(to_,from:PAnsiChar;from_length:cardinal):cardinal; stdcall;
function mysql_hex_string(to_,from:PAnsiChar;from_length:cardinal):cardinal; stdcall;
function mysql_real_escape_string(mysql:PMYSQL;to_,from:PAnsiChar;length:cardinal):cardinal; stdcall;
procedure mysql_debug(debug:PAnsiChar); stdcall;
procedure myodbc_remove_escape(mysql:PMYSQL;name:PAnsiChar); stdcall;
function mysql_thread_safe:cardinal; stdcall;
function mysql_embedded:my_bool; stdcall;
//function mariadb_connection(mysql:PMYSQL):my_bool; stdcall;
function mysql_read_query_result(mysql:PMYSQL):my_bool; stdcall;

const
  MYSQL_STMT_INIT_DONE = 1;
  MYSQL_STMT_PREPARE_DONE = 2;
  MYSQL_STMT_EXECUTE_DONE = 3;
  MYSQL_STMT_FETCH_DONE = 4;

type
  MYSQL_BIND=record
    length:PCardinal;
    is_null:Pmy_bool;
    buffer:pointer;
    error:Pmy_bool;
    row_ptr:PAnsiChar;
    store_param_func,fetch_result,skip_result:pointer;
    {
    void (*store_param_func)(NET *net, struct st_mysql_bind *param);
    void (*fetch_result)(struct st_mysql_bind *, MYSQL_FIELD *,
                         unsigned char **row);
    void (*skip_result)(struct st_mysql_bind *, MYSQL_FIELD *,
            unsigned char **row);
    }
    buffer_length,offset,length_value:cardinal;
    param_number,pack_length:cardinal;
    buffer_type:cardinal;
    error_value,is_unsigned,long_data_used,is_null_value:my_bool;
    extension:pointer;
  end;
  PMYSQL_BIND=^MYSQL_BIND;

  MYSQL_STMT=record
    mem_root:MEM_ROOT;
    list:LIST;
    mysql:PMYSQL;
    params:PMYSQL_BIND;
    bind:PMYSQL_BIND;
    fields:PMYSQL_FIELD;
    result:MYSQL_DATA;
    data_cursor:PMYSQL_ROWS;
    read_row_func:pointer;//int(struct st_stmt:PMYSQL_STMT,unsigned char **row);
    affected_rows:my_ulonglong;
    insert_id:my_ulonglong;
    stmt_id,flags,prefetch_rows:cardinal;
    server_status,last_errno,param_count,field_count:cardinal;
    state:cardinal;
    last_error:array[0..512] of AnsiChar;
    sqlstate:array[0..5] of byte;
    send_types_to_server,bind_param_done:my_bool;
    bind_result_done:byte;
    unbuffered_fetch_cancelled,update_max_length:my_bool;
    extension:pointer;
  end;
  PMYSQL_STMT=^MYSQL_STMT;

const
  STMT_ATTR_UPDATE_MAX_LENGTH = 0;
  STMT_ATTR_CURSOR_TYPE = 1;
  STMT_ATTR_PREFETCH_ROWS = 2;

function mysql_stmt_init(mysql:PMYSQL):PMYSQL_STMT; stdcall;
function mysql_stmt_prepare(stmt:PMYSQL_STMT;query:PAnsiChar;length:cardinal):integer; stdcall;
function mysql_stmt_execute(stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_fetch(stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_fetch_column(stmt:PMYSQL_STMT;bind_arg:PMYSQL_BIND;column:integer;offset:cardinal):integer; stdcall;
function mysql_stmt_store_result(stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_param_count(stmt:PMYSQL_STMT):cardinal; stdcall;
function mysql_stmt_attr_set(stmt:PMYSQL_STMT;attr_type:cardinal;attr:pointer):my_bool; stdcall;
function mysql_stmt_attr_get(stmt:PMYSQL_STMT;attr_type:cardinal;attr:pointer):my_bool; stdcall;
function mysql_stmt_bind_param(stmt:PMYSQL_STMT;bnd:PMYSQL_BIND):my_bool; stdcall;
function mysql_stmt_bind_result(stmt:PMYSQL_STMT;bnd:PMYSQL_BIND):my_bool; stdcall;
function mysql_stmt_close(stmt:PMYSQL_STMT):my_bool; stdcall;
function mysql_stmt_reset(stmt:PMYSQL_STMT):my_bool; stdcall;
function mysql_stmt_free_result(stmt:PMYSQL_STMT):my_bool; stdcall;
function mysql_stmt_send_long_data(stmt:PMYSQL_STMT;param_number:cardinal;data:PAnsiChar;length:cardinal):my_bool; stdcall;
function mysql_stmt_result_metadata(stmt:PMYSQL_STMT):PMYSQL_RES; stdcall;
function mysql_stmt_param_metadata(stmt:PMYSQL_STMT):PMYSQL_RES; stdcall;
function mysql_stmt_errno(stmt:PMYSQL_STMT):cardinal; stdcall;
function mysql_stmt_error(stmt:PMYSQL_STMT):PAnsiChar; stdcall;
function mysql_stmt_sqlstate(stmt:PMYSQL_STMT):PAnsiChar; stdcall;
function mysql_stmt_row_seek(stmt:PMYSQL_STMT;offset:MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET; stdcall;
function mysql_stmt_row_tell(stmt:PMYSQL_STMT):MYSQL_ROW_OFFSET; stdcall;
procedure mysql_stmt_data_seek(stmt:PMYSQL_STMT;offset:my_ulonglong); stdcall;
function mysql_stmt_num_rows(stmt:PMYSQL_STMT):my_ulonglong; stdcall;
function mysql_stmt_affected_rows(stmt:PMYSQL_STMT):my_ulonglong; stdcall;
function mysql_stmt_insert_id(stmt:PMYSQL_STMT):my_ulonglong; stdcall;
function mysql_stmt_field_count(stmt:PMYSQL_STMT):cardinal; stdcall;

function mysql_commit(mysql:PMYSQL):my_bool; stdcall;
function mysql_rollback(mysql:PMYSQL):my_bool; stdcall;
function mysql_autocommit(mysql:PMYSQL;auto_mode:my_bool):my_bool; stdcall;
function mysql_more_results(mysql:PMYSQL):my_bool; stdcall;
function mysql_next_result(mysql:PMYSQL):integer; stdcall;
function mysql_stmt_next_result(stmt:PMYSQL_STMT):integer; stdcall;
procedure mysql_close_slow_part(mysql:PMYSQL); stdcall;
procedure mysql_close(sock:PMYSQL); stdcall;
function mysql_get_socket(const mysql:PMYSQL):my_socket; stdcall;
function mysql_get_timeout_value(const mysql:PMYSQL):cardinal; stdcall;
function mysql_get_timeout_value_ms(const mysql:PMYSQL):cardinal; stdcall;

//function mysql_net_read_packet(mysql:PMYSQL):cardinal; stdcall;
//function mysql_net_field_length(unsigned char **packet):cardinal; stdcall;

const
  MYSQL_NO_DATA        = 100;
  MYSQL_DATA_TRUNCATED = 101;

//  mysql_reload(mysql) mysql_refresh((mysql),REFRESH_GRANT)
{
#ifdef USE_OLD_FUNCTIONS
MYSQL *		STDCALL mysql_connect(mysql:PMYSQL, const char *host,
				      const char *user, const char *passwd); stdcall;
int		STDCALL mysql_create_db(mysql:PMYSQL, const char *DB); stdcall;
int		STDCALL mysql_drop_db(mysql:PMYSQL, const char *DB); stdcall;
}


implementation

const
  LibMySQL='libmysql.dll';

function my_thread_init; external LibMySQL;
procedure my_thread_end; external LibMySQL;
function mysql_library_init; external LibMySQL name 'mysql_server_init';
procedure mysql_library_end; external LibMySQL name 'mysql_server_end';
function mysql_get_parameters; external LibMySQL;
function mysql_thread_init; external LibMySQL;
procedure mysql_thread_end; external LibMySQL;

function mysql_num_rows; external LibMySQL;
function mysql_num_fields; external LibMySQL;
function mysql_eof; external LibMySQL;
function mysql_fetch_field_direct; external LibMySQL;
function mysql_fetch_fields; external LibMySQL;
function mysql_row_tell; external LibMySQL;
function mysql_field_tell; external LibMySQL;

function mysql_field_count; external LibMySQL;
function mysql_affected_rows; external LibMySQL;
function mysql_insert_id; external LibMySQL;
function mysql_errno; external LibMySQL;
function mysql_error; external LibMySQL;
function mysql_sqlstate; external LibMySQL;
function mysql_warning_count; external LibMySQL;
function mysql_info; external LibMySQL;
function mysql_thread_id; external LibMySQL;
function mysql_character_set_name; external LibMySQL;
function mysql_set_character_set; external LibMySQL;

function mysql_init; external LibMySQL;
function mysql_ssl_set; external LibMySQL;
function mysql_get_ssl_cipher; external LibMySQL;
function mysql_change_user; external LibMySQL;
function mysql_real_connect; external LibMySQL;
function mysql_select_db; external LibMySQL;
function mysql_query; external LibMySQL;
function mysql_send_query; external LibMySQL;
function mysql_real_query; external LibMySQL;
function mysql_store_result; external LibMySQL;
function mysql_use_result; external LibMySQL;

procedure mysql_get_character_set_info; external LibMySQL;

procedure mysql_set_local_infile_handler; external LibMySQL;

procedure mysql_set_local_infile_default; external LibMySQL;

function mysql_shutdown; external LibMySQL;
function mysql_dump_debug_info; external LibMySQL;
function mysql_refresh; external LibMySQL;
function mysql_kill; external LibMySQL;
function mysql_set_server_option; external LibMySQL;
function mysql_ping; external LibMySQL;
function mysql_stat; external LibMySQL;
function mysql_get_server_info; external LibMySQL;
function mysql_get_server_name; external LibMySQL;
function mysql_get_client_info; external LibMySQL;
function mysql_get_client_version; external LibMySQL;
function mysql_get_host_info; external LibMySQL;
function mysql_get_server_version; external LibMySQL;
function mysql_get_proto_info; external LibMySQL;
function mysql_list_dbs; external LibMySQL;
function mysql_list_tables; external LibMySQL;
function mysql_list_processes; external LibMySQL;
function mysql_options; external LibMySQL;
function mysql_options4; external LibMySQL;
procedure mysql_free_result; external LibMySQL;
procedure mysql_data_seek; external LibMySQL;
function mysql_row_seek; external LibMySQL;
function mysql_field_seek; external LibMySQL;
function mysql_fetch_row; external LibMySQL;
function mysql_fetch_lengths; external LibMySQL;
function mysql_fetch_field; external LibMySQL;
function mysql_list_fields; external LibMySQL;
function mysql_escape_string; external LibMySQL;
function mysql_hex_string; external LibMySQL;
function mysql_real_escape_string; external LibMySQL;
procedure mysql_debug; external LibMySQL;
procedure myodbc_remove_escape; external LibMySQL;
function mysql_thread_safe; external LibMySQL;
function mysql_embedded; external LibMySQL;
//function mariadb_connection; external LibMySQL;
function mysql_read_query_result; external LibMySQL;

function mysql_stmt_init; external LibMySQL;
function mysql_stmt_prepare; external LibMySQL;
function mysql_stmt_execute; external LibMySQL;
function mysql_stmt_fetch; external LibMySQL;
function mysql_stmt_fetch_column; external LibMySQL;
function mysql_stmt_store_result; external LibMySQL;
function mysql_stmt_param_count; external LibMySQL;
function mysql_stmt_attr_set; external LibMySQL;
function mysql_stmt_attr_get; external LibMySQL;
function mysql_stmt_bind_param; external LibMySQL;
function mysql_stmt_bind_result; external LibMySQL;
function mysql_stmt_close; external LibMySQL;
function mysql_stmt_reset; external LibMySQL;
function mysql_stmt_free_result; external LibMySQL;
function mysql_stmt_send_long_data; external LibMySQL;
function mysql_stmt_result_metadata; external LibMySQL;
function mysql_stmt_param_metadata; external LibMySQL;
function mysql_stmt_errno; external LibMySQL;
function mysql_stmt_error; external LibMySQL;
function mysql_stmt_sqlstate; external LibMySQL;
function mysql_stmt_row_seek; external LibMySQL;
function mysql_stmt_row_tell; external LibMySQL;
procedure mysql_stmt_data_seek; external LibMySQL;
function mysql_stmt_num_rows; external LibMySQL;
function mysql_stmt_affected_rows; external LibMySQL;
function mysql_stmt_insert_id; external LibMySQL;
function mysql_stmt_field_count; external LibMySQL;

function mysql_commit; external LibMySQL;
function mysql_rollback; external LibMySQL;
function mysql_autocommit; external LibMySQL;
function mysql_more_results; external LibMySQL;
function mysql_next_result; external LibMySQL;
function mysql_stmt_next_result; external LibMySQL;
procedure mysql_close_slow_part; external LibMySQL;
procedure mysql_close; external LibMySQL;
function mysql_get_socket; external LibMySQL;
function mysql_get_timeout_value; external LibMySQL;
function mysql_get_timeout_value_ms; external LibMySQL;

//function mysql_net_read_packet; external LibMySQL;
//function mysql_net_field_length; external LibMySQL;

end.

