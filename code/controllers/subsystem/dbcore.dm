SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_TICKER
	wait = 10 // Not seconds because we're running on SS_TICKER
	runlevels = RUNLEVEL_INIT|RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	init_order = INIT_ORDER_DBCORE
	priority = FIRE_PRIORITY_DATABASE

	var/failed_connection_timeout = 0

	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
	var/failed_connections = 0

	var/last_error

	var/max_concurrent_queries = 25

	/// Number of all queries, reset to 0 when logged in SStime_track. Used by SStime_track
	var/all_queries_num = 0
	/// Number of active queries, reset to 0 when logged in SStime_track. Used by SStime_track
	var/queries_active_num = 0
	/// Number of standby queries, reset to 0 when logged in SStime_track. Used by SStime_track
	var/queries_standby_num = 0

	/// All the current queries that exist.
	var/list/all_queries = list()
	/// Queries being checked for timeouts.
	var/list/processing_queries

	/// Queries currently being handled by database driver
	var/list/datum/db_query/queries_active = list()
	/// Queries pending execution that will be handled this controller firing
	var/list/datum/db_query/queries_new
	/// Queries pending execution, mapped to complete arguments
	var/list/datum/db_query/queries_standby = list()
	/// Queries left to handle during controller firing
	var/list/datum/db_query/queries_current

	var/connection  // Arbitrary handle returned from rust_g.

/datum/controller/subsystem/dbcore/Initialize()
	//We send warnings to the admins during subsystem init, as the clients will be New'd and messages
	//will queue properly with goonchat
	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	return ..()

/datum/controller/subsystem/dbcore/stat_entry(msg)
	msg = "P:[length(all_queries)]|Active:[length(queries_active)]|Standby:[length(queries_standby)]"
	return ..()

/// Resets the tracking numbers on the subsystem. Used by SStime_track.
/datum/controller/subsystem/dbcore/proc/reset_tracking()
	all_queries_num = 0
	queries_active_num = 0
	queries_standby_num = 0

/datum/controller/subsystem/dbcore/fire(resumed = FALSE)
	if(!IsConnected())
		return

	if(!resumed)
		queries_new = null
		if(!length(queries_active) && !length(queries_standby) && !length(all_queries))
			processing_queries = null
			queries_current = null
			return
		queries_current = queries_active.Copy()
		processing_queries = all_queries.Copy()

	for(var/I in processing_queries)
		var/datum/db_query/Q = I
		if(world.time - Q.last_activity_time > (5 MINUTES))
			message_admins("Found undeleted query, please check the server logs and notify coders.")
			log_sql("Undeleted query: \"[Q.sql]\" LA: [Q.last_activity] LAT: [Q.last_activity_time]")
			qdel(Q)
		if(MC_TICK_CHECK)
			return

	// First handle the already running queries
	while(length(queries_current))
		var/datum/db_query/query = popleft(queries_current)
		if(!process_query(query))
			queries_active -= query
		if(MC_TICK_CHECK)
			return

	// Then strap on extra new queries as possible
	if(isnull(queries_new))
		if(!length(queries_standby))
			return
		queries_new = queries_standby.Copy(1, min(length(queries_standby), max_concurrent_queries) + 1)

	while(length(queries_new) && length(queries_active) < max_concurrent_queries)
		var/datum/db_query/query = popleft(queries_new)
		queries_standby.Remove(query)
		create_active_query(query)
		if(MC_TICK_CHECK)
			return

/// Helper proc for handling queued new queries
/datum/controller/subsystem/dbcore/proc/create_active_query(datum/db_query/query)
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	if(IsAdminAdvancedProcCall())
		return FALSE
	run_query(query)
	queries_active_num++
	queries_active += query
	return query

/datum/controller/subsystem/dbcore/proc/process_query(datum/db_query/query)
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	if(IsAdminAdvancedProcCall())
		return FALSE
	if(QDELETED(query))
		return FALSE
	if(query.process(wait))
		queries_active -= query
		return FALSE
	return TRUE

