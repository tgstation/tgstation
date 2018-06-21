SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_BACKGROUND
	wait = 1 MINUTES
	init_order = INIT_ORDER_DBCORE
	var/const/FAILED_DB_CONNECTION_CUTOFF = 5

	var/const/Default_Cursor = 0
	var/const/Client_Cursor = 1
	var/const/Server_Cursor = 2
	//conversions
	var/const/TEXT_CONV = 1
	var/const/RSC_FILE_CONV = 2
	var/const/NUMBER_CONV = 3
	//column flag values:
	var/const/IS_NUMERIC = 1
	var/const/IS_BINARY = 2
	var/const/IS_NOT_NULL = 4
	var/const/IS_PRIMARY_KEY = 8
	var/const/IS_UNSIGNED = 16
	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
// TODO: Investigate more recent type additions and see if I can handle them. - Nadrew

	var/_db_con// This variable contains a reference to the actual database connection.
	var/failed_connections = 0

	var/list/active_queries = list()

/datum/controller/subsystem/dbcore/PreInit()
	if(!_db_con)
		_db_con = _dm_db_new_con()

/datum/controller/subsystem/dbcore/Initialize()
	//We send warnings to the admins during subsystem init, as the clients will be New'd and messages
	//will queue properly with goonchat
	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	return ..()

/datum/controller/subsystem/dbcore/fire()
	for(var/I in active_queries)
		var/datum/DBQuery/Q = I
		if(world.time - Q.last_activity_time > (5 MINUTES))
			message_admins("Found undeleted query, please check the server logs and notify coders.")
			log_sql("Undeleted query: \"[Q.sql]\" LA: [Q.last_activity] LAT: [Q.last_activity_time]")
			qdel(Q)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/dbcore/Recover()
	_db_con = SSdbcore._db_con

/datum/controller/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_round_shutdown = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = '[sanitizeSQL(SSticker.end_state)]' WHERE id = [GLOB.round_id]")
		query_round_shutdown.Execute()
		qdel(query_round_shutdown)
	if(IsConnected())
		Disconnect()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	return var_name != NAMEOF(src, _db_con) && var_name != NAMEOF(src, active_queries) && ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == "_db_con")
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)

	_dm_db_connect(_db_con, "dbi:mysql:[db]:[address]:[port]", user, pass, Default_Cursor, null)
	. = IsConnected()
	if (!.)
		log_sql("Connect() failed | [ErrorMsg()]")
		++failed_connections

