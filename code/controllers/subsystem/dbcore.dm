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
		var/datum/query_result/Q = I
		if(world.time - Q.last_activity_time > (5 MINUTES))
			message_admins("Found undeleted query, please check the server logs and notify coders.")
			log_sql("Undeleted query: \"[Q.sql]\" LA: [Q.last_activity] LAT: [Q.last_activity_time]")
			qdel(Q)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		SSdbcore.Query("UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = ? WHERE id = ?", list(SSticker.end_state, GLOB.round_id))
	if(IsConnected())
		Disconnect()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	return var_name != NAMEOF(src, active_queries) && ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connection_timeout <= world.time) //it's been more than 5 seconds since we failed to connect, reset the counter
		failed_connections = 0

	if(failed_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect for 5 seconds.
		failed_connection_timeout = world.time + 50
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)
	var/timeout = CONFIG_GET(number/query_timeout)
	var/min_threads = CONFIG_GET(number/min_threads)
	var/max_threads = CONFIG_GET(number/max_threads)

	var/list/connection_result = json_decode(rustg_sql_connect_pool(address, port, user, pass, db, timeout, min_threads, max_threads))
	if(!connection_result)
		failed_connections++
		return FALSE
	if(connection_result["status"] != "ok")
		failed_connections++
		if(connection_result["data"])
			log_sql("SQL connection errored: [connection_result["data"]]")
			message_admins("SQL connection errored: [connection_result["data"]]")
			CRASH(connection_result["data"])
		return FALSE
	return TRUE

/datum/controller/subsystem/dbcore/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			log_world("Database connection established.")
			var/datum/query_result/query_db_version = Query("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1")
			if(!query_db_version.error)
				db_major = text2num(query_db_version.rows[1][1])
				db_minor = text2num(query_db_version.rows[1][2])
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
	SSdbcore.Query("INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF(? LIKE '', '0', ?)), ?)", list(world.internet_address, world.internet_address, world.port), async = FALSE)
	var/datum/query_result/query_round_last_id = SSdbcore.Query("SELECT LAST_INSERT_ID()", async = FALSE)
	if(!query_round_last_id.error)
		GLOB.round_id = query_round_last_id.rows[1][1]

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(!Connect())
		return
	SSdbcore.Query("UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = ?", list(GLOB.round_id))

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	var/sql_station_name = sanitizeSQL(station_name())
	SSdbcore.Query("UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = ?, station_name = ? WHERE id = ?", list(SSticker.mode_result, station_name(), GLOB.round_id))

/datum/controller/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	var/list/disconnect_result = rustg_sql_disconnect_pool()
	if(!disconnect_result)
		return FALSE
	if(disconnect_result["status"] == "err")
		log_sql("SQL status check errored: [disconnect_result["data"]]")
		message_admins("SQL status check errored: [disconnect_result["data"]]")
	return disconnect_result["status"] == "success"

/datum/controller/subsystem/dbcore/proc/IsConnected()
	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE
	var/list/connected_result = json_decode(rustg_sql_connected())
	if(!connected_result)
		return FALSE
	if(connected_result["status"] == "err")
		log_sql("SQL status check errored: [connected_result["data"]]")
		message_admins("SQL status check errored: [connected_result["data"]]")
	return connected_result["status"] == "online"


/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	if(!CONFIG_GET(flag/sql_enabled))
		return "Database disabled by configuration"
	return last_error

/datum/controller/subsystem/dbcore/proc/ReportError(error)
	last_error = error

/datum/controller/subsystem/dbcore/proc/Query(sql_query, list/params, async = TRUE)
	if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Query has been blocked")
		return FALSE
	var/qr
	if(async)
		var/job = rustg_sql_query_async(sql_query, LAZYLEN(params) ? json_encode(params) : "")
		while(!qr)
			var/list/query = rustg_sql_check_query(job)
			if(!query)
				return FALSE
			switch(query)
				if(RUSTG_JOB_NO_SUCH_JOB)
					return FALSE
				if(RUSTG_JOB_ERROR)
					log_sql("Job [job] errored (query '[sql_query]', params [json_encode(params)])")
					message_admins("Job [job] errored (query '[sql_query]', params [json_encode(params)])")
					return FALSE
				if(RUSTG_JOB_NO_RESULTS_YET)
					stoplag()
					continue
				else
					qr = query
					break
	else
		qr = rustg_sql_query_blocking(sql_query, LAZYLEN(params) ? json_encode(params) : "")
	return new /datum/query_result(qr)

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

/datum/sql_query
	var/sql // The sql query being executed.
	var/list/item  //list of data values populated by NextRow()

	var/last_activity
	var/last_activity_time

	var/last_error
	var/skip_next_is_complete
	var/in_progress
	var/datum/BSQL_Connection/connection
	var/datum/BSQL_Operation/Query/query


/world/BSQL_Debug(message)
	if(!CONFIG_GET(flag/bsql_debug))
		return

	//strip sensitive stuff
	if(findtext(message, ": OpenConnection("))
		message = "OpenConnection CENSORED"

	log_sql("BSQL_DEBUG: [message]")

/datum/query_result
	var/affected = 0
	var/error = null
	var/list/rows = list()

/datum/query_result/New(data)
	if(!data)
		stack_trace("/datum/query_result created with null data!")
	var/list/json
	if(islist(data))
		json = data
	else
		json = json_decode(data)
		if(!json || !islist(json))
			stack_trace("/datum/query_result created with invalid JSON!")
	switch(json["status"])
		if("ok")
			affected = "affected" in json ? json["affected"] : affected
			rows = "rows" in json ? json["rows"] : rows
		if("err")
			error = json["data"]
			log_world(error) // TODO: remove this once I'm done
