#define FAILED_DB_CONNECTION_CUTOFF 5

//cursors
#define Default_Cursor	0
#define Client_Cursor	1
#define Server_Cursor	2
//conversions
#define TEXT_CONV		1
#define RSC_FILE_CONV	2
#define NUMBER_CONV		3
//column flag values:
#define IS_NUMERIC		1
#define IS_BINARY		2
#define IS_NOT_NULL		4
#define IS_PRIMARY_KEY	8
#define IS_UNSIGNED		16
//types
#define TINYINT		1
#define SMALLINT	2
#define MEDIUMINT	3
#define INTEGER		4
#define BIGINT		5
#define DECIMAL		6
#define FLOAT		7
#define DOUBLE		8
#define DATE		9
#define DATETIME	10
#define TIMESTAMP	11
#define TIME		12
#define STRING		13
#define BLOB		14
// TODO: Investigate more recent type additions and see if I can handle them. - Nadrew


// Deprecated! See global.dm for new configuration vars
/*
var/DB_SERVER = "" // This is the location of your MySQL server (localhost is USUALLY fine)
var/DB_PORT = 3306 // This is the port your MySQL server is running on (3306 is the default)
*/

DBConnection
	var/_db_con // This variable contains a reference to the actual database connection.
	var/dbi // This variable is a string containing the DBI MySQL requires.
	var/user // This variable contains the username data.
	var/password // This variable contains the password data.
	var/default_cursor // This contains the default database cursor data.
		//
	var/server = ""
	var/port = 3306
	var/failed_connections = 0

DBConnection/New(dbi_handler,username,password_handler,cursor_handler)
	src.dbi = dbi_handler
	src.user = username
	src.password = password_handler
	src.default_cursor = cursor_handler
	_db_con = _dm_db_new_con()

DBConnection/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return FALSE

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	doConnect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = IsConnected()
	if (!. && config.sql_enabled)
		log_world("SQL error: " + ErrorMsg())
		++failed_connections

DBConnection/proc/doConnect(dbi_handler=src.dbi,user_handler=src.user,password_handler=src.password,cursor_handler)
	if(!config.sql_enabled)
		return 0
	if(!src) return 0
	cursor_handler = src.default_cursor
	if(!cursor_handler) cursor_handler = Default_Cursor
	return _dm_db_connect(_db_con,dbi_handler,user_handler,password_handler,cursor_handler,null)

DBConnection/proc/Disconnect()
	failed_connections = 0
	return _dm_db_close(_db_con)

DBConnection/proc/IsConnected()
	if(!config.sql_enabled) return 0
	var/success = _dm_db_is_connected(_db_con)
	return success

DBConnection/proc/Quote(str) return _dm_db_quote(_db_con,str)

DBConnection/proc/ErrorMsg() return _dm_db_error_msg(_db_con)
DBConnection/proc/SelectDB(database_name,dbi)
	if(IsConnected()) Disconnect()
	//return Connect("[dbi?"[dbi]":"dbi:mysql:[database_name]:[DB_SERVER]:[DB_PORT]"]",user,password)
	return Connect("[dbi?"[dbi]":"dbi:mysql:[database_name]:[sqladdress]:[sqlport]"]",user,password)
DBConnection/proc/NewQuery(sql_query,cursor_handler=src.default_cursor) return new/DBQuery(sql_query,src,cursor_handler)


DBQuery/New(sql_query,DBConnection/connection_handler,cursor_handler)
	if(sql_query) src.sql = sql_query
	if(connection_handler) src.db_connection = connection_handler
	if(cursor_handler) src.default_cursor = cursor_handler
	_db_query = _dm_db_new_query()
	return ..()


DBQuery
	var/sql // The sql query being executed.
	var/default_cursor
	var/list/columns //list of DB Columns populated by Columns()
	var/list/conversions
	var/list/item[0]  //list of data values populated by NextRow()

	var/DBConnection/db_connection
	var/_db_query

DBQuery/proc/Connect(DBConnection/connection_handler) src.db_connection = connection_handler

DBQuery/proc/Execute(sql_query=src.sql,cursor_handler=default_cursor)
	Close()
	return _dm_db_execute(_db_query,sql_query,db_connection._db_con,cursor_handler,null)

DBQuery/proc/NextRow() return _dm_db_next_row(_db_query,item,conversions)

DBQuery/proc/RowsAffected() return _dm_db_rows_affected(_db_query)

DBQuery/proc/RowCount() return _dm_db_row_count(_db_query)

DBQuery/proc/ErrorMsg() return _dm_db_error_msg(_db_query)

DBQuery/proc/Columns()
	if(!columns)
		columns = _dm_db_columns(_db_query,/DBColumn)
	return columns

DBQuery/proc/GetRowData()
	var/list/columns = Columns()
	var/list/results
	if(columns.len)
		results = list()
		for(var/C in columns)
			results+=C
			var/DBColumn/cur_col = columns[C]
			results[C] = src.item[(cur_col.position+1)]
	return results

DBQuery/proc/Close()
	item.len = 0
	columns = null
	conversions = null
	return _dm_db_close(_db_query)

DBQuery/proc/Quote(str)
	return db_connection.Quote(str)

DBQuery/proc/SetConversion(column,conversion)
	if(istext(column)) column = columns.Find(column)
	if(!conversions) conversions = new/list(column)
	else if(conversions.len < column) conversions.len = column
	conversions[column] = conversion


DBColumn
	var/name
	var/table
	var/position //1-based index into item data
	var/sql_type
	var/flags
	var/length
	var/max_length

DBColumn/New(name_handler,table_handler,position_handler,type_handler,flag_handler,length_handler,max_length_handler)
	src.name = name_handler
	src.table = table_handler
	src.position = position_handler
	src.sql_type = type_handler
	src.flags = flag_handler
	src.length = length_handler
	src.max_length = max_length_handler
	return ..()


DBColumn/proc/SqlTypeName(type_handler=src.sql_type)
	switch(type_handler)
		if(TINYINT) return "TINYINT"
		if(SMALLINT) return "SMALLINT"
		if(MEDIUMINT) return "MEDIUMINT"
		if(INTEGER) return "INTEGER"
		if(BIGINT) return "BIGINT"
		if(FLOAT) return "FLOAT"
		if(DOUBLE) return "DOUBLE"
		if(DATE) return "DATE"
		if(DATETIME) return "DATETIME"
		if(TIMESTAMP) return "TIMESTAMP"
		if(TIME) return "TIME"
		if(STRING) return "STRING"
		if(BLOB) return "BLOB"


#undef Default_Cursor
#undef Client_Cursor
#undef Server_Cursor
#undef TEXT_CONV
#undef RSC_FILE_CONV
#undef NUMBER_CONV
#undef IS_NUMERIC
#undef IS_BINARY
#undef IS_NOT_NULL
#undef IS_PRIMARY_KEY
#undef IS_UNSIGNED
#undef TINYINT
#undef SMALLINT
#undef MEDIUMINT
#undef INTEGER
#undef BIGINT
#undef DECIMAL
#undef FLOAT
#undef DOUBLE
#undef DATE
#undef DATETIME
#undef TIMESTAMP
#undef TIME
#undef STRING
#undef BLOB


#undef FAILED_DB_CONNECTION_CUTOFF
