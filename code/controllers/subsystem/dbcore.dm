SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_BACKGROUND
	wait = 1 MINUTES
	init_order = INIT_ORDER_DBCORE
	var/const/FAILED_DB_CONNECTION_CUTOFF = 5
	var/failed_connection_timeout = 0

	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
	var/failed_connections = 0

	var/last_error
	var/list/active_queries = list()

	var/datum/BSQL_Connection/connection
	var/datum/BSQL_Operation/connectOperation

/datum/controller/subsystem/dbcore/Initialize()
	SSdbcore.Connect()
	SSdbcore.CheckSchemaVersion()
	SSdbcore.SetRoundID()
	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	return ..()

/datum/controller/subsystem/dbcore/Recover()
	connection = SSdbcore.connection
	connectOperation = SSdbcore.connectOperation

/datum/controller/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_round_shutdown = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = '[sanitizeSQL(SSticker.end_state)]' WHERE id = [GLOB.round_id]")
		query_round_shutdown.Execute()
		qdel(query_round_shutdown)
	if(SSdbcore.Connect())
		rustg_sql_disconnect_pool()
//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	return var_name != NAMEOF(src, connection) && var_name != NAMEOF(src, active_queries) && var_name != NAMEOF(src, connectOperation) && ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, connection) || var_name == NAMEOF(src, connectOperation))
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE
	if(SSdbcore.IsConnected())
		return TRUE
	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)
	var/list/connection_result = json_decode(rustg_sql_connect_pool(address, port, user, pass, db, "", "", ""))
	if(connection_result)
		var/connection_status = connection_result["status"]
		world.log << "Database Connection Status: [connection_status]"
		if(connection_status == "ok")
			return TRUE
		else
			message_admins("WARNING! Database connection failed! Status: [connection_status]")
			log_sql("WARNING! Database connection failed! Status: [connection_status]")
			return FALSE

/datum/controller/subsystem/dbcore/proc/IsConnected()
	var/list/connection_results = json_decode(rustg_sql_connected())
	switch(connection_results["status"])
		if("online")
			return TRUE
		if("offline")
			return FALSE
		if("err")
			var/error_data = connection_results["data"]
			message_admins("SQL error occured in IsConnected! Error: [error_data]")
			log_sql("SQL error occured in IsConnected! Error: [error_data]")
			return FALSE

#warn "REMOVE THIS SHIT BEFORE SHIPPING I SWEAR TO GOD"
/datum/controller/subsystem/dbcore/proc/TestArbitraryDBCallDebugging(query, parameters = "{}")
	world.log << "RUNNING QUERY [query]"
	var/query_results = rustg_sql_query_blocking(query, parameters)
	world.log << query_results
	world.log << "QUERY OVER"

/datum/controller/subsystem/dbcore/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			log_world("Database connection established.")
			var/datum/DBQuery/query_db_version = NewQuery("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1", "{}")
			query_db_version.Execute()
			UNTIL(!query_db_version.in_progress)
			db_major = text2num(query_db_version.item[1])
			db_minor = text2num(query_db_version.item[2])
			if(db_major != DB_MAJOR_VERSION || db_minor != DB_MINOR_VERSION)
				schema_mismatch = 1 // flag admin message about mismatch
				log_sql("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
			qdel(query_db_version)
		else
			log_sql("Your server failed to establish a connection with the database.")
	else
		log_sql("Database is not enabled in configuration.")

/datum/controller/subsystem/dbcore/proc/SetRoundID()
	if(!SSdbcore.IsConnected())
		return
	var/datum/DBQuery/query_round_initialize = SSdbcore.NewQuery("INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
	query_round_initialize.Execute(async = FALSE)
	qdel(query_round_initialize)
	var/datum/DBQuery/query_round_last_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
	query_round_last_id.Execute(async = FALSE)
	if(query_round_last_id.NextRow(async = FALSE))
		GLOB.round_id = query_round_last_id.item[1]
	qdel(query_round_last_id)

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(!SSdbcore.IsConnected())
		return
	var/datum/DBQuery/query_round_start = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = [GLOB.round_id]")
	query_round_start.Execute()
	qdel(query_round_start)

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(!SSdbcore.IsConnected())
		return
	var/sql_station_name = sanitizeSQL(station_name())
	var/datum/DBQuery/query_round_end = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = '[sanitizeSQL(SSticker.mode_result)]', station_name = '[sql_station_name]' WHERE id = [GLOB.round_id]")
	query_round_end.Execute()
	qdel(query_round_end)

/datum/controller/subsystem/dbcore/proc/Disconnect()
	rustg_sql_disconnect_pool()

/datum/controller/subsystem/dbcore/proc/Quote(str)
	if(connection)
		return connection.Quote(str)

/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	if(!CONFIG_GET(flag/sql_enabled))
		return "Database disabled by configuration"
	return last_error

/datum/controller/subsystem/dbcore/proc/ReportError(error)
	last_error = error

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query, sql_parameters)
	if(!Connect())
		world.log << "TRIED TO DO DB QUERIES WITH THE DATABASE TURNED OFF"
		return FALSE
	/*if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Parameters: [sql_parameters]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Parameters: [sql_parameters]. Query has been blocked")
		return FALSE*/
	return new /datum/DBQuery(sql_query, sql_parameters)

/datum/controller/subsystem/dbcore/proc/QuerySelect(list/querys, warn = FALSE, qdel = FALSE)
	if (!islist(querys))
		if (!istype(querys, /datum/DBQuery))
			CRASH("Invalid query passed to QuerySelect: [querys]")
		querys = list(querys)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		if (warn)
			INVOKE_ASYNC(query, /datum/DBQuery.proc/warn_execute)
		else
			INVOKE_ASYNC(query, /datum/DBQuery.proc/Execute)

	for (var/thing in querys)
		var/datum/DBQuery/query = thing
		UNTIL(!query.in_progress)
		if (qdel)
			qdel(query)



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
/datum/controller/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = TRUE)
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
		. = Query.warn_execute(async)
	else
		. = Query.Execute(async)
	qdel(Query)