/datum/controller/subsystem/dbcore/proc/run_query_sync(datum/db_query/query)
	if(IsAdminAdvancedProcCall())
		return
	run_query(query)
	UNTIL(query.process())
	return query

/datum/controller/subsystem/dbcore/proc/run_query(datum/db_query/query)
	if(IsAdminAdvancedProcCall())
		return
	query.job_id = rustg_sql_query_async(connection, query.sql, json_encode(query.arguments))

/datum/controller/subsystem/dbcore/proc/queue_query(datum/db_query/query)
	if(IsAdminAdvancedProcCall())
		return
	queries_standby_num++
	queries_standby |= query

/datum/controller/subsystem/dbcore/Recover()
	connection = SSdbcore.connection

/datum/controller/subsystem/dbcore/Shutdown()
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	if(SSdbcore.Connect())
		for(var/datum/db_query/query in queries_current)
			run_query(query)

		var/datum/db_query/query_round_shutdown = SSdbcore.NewQuery(
			"UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = :end_state WHERE id = :round_id",
			list("end_state" = SSticker.end_state, "round_id" = GLOB.round_id)
		)
		query_round_shutdown.Execute()
		qdel(query_round_shutdown)
	if(IsConnected())
		Disconnect()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	if(var_name == NAMEOF(src, connection))
		return FALSE
	if(var_name == NAMEOF(src, all_queries))
		return FALSE
	if(var_name == NAMEOF(src, queries_active))
		return FALSE
	if(var_name == NAMEOF(src, queries_new))
		return FALSE
	if(var_name == NAMEOF(src, queries_standby))
		return FALSE
	if(var_name == NAMEOF(src, queries_active))
		return FALSE

	return ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, connection))
		return FALSE
	if(var_name == NAMEOF(src, all_queries))
		return FALSE
	if(var_name == NAMEOF(src, queries_active))
		return FALSE
	if(var_name == NAMEOF(src, queries_new))
		return FALSE
	if(var_name == NAMEOF(src, queries_standby))
		return FALSE
	if(var_name == NAMEOF(src, queries_active))
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(failed_connection_timeout <= world.time) //it's been more than 5 seconds since we failed to connect, reset the counter
		failed_connections = 0

	if(failed_connections > 5) //If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect for 5 seconds.
		failed_connection_timeout = world.time + 50
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)
	var/timeout = max(CONFIG_GET(number/async_query_timeout), CONFIG_GET(number/blocking_query_timeout))
	var/thread_limit = CONFIG_GET(number/bsql_thread_limit)

	max_concurrent_queries = CONFIG_GET(number/max_concurrent_queries)

	var/result = json_decode(rustg_sql_connect_pool(json_encode(list(
		"host" = address,
		"port" = port,
		"user" = user,
		"pass" = pass,
		"db_name" = db,
		"read_timeout" = timeout,
		"write_timeout" = timeout,
		"max_threads" = thread_limit,
	))))
	. = (result["status"] == "ok")
	if (.)
		connection = result["handle"]
	else
		connection = null
		last_error = result["data"]
		log_sql("Connect() failed | [last_error]")
		++failed_connections

/datum/controller/subsystem/dbcore/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(Connect())
			log_world("Database connection established.")
			var/datum/db_query/query_db_version = NewQuery("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1")
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
	var/datum/db_query/query_round_initialize = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port, commit_hash) VALUES (Now(), INET_ATON(:internet_address), :port, :commit_hash)",
		list("internet_address" = world.internet_address || "0", "port" = "[world.port]", "commit_hash" = GLOB.revdata.originmastercommit)
	)
	query_round_initialize.Execute(async = FALSE)
	GLOB.round_id = "[query_round_initialize.last_insert_id]"
	qdel(query_round_initialize)

/datum/controller/subsystem/dbcore/proc/SetRoundStart()
	if(!Connect())
		return
	var/datum/db_query/query_round_start = SSdbcore.NewQuery(
		"UPDATE [format_table_name("round")] SET start_datetime = Now() WHERE id = :round_id",
		list("round_id" = GLOB.round_id)
	)
	query_round_start.Execute()
	qdel(query_round_start)

