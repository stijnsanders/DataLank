unit LibMyAsync;
{

  LibMyAsync: libmysql.dll wrapper for MariaDB/MySQL, start/cont functions

  https://github.com/stijnsanders/DataLank

  based on MariaDB 10.1.14
  include/mysql/mysql.ini

}

interface

uses LibMy;

function mysql_set_character_set_start(var ret:integer;mysql:PMYSQL;csname:PAnsiChar):integer; stdcall;
function mysql_set_character_set_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_change_user_start(var ret:my_bool;mysql:PMYSQL;user,passwd,db:PAnsiChar):integer; stdcall;
function mysql_change_user_cont(var ret:my_bool;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_real_connect_start(var ret:PMYSQL;mysql:PMYSQL;
  host,user,passwd,db:PAnsiChar;port:cardinal;unix_socket:PAnsiChar;clientflag:cardinal):integer; stdcall;
function mysql_real_connect_cont(var ret:PMYSQL;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_select_db_start(var ret:integer;mysql:MYSQL;db:PAnsiChar):integer; stdcall;
function mysql_select_db_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_query_start(var ret:integer;mysql:PMYSQL;q:PAnsiChar):integer; stdcall;
function mysql_query_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_send_query_start(var ret:integer;mysql:PMYSQL;q:PAnsiChar;length:cardinal):integer; stdcall;
function mysql_send_query_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_real_query_start(var ret:integer;mysql:PMYSQL;q:PAnsiChar;length:cardinal):integer; stdcall;
function mysql_real_query_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_store_result_start(var ret:PMYSQL_RES;mysql:PMYSQL):integer; stdcall;
function mysql_store_result_cont(var ret:PMYSQL_RES;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_shutdown_start(var ret:integer;mysql:PMYSQL;shutdown_level:integer):integer; stdcall;
function mysql_shutdown_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_dump_debug_info_start(var ret:integer;mysql:PMYSQL): integer; stdcall;
function mysql_dump_debug_info_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_refresh_start(var ret:integer;mysql:PMYSQL;refresh_options:cardinal):integer; stdcall;
function mysql_refresh_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_kill_start(var ret:integer;mysql:PMYSQL;pid:cardinal):integer; stdcall;
function mysql_kill_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_set_server_option_start(var ret:integer;mysql:PMYSQL;option:integer):integer; stdcall;
function mysql_set_server_option_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_ping_start(var ret:integer;mysql:PMYSQL):integer; stdcall;
function mysql_ping_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_stat_start(var ret:PAnsiChar;mysql:PMYSQL):integer; stdcall;
function mysql_stat_cont(var ret:PAnsiChar;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_list_dbs_start(var ret:PMYSQL_RES;mysql:PMYSQL;wild:PAnsiChar):integer; stdcall;
function mysql_list_dbs_cont(var ret:PMYSQL_RES;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_list_tables_start(var ret:PMYSQL_RES;mysql:PMYSQL;wild:PAnsiChar):integer; stdcall;
function mysql_list_tables_cont(var ret:PMYSQL_RES;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_list_processes_start(var ret:PMYSQL_RES;mysql:PMYSQL):integer; stdcall;
function mysql_list_processes_cont(var ret:PMYSQL_RES;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_free_result_start(var res:MYSQL_RES):integer; stdcall;
function mysql_free_result_cont(var res:MYSQL_RES;status:integer):integer; stdcall;
function mysql_fetch_row_start(var ret:MYSQL_ROW;res:PMYSQL_RES):integer; stdcall;
function mysql_fetch_row_cont(var ret:MYSQL_ROW;res:PMYSQL_RES;status:integer):integer; stdcall;
function mysql_list_fields_start(var ret:PMYSQL_RES;mysql:PMYSQL;table,wild:PAnsiChar):integer; stdcall;
function mysql_list_fields_cont(var ret:PMYSQL_RES;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_read_query_result_start(var ret:my_bool;mysql:PMYSQL):integer; stdcall;
function mysql_read_query_result_cont(var ret:my_bool;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_stmt_prepare_start(var ret:integer;stmt:PMYSQL_STMT;query:PAnsiChar;length:cardinal):integer; stdcall;
function mysql_stmt_prepare_cont(var ret:integer;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_execute_start(var ret:integer;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_execute_cont(var ret:integer;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_fetch_start(var ret:integer;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_fetch_cont(var ret:integer;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_store_result_start(var ret:integer;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_store_result_cont(var ret:integer;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_close_start(var ret:my_bool;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_close_cont(var ret:my_bool;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_reset_start(var ret:my_bool;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_reset_cont(var ret:my_bool;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_free_result_start(var ret:my_bool;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_free_result_cont(var ret:my_bool;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_stmt_send_long_data_start(var ret:my_bool;stmt:PMYSQL_STMT;param_number:cardinal;data:PAnsiChar;len:cardinal):integer; stdcall;
function mysql_stmt_send_long_data_cont(var ret:my_bool;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_commit_start(var ret:my_bool;mysql:PMYSQL):integer; stdcall;
function mysql_commit_cont(var ret:my_bool;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_rollback_start(var ret:my_bool;mysql:PMYSQL):integer; stdcall;
function mysql_rollback_cont(var ret:my_bool;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_autocommit_start(var ret:my_bool;mysql:PMYSQL;auto_mode:my_bool):integer; stdcall;
function mysql_autocommit_cont(var ret:my_bool;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_next_result_start(var ret:integer;mysql:PMYSQL):integer; stdcall;
function mysql_next_result_cont(var ret:integer;mysql:PMYSQL;status:integer):integer; stdcall;
function mysql_stmt_next_result_start(var ret:integer;stmt:PMYSQL_STMT):integer; stdcall;
function mysql_stmt_next_result_cont(var ret:integer;stmt:PMYSQL_STMT;status:integer):integer; stdcall;
function mysql_close_start(var sock:MYSQL):integer; stdcall;
function mysql_close_cont(var sock:MYSQL;status:integer):integer; stdcall;

implementation

const
  LibMySQL='libmysql.dll';

function mysql_set_character_set_start; external LibMySQL;
function mysql_set_character_set_cont; external LibMySQL;
function mysql_change_user_start; external LibMySQL;
function mysql_change_user_cont; external LibMySQL;
function mysql_real_connect_start; external LibMySQL;
function mysql_real_connect_cont; external LibMySQL;
function mysql_select_db_start; external LibMySQL;
function mysql_select_db_cont; external LibMySQL;
function mysql_query_start; external LibMySQL;
function mysql_query_cont; external LibMySQL;
function mysql_send_query_start; external LibMySQL;
function mysql_send_query_cont; external LibMySQL;
function mysql_real_query_start; external LibMySQL;
function mysql_real_query_cont; external LibMySQL;
function mysql_store_result_start; external LibMySQL;
function mysql_store_result_cont; external LibMySQL;
function mysql_shutdown_start; external LibMySQL;
function mysql_shutdown_cont; external LibMySQL;
function mysql_dump_debug_info_start; external LibMySQL;
function mysql_dump_debug_info_cont; external LibMySQL;
function mysql_refresh_start; external LibMySQL;
function mysql_refresh_cont; external LibMySQL;
function mysql_kill_start; external LibMySQL;
function mysql_kill_cont; external LibMySQL;
function mysql_set_server_option_start; external LibMySQL;
function mysql_set_server_option_cont; external LibMySQL;
function mysql_ping_start; external LibMySQL;
function mysql_ping_cont; external LibMySQL;
function mysql_stat_start; external LibMySQL;
function mysql_stat_cont; external LibMySQL;
function mysql_list_dbs_start; external LibMySQL;
function mysql_list_dbs_cont; external LibMySQL;
function mysql_list_tables_start; external LibMySQL;
function mysql_list_tables_cont; external LibMySQL;
function mysql_list_processes_start; external LibMySQL;
function mysql_list_processes_cont; external LibMySQL;
function mysql_free_result_start; external LibMySQL;
function mysql_free_result_cont; external LibMySQL;
function mysql_fetch_row_start; external LibMySQL;
function mysql_fetch_row_cont; external LibMySQL;
function mysql_list_fields_start; external LibMySQL;
function mysql_list_fields_cont; external LibMySQL;
function mysql_read_query_result_start; external LibMySQL;
function mysql_read_query_result_cont; external LibMySQL;
function mysql_stmt_prepare_start; external LibMySQL;
function mysql_stmt_prepare_cont; external LibMySQL;
function mysql_stmt_execute_start; external LibMySQL;
function mysql_stmt_execute_cont; external LibMySQL;
function mysql_stmt_fetch_start; external LibMySQL;
function mysql_stmt_fetch_cont; external LibMySQL;
function mysql_stmt_store_result_start; external LibMySQL;
function mysql_stmt_store_result_cont; external LibMySQL;
function mysql_stmt_close_start; external LibMySQL;
function mysql_stmt_close_cont; external LibMySQL;
function mysql_stmt_reset_start; external LibMySQL;
function mysql_stmt_reset_cont; external LibMySQL;
function mysql_stmt_free_result_start; external LibMySQL;
function mysql_stmt_free_result_cont; external LibMySQL;
function mysql_stmt_send_long_data_start; external LibMySQL;
function mysql_stmt_send_long_data_cont; external LibMySQL;
function mysql_commit_start; external LibMySQL;
function mysql_commit_cont; external LibMySQL;
function mysql_rollback_start; external LibMySQL;
function mysql_rollback_cont; external LibMySQL;
function mysql_autocommit_start; external LibMySQL;
function mysql_autocommit_cont; external LibMySQL;
function mysql_next_result_start; external LibMySQL;
function mysql_next_result_cont; external LibMySQL;
function mysql_stmt_next_result_start; external LibMySQL;
function mysql_stmt_next_result_cont; external LibMySQL;
function mysql_close_start; external LibMySQL;
function mysql_close_cont; external LibMySQL;

end.