/datum/DBQuery
	var/sql // The sql query being executed.
	var/parameters
	var/in_progress
	var/query_results
	var/list/item
	var/last_error

/datum/DBQuery/New(sql_query, sql_parameters = "{}")
	SSdbcore.active_queries[src] = TRUE
	sql = sql_query
	parameters = sql_parameters

/datum/DBQuery/Destroy()
	SSdbcore.active_queries -= src
	return ..()

/datum/DBQuery/CanProcCall(proc_name)
	//fuck off kevinz
	return FALSE

/datum/DBQuery/proc/SetQuery(new_sql, new_parameters)
	if(in_progress)
		CRASH("Attempted to set new sql while waiting on active query")
	sql = new_sql
	parameters = new_parameters

/datum/DBQuery/proc/warn_execute(async = TRUE)
	. = Execute(async)
	if(!.)
		to_chat(usr, "<span class='danger'>A SQL error occurred during this operation, check the server logs.</span>")

/datum/DBQuery/proc/Execute(async = TRUE, log_error = TRUE)
	if(in_progress)
		CRASH("Attempted to start a new query while waiting on the old one.")

	log_sql("Executing query [sql] with parameters [parameters] at [REALTIMEOFDAY]. Is async: [async]")
	run_query(async)
	log_sql("Finished executing query [sql] with parameters [parameters] at [REALTIMEOFDAY]. Is async: [async]")

/datum/DBQuery/proc/run_query(async)
	world.log << sql
	world.log << parameters
	in_progress = TRUE
	if(async)
		query_results = rustg_sql_query_async(sql, parameters)
		var/done = 0
		while(!done)
			var/x = rustg_sql_check_query(query_results)
			switch(x)
				if(RUSTG_JOB_NO_RESULTS_YET)
					sleep(5)
					continue
				if(RUSTG_JOB_NO_SUCH_JOB)
					world.log << "wtf job [query_results] not made?"
					break
				if(RUSTG_JOB_ERROR)
					world.log << "job [query_results] errored?"
				else
					world.log << "QUERY FINISHED, RESULT: [x]"
					var/list/results = json_decode(x)
					if(results["status"] == "err")
						var/error_d = results["data"]
						log_sql("SQL Error Occured! Query was [sql], parameters were [parameters]. Error: [error_d]")
						message_admins("SQL Error Occured! Query was [sql], parameters were [parameters]. Error: [error_d]")
					query_results = x
					done = 1
					break
	else
		query_results = rustg_sql_query_blocking(sql, parameters)
	in_progress = FALSE

/datum/DBQuery/proc/slow_query_check()
	message_admins("HEY! A database query timed out. Did the server just hang? <a href='?_src_=holder;[HrefToken()];slowquery=yes'>\[YES\]</a>|<a href='?_src_=holder;[HrefToken()];slowquery=no'>\[NO\]</a>")

/datum/DBQuery/proc/NextRow(async = TRUE)
	return // todo: replace this

/datum/DBQuery/proc/IsFinished()
	return rustg_sql_check_query(query_results) != RUSTG_JOB_NO_RESULTS_YET