/datum/controller/subsystem/dbcore/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(SSdbcore.Connect())
			log_world("Database connection established.")
			var/datum/DBQuery/query_db_version = SSdbcore.NewQuery("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1")
			query_db_version.Execute()
			if(query_db_version.NextRow())
				db_major = text2num(query_db_version.item[1])
				db_minor = text2num(query_db_version.item[2])
				if(db_major != DB_MAJOR_VERSION || db_minor != DB_MINOR_VERSION)
					schema_mismatch = 1 // flag admin message about mismatch
					log_sql("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
			else
				schema_mismatch = 2 //flag admin message about no schema version
				log_sql("Could not get schema version from database")
			qdel(query_db_version)
		else
			log_sql("Your server failed to establish a connection with the database.")
	else
		log_sql("Database is not enabled in configuration.")

/datum/controller/subsystem/dbcore/proc/SetRoundID()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_initialize = SSdbcore.NewQuery("INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
	query_round_initialize.Execute()
	qdel(query_round_initialize)
	var/datum/DBQuery/query_round_last_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
	query_round_last_id.Execute()
	if(query_round_last_id.NextRow())
		GLOB.round_id = query_round_last_id.item[1]
	qdel(query_round_last_id)

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(!Connect())
		return
	var/datum/DBQuery/query_round_start = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = [GLOB.round_id]")
	query_round_start.Execute()
	qdel(query_round_start)

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	var/sql_station_name = sanitizeSQL(station_name())
	var/datum/DBQuery/query_round_end = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = '[sanitizeSQL(SSticker.mode_result)]', station_name = '[sql_station_name]' WHERE id = [GLOB.round_id]")
	query_round_end.Execute()
	qdel(query_round_end)

/datum/controller/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	return _dm_db_close(_db_con)

/datum/controller/subsystem/dbcore/proc/IsConnected()
	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE
	return _dm_db_is_connected(_db_con)

/datum/controller/subsystem/dbcore/proc/Quote(str)
	return _dm_db_quote(_db_con, str)

/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	if(!CONFIG_GET(flag/sql_enabled))
		return "Database disabled by configuration"
	return _dm_db_error_msg(_db_con)

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query, cursor_handler = Default_Cursor)
	if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Query has been blocked")
		return FALSE
	return new /datum/DBQuery(sql_query, src, cursor_handler)

/*
Takes a list of rows (each row being an associated list of column => value) and inserts them via a single mass query.
Rows missing columns present in other rows will resolve to SQL NULL
You are expected to do your own escaping of the data, and expected to provide your own quotes for strings.
The duplicate_key arg can be true to automatically generate this part of the query
	or set to a string that is appended to the end of the query
Ignore_errors instructes mysql to continue inserting rows if some of them have errors.
	 the erroneous row(s) aren't inserted and there isn't really any way to know why or why errored
Delayed insert mode was removed in mysql 7 and only works with MyISAM type tables,
	It was included because it is still supported in mariadb.
	It does not work with duplicate_key and the mysql server ignores it in those cases
*/
/datum/controller/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE)
	if (!table || !rows || !istype(rows))
		return
	var/list/columns = list()
	var/list/sorted_rows = list()

	for (var/list/row in rows)
		var/list/sorted_row = list()
		sorted_row.len = columns.len
		for (var/column in row)
			var/idx = columns[column]
			if (!idx)
				idx = columns.len + 1
				columns[column] = idx
				sorted_row.len = columns.len

			sorted_row[idx] = row[column]
		sorted_rows[++sorted_rows.len] = sorted_row

	if (duplicate_key == TRUE)
		var/list/column_list = list()
		for (var/column in columns)
			column_list += "[column] = VALUES([column])"
		duplicate_key = "ON DUPLICATE KEY UPDATE [column_list.Join(", ")]\n"
	else if (duplicate_key == FALSE)
		duplicate_key = null

	if (ignore_errors)
		ignore_errors = " IGNORE"
	else
		ignore_errors = null

	if (delayed)
		delayed = " DELAYED"
	else
		delayed = null

	var/list/sqlrowlist = list()
	var/len = columns.len
	for (var/list/row in sorted_rows)
		if (length(row) != len)
			row.len = len
		for (var/value in row)
			if (value == null)
				value = "NULL"
		sqlrowlist += "([row.Join(", ")])"

	sqlrowlist = "	[sqlrowlist.Join(",\n	")]"
	var/datum/DBQuery/Query = NewQuery("INSERT[delayed][ignore_errors] INTO [table]\n([columns.Join(", ")])\nVALUES\n[sqlrowlist]\n[duplicate_key]")
	if (warn)
		. = Query.warn_execute()
	else
		. = Query.Execute()
	qdel(Query)


/datum/DBQuery
	var/sql // The sql query being executed.
	var/default_cursor
	var/list/columns //list of DB Columns populated by Columns()
	var/list/conversions
	var/list/item  //list of data values populated by NextRow()
	var/last_activity
	var/last_activity_time
	var/datum/controller/subsystem/dbcore/db_connection
	var/_db_query

/datum/DBQuery/New(sql_query, datum/controller/subsystem/dbcore/connection_handler, cursor_handler)
	SSdbcore.active_queries[src] = TRUE
	Activity("Created")
	if(sql_query)
		sql = sql_query
	if(connection_handler)
		db_connection = connection_handler
	if(cursor_handler)
		default_cursor = cursor_handler
	item = list()
	_db_query = _dm_db_new_query()

/datum/DBQuery/Destroy()
	Close()
	SSdbcore.active_queries -= src
	return ..()

/datum/DBQuery/CanProcCall(proc_name)
	//fuck off kevinz
	return FALSE

/datum/DBQuery/proc/Activity(activity)
	last_activity = activity
	last_activity_time = world.time

/datum/DBQuery/proc/warn_execute()
	. = Execute()
	if(!.)
		to_chat(usr, "<span class='danger'>A SQL error occurred during this operation, check the server logs.</span>")

/datum/DBQuery/proc/SetQuery(new_sql)
	Activity("SetQuery")
	Close()
	sql = new_sql