/datum/controller/subsystem/dbcore/proc/SetRoundEnd()
	if(!Connect())
		return
	var/datum/db_query/query_round_end = SSdbcore.NewQuery(
		"UPDATE [format_table_name("round")] SET end_datetime = Now(), game_mode_result = :game_mode_result, station_name = :station_name WHERE id = :round_id",
		list("game_mode_result" = SSdynamic.get_round_result(), "station_name" = station_name(), "round_id" = GLOB.round_id)
	)
	query_round_end.Execute()
	qdel(query_round_end)

/datum/controller/subsystem/dbcore/proc/Disconnect()
	failed_connections = 0
	if (connection)
		rustg_sql_disconnect_pool(connection)
	connection = null

/datum/controller/subsystem/dbcore/proc/IsConnected()
	if (!CONFIG_GET(flag/sql_enabled))
		return FALSE
	if (!connection)
		return FALSE
	return json_decode(rustg_sql_connected(connection))["status"] == "online"

/datum/controller/subsystem/dbcore/proc/ErrorMsg()
	if(!CONFIG_GET(flag/sql_enabled))
		return "Database disabled by configuration"
	return last_error

/datum/controller/subsystem/dbcore/proc/ReportError(error)
	last_error = error

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query, arguments)
	if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Query has been blocked")
		return FALSE
	return new /datum/db_query(connection, sql_query, arguments)

/datum/controller/subsystem/dbcore/proc/QuerySelect(list/querys, warn = FALSE, qdel = FALSE)
	if (!islist(querys))
		if (!istype(querys, /datum/db_query))
			CRASH("Invalid query passed to QuerySelect: [querys]")
		querys = list(querys)

	for (var/thing in querys)
		var/datum/db_query/query = thing
		if (warn)
			INVOKE_ASYNC(query, /datum/db_query.proc/warn_execute)
		else
			INVOKE_ASYNC(query, /datum/db_query.proc/Execute)

	for (var/thing in querys)
		var/datum/db_query/query = thing
		query.sync()
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
/datum/controller/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, delayed = FALSE, warn = FALSE, async = TRUE, special_columns = null)
	if (!table || !rows || !istype(rows))
		return

	// Prepare column list
	var/list/columns = list()
	var/list/has_question_mark = list()
	for (var/list/row in rows)
		for (var/column in row)
			columns[column] = "?"
			has_question_mark[column] = TRUE
	for (var/column in special_columns)
		columns[column] = special_columns[column]
		has_question_mark[column] = findtext(special_columns[column], "?")

	// Prepare SQL query full of placeholders
	var/list/query_parts = list("INSERT")
	if (delayed)
		query_parts += " DELAYED"
	if (ignore_errors)
		query_parts += " IGNORE"
	query_parts += " INTO "
	query_parts += table
	query_parts += "\n([columns.Join(", ")])\nVALUES"

	var/list/arguments = list()
	var/has_row = FALSE
	for (var/list/row in rows)
		if (has_row)
			query_parts += ","
		query_parts += "\n  ("
		var/has_col = FALSE
		for (var/column in columns)
			if (has_col)
				query_parts += ", "
			if (has_question_mark[column])
				var/name = "p[arguments.len]"
				query_parts += replacetext(columns[column], "?", ":[name]")
				arguments[name] = row[column]
			else
				query_parts += columns[column]
			has_col = TRUE
		query_parts += ")"
		has_row = TRUE

	if (duplicate_key == TRUE)
		var/list/column_list = list()
		for (var/column in columns)
			column_list += "[column] = VALUES([column])"
		query_parts += "\nON DUPLICATE KEY UPDATE [column_list.Join(", ")]"
	else if (duplicate_key != FALSE)
		query_parts += duplicate_key

	var/datum/db_query/Query = NewQuery(query_parts.Join(), arguments)
	if (warn)
		. = Query.warn_execute(async)
	else
		. = Query.Execute(async)
	qdel(Query)

/datum/db_query
	// Inputs
	var/connection
	var/sql
	var/arguments

	var/datum/callback/success_callback
	var/datum/callback/fail_callback

	// Status information
	/// Current status of the query.
	var/status
	/// Job ID of the query passed by rustg.
	var/job_id
	var/last_error
	var/last_activity
	var/last_activity_time

	// Output
	var/list/list/rows
	var/next_row_to_take = 1
	var/affected
	var/last_insert_id

	var/list/item  //list of data values populated by NextRow()

/datum/db_query/New(connection, sql, arguments)
	SSdbcore.all_queries += src
	SSdbcore.all_queries_num++
	Activity("Created")
	item = list()

	src.connection = connection
	src.sql = sql
	src.arguments = arguments

/datum/db_query/Destroy()
	Close()
	SSdbcore.all_queries -= src
	SSdbcore.queries_standby -= src
	SSdbcore.queries_active -= src
	return ..()

/datum/db_query/CanProcCall(proc_name)
	//fuck off kevinz
	return FALSE

/datum/db_query/proc/Activity(activity)
	last_activity = activity
	last_activity_time = world.time

/datum/db_query/proc/warn_execute(async = TRUE)
	. = Execute(async)
	if(!.)
		to_chat(usr, span_danger("A SQL error occurred during this operation, check the server logs."))

/datum/db_query/proc/Execute(async = TRUE, log_error = TRUE)
	Activity("Execute")
	if(status == DB_QUERY_STARTED)
		CRASH("Attempted to start a new query while waiting on the old one")

	if(!SSdbcore.IsConnected())
		last_error = "No connection!"
		return FALSE

	var/start_time
	if(!async)
		start_time = REALTIMEOFDAY
	Close()
	status = DB_QUERY_STARTED
	if(async)
		if(!Master.current_runlevel || Master.processing == 0)
			SSdbcore.run_query_sync(src)
		else
			SSdbcore.queue_query(src)
		sync()
	else
		var/job_result_str = rustg_sql_query_blocking(connection, sql, json_encode(arguments))
		store_data(json_decode(job_result_str))

	. = (status != DB_QUERY_BROKEN)
	var/timed_out = !. && findtext(last_error, "Operation timed out")
	if(!. && log_error)
		log_sql("[last_error] | Query used: [sql] | Arguments: [json_encode(arguments)]")
	if(!async && timed_out)
		log_query_debug("Query execution started at [start_time]")
		log_query_debug("Query execution ended at [REALTIMEOFDAY]")
		log_query_debug("Slow query timeout detected.")
		log_query_debug("Query used: [sql]")
		slow_query_check()

/// Sleeps until execution of the query has finished.
/datum/db_query/proc/sync()
	while(status < DB_QUERY_FINISHED)
		stoplag()

/datum/db_query/process(delta_time)
	if(status >= DB_QUERY_FINISHED)
		return

	status = DB_QUERY_STARTED
	var/job_result = rustg_sql_check_query(job_id)
	if(job_result == RUSTG_JOB_NO_RESULTS_YET)
		return

	store_data(json_decode(job_result))
	return TRUE

/datum/db_query/proc/store_data(result)
	switch(result["status"])
		if("ok")
			rows = result["rows"]
			affected = result["affected"]
			last_insert_id = result["last_insert_id"]
			status = DB_QUERY_FINISHED
			return
		if("err")
			last_error = result["data"]
			status = DB_QUERY_BROKEN
			return
		if("offline")
			last_error = "CONNECTION OFFLINE"
			status = DB_QUERY_BROKEN
			return


/datum/db_query/proc/slow_query_check()
	message_admins("HEY! A database query timed out. Did the server just hang? <a href='?_src_=holder;[HrefToken()];slowquery=yes'>\[YES\]</a>|<a href='?_src_=holder;[HrefToken()];slowquery=no'>\[NO\]</a>")

/datum/db_query/proc/NextRow(async = TRUE)
	Activity("NextRow")

	if (rows && next_row_to_take <= rows.len)
		item = rows[next_row_to_take]
		next_row_to_take++
		return !!item
	else
		return FALSE

/datum/db_query/proc/ErrorMsg()
	return last_error

/datum/db_query/proc/Close()
	rows = null
	item = null