/datum/DBQuery/proc/Execute(sql_query = sql, cursor_handler = default_cursor, log_error = TRUE)
	Activity("Execute")
	var/start_time
	var/timeout = CONFIG_GET(number/query_debug_log_timeout)
	if(timeout)
		start_time = REALTIMEOFDAY
	Close()
	. = _dm_db_execute(_db_query, sql_query, db_connection._db_con, cursor_handler, null)
	if(!. && log_error)
		log_sql("[ErrorMsg()] | Query used: [sql]")
	if(timeout)
		if((REALTIMEOFDAY - start_time) > timeout)
			log_query_debug("Query execution started at [start_time]")
			log_query_debug("Query execution ended at [REALTIMEOFDAY]")
			log_query_debug("Possible slow query timeout detected.")
			log_query_debug("Query used: [sql]")
			slow_query_check()

/datum/DBQuery/proc/slow_query_check()
	message_admins("HEY! A database query may have timed out. Did the server just hang? <a href='?_src_=holder;[HrefToken()];slowquery=yes'>\[YES\]</a>|<a href='?_src_=holder;[HrefToken()];slowquery=no'>\[NO\]</a>")

/datum/DBQuery/proc/NextRow()
	Activity("NextRow")
	return _dm_db_next_row(_db_query,item,conversions)

/datum/DBQuery/proc/RowsAffected()
	return _dm_db_rows_affected(_db_query)

/datum/DBQuery/proc/RowCount()
	return _dm_db_row_count(_db_query)

/datum/DBQuery/proc/ErrorMsg()
	return _dm_db_error_msg(_db_query)

/datum/DBQuery/proc/Columns()
	if(!columns)
		columns = _dm_db_columns(_db_query, /datum/DBColumn)
	return columns

/datum/DBQuery/proc/GetRowData()
	var/list/columns = Columns()
	var/list/results
	if(columns.len)
		results = list()
		for(var/C in columns)
			results+=C
			var/datum/DBColumn/cur_col = columns[C]
			results[C] = src.item[(cur_col.position+1)]
	return results

/datum/DBQuery/proc/Close()
	item.Cut()
	columns = null
	conversions = null
	return _dm_db_close(_db_query)

/datum/DBQuery/proc/Quote(str)
	return db_connection.Quote(str)

/datum/DBQuery/proc/SetConversion(column,conversion)
	if(istext(column))
		column = columns.Find(column)
	if(!conversions)
		conversions = new /list(column)
	else if(conversions.len < column)
		conversions.len = column
	conversions[column] = conversion


/datum/DBColumn
	var/name
	var/table
	var/position //1-based index into item data
	var/sql_type
	var/flags
	var/length
	var/max_length
	//types
	var/const/TINYINT = 1
	var/const/SMALLINT = 2
	var/const/MEDIUMINT = 3
	var/const/INTEGER = 4
	var/const/BIGINT = 5
	var/const/DECIMAL = 6
	var/const/FLOAT = 7
	var/const/DOUBLE = 8
	var/const/DATE = 9
	var/const/DATETIME = 10
	var/const/TIMESTAMP = 11
	var/const/TIME = 12
	var/const/STRING = 13
	var/const/BLOB = 14

/datum/DBColumn/New(name_handler, table_handler, position_handler, type_handler, flag_handler, length_handler, max_length_handler)
	name = name_handler
	table = table_handler
	position = position_handler
	sql_type = type_handler
	flags = flag_handler
	length = length_handler
	max_length = max_length_handler

/datum/DBColumn/proc/SqlTypeName(type_handler = sql_type)
	switch(type_handler)
		if(TINYINT)
			return "TINYINT"
		if(SMALLINT)
			return "SMALLINT"
		if(MEDIUMINT)
			return "MEDIUMINT"
		if(INTEGER)
			return "INTEGER"
		if(BIGINT)
			return "BIGINT"
		if(FLOAT)
			return "FLOAT"
		if(DOUBLE)
			return "DOUBLE"
		if(DATE)
			return "DATE"
		if(DATETIME)
			return "DATETIME"
		if(TIMESTAMP)
			return "TIMESTAMP"
		if(TIME)
			return "TIME"
		if(STRING)
			return "STRING"
		if(BLOB)
			return "BLOB"
