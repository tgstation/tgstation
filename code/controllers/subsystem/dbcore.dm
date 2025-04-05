#define SHUTDOWN_QUERY_TIMELIMIT (1 MINUTES)
SUBSYSTEM_DEF(dbcore)
	name = "Database"
	flags = SS_TICKER
	wait = 10 // Not seconds because we're running on SS_TICKER
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	init_order = INIT_ORDER_DBCORE
	priority = FIRE_PRIORITY_DATABASE

	var/schema_mismatch = 0
	var/db_minor = 0
	var/db_major = 0
	/// Number of failed connection attempts this try. Resets after the timeout or successful connection
	var/failed_connections = 0
	/// Max number of consecutive failures before a timeout (here and not a define so it can be vv'ed mid round if needed)
	var/max_connection_failures = 5
	/// world.time that connection attempts can resume
	var/failed_connection_timeout = 0
	/// Total number of times connections have had to be timed out.
	var/failed_connection_timeout_count = 0

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
	/// Queries pending execution, mapped to complete arguments
	var/list/datum/db_query/queries_standby = list()

	/// We are in the process of shutting down and should not allow more DB connections
	var/shutting_down = FALSE


	var/connection  // Arbitrary handle returned from rust_g.

	var/db_daemon_started = FALSE

/datum/controller/subsystem/dbcore/Initialize()
	//We send warnings to the admins during subsystem init, as the clients will be New'd and messages
	//will queue properly with goonchat
	switch(schema_mismatch)
		if(1)
			message_admins("Database schema ([db_major].[db_minor]) doesn't match the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version from database")

	return SS_INIT_SUCCESS

/datum/controller/subsystem/dbcore/OnConfigLoad()
	. = ..()
	var/datum/config_entry/min_config_datum = config.entries_by_type[/datum/config_entry/number/pooling_min_sql_connections]
	var/datum/config_entry/max_config_datum = config.entries_by_type[/datum/config_entry/number/pooling_max_sql_connections]

	var/min_sql_connections = min_config_datum.config_entry_value
	var/max_sql_connections = max_config_datum.config_entry_value

	if (max_sql_connections < min_sql_connections)
		if (min_config_datum.modified && max_config_datum.modified)
			log_config("ERROR: POOLING_MAX_SQL_CONNECTIONS ([max_sql_connections]) is set lower than POOLING_MIN_SQL_CONNECTIONS ([min_sql_connections]), the values will be swapped.")

			CONFIG_SET(number/pooling_min_sql_connections, min_sql_connections)
			CONFIG_SET(number/pooling_max_sql_connections, max_sql_connections)

		else if (min_config_datum.modified)
			log_config("ERROR: POOLING_MIN_SQL_CONNECTIONS ([min_sql_connections]) is set higher than POOLING_MAX_SQL_CONNECTIONS's default ([max_sql_connections]), POOLING_MAX_SQL_CONNECTIONS will be updated to match.")

			CONFIG_SET(number/pooling_max_sql_connections, min_sql_connections)

		else //the defaults are wrong?!?!?!
			stack_trace("The config defaults for sql database pooling don't make sense.")
			CONFIG_SET(number/pooling_min_sql_connections, min(min_sql_connections, max_sql_connections))
			CONFIG_SET(number/pooling_max_sql_connections,  max(min_sql_connections, max_sql_connections))
			log_config("ERROR: POOLING_MAX_SQL_CONNECTIONS ([max_sql_connections]) is set lower than POOLING_MIN_SQL_CONNECTIONS ([min_sql_connections]). Please check your config or the code defaults for sanity")

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
		if(!length(queries_active) && !length(queries_standby) && !length(all_queries))
			processing_queries = null
			return
		processing_queries = all_queries.Copy()

	// First handle the already running queries
	for (var/datum/db_query/query in queries_active)
		if(!process_query(query))
			queries_active -= query

	// Now lets pull in standby queries if we have room.
	if (length(queries_standby) > 0 && length(queries_active) < max_concurrent_queries)
		var/list/queries_to_activate = queries_standby.Copy(1, min(length(queries_standby), max_concurrent_queries) + 1)

		for (var/datum/db_query/query in queries_to_activate)
			queries_standby.Remove(query)
			create_active_query(query)

	// And finally, let check queries for undeleted queries, check ticking if there is a lot of work to do.
	while(length(processing_queries))
		var/datum/db_query/query = popleft(processing_queries)
		if(world.time - query.last_activity_time > (5 MINUTES))
			stack_trace("Found undeleted query, check the sql.log for the undeleted query and add a delete call to the query datum.")
			log_sql("Undeleted query: \"[query.sql]\" LA: [query.last_activity] LAT: [query.last_activity_time]")
			qdel(query)
		if(MC_TICK_CHECK)
			return


/// Helper proc for handling activating queued queries
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
	if(query.process((TICKS2DS(wait)) / 10))
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

	if (!length(queries_standby) && length(queries_active) < max_concurrent_queries)
		create_active_query(query)
		return

	queries_standby_num++
	queries_standby |= query

/datum/controller/subsystem/dbcore/Recover()
	connection = SSdbcore.connection

/datum/controller/subsystem/dbcore/Shutdown()
	shutting_down = TRUE
	var/msg = "Clearing DB queries standby:[length(queries_standby)] active: [length(queries_active)] all: [length(all_queries)]"
	to_chat(world, span_boldannounce(msg))
	log_world(msg)
	//This is as close as we can get to the true round end before Disconnect() without changing where it's called, defeating the reason this is a subsystem
	var/endtime = REALTIMEOFDAY + SHUTDOWN_QUERY_TIMELIMIT
	if(SSdbcore.Connect())
		//Take over control of all active queries
		var/queries_to_check = queries_active.Copy()
		queries_active.Cut()

		//Start all waiting queries
		for(var/datum/db_query/query in queries_standby)
			run_query(query)
			queries_to_check += query
			queries_standby -= query

		//wait for them all to finish
		for(var/datum/db_query/query in queries_to_check)
			UNTIL(query.process() || REALTIMEOFDAY > endtime)

		//log shutdown to the db
		var/datum/db_query/query_round_shutdown = SSdbcore.NewQuery(
			"UPDATE [format_table_name("round")] SET shutdown_datetime = Now(), end_state = :end_state WHERE id = :round_id",
			list("end_state" = SSticker.end_state, "round_id" = GLOB.round_id),
			TRUE
		)
		query_round_shutdown.Execute(FALSE)
		qdel(query_round_shutdown)

	msg = "Done clearing DB queries standby:[length(queries_standby)] active: [length(queries_active)] all: [length(all_queries)]"
	to_chat(world, span_boldannounce(msg))
	log_world(msg)
	if(IsConnected())
		Disconnect()
	stop_db_daemon()

//nu
/datum/controller/subsystem/dbcore/can_vv_get(var_name)
	if(var_name == NAMEOF(src, connection))
		return FALSE
	if(var_name == NAMEOF(src, all_queries))
		return FALSE
	if(var_name == NAMEOF(src, queries_active))
		return FALSE
	if(var_name == NAMEOF(src, queries_standby))
		return FALSE
	if(var_name == NAMEOF(src, processing_queries))
		return FALSE

	return ..()

/datum/controller/subsystem/dbcore/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, connection))
		return FALSE
	if(var_name == NAMEOF(src, all_queries))
		return FALSE
	if(var_name == NAMEOF(src, queries_active))
		return FALSE
	if(var_name == NAMEOF(src, queries_standby))
		return FALSE
	if(var_name == NAMEOF(src, processing_queries))
		return FALSE
	return ..()

/datum/controller/subsystem/dbcore/proc/Connect()
	if(IsConnected())
		return TRUE

	if(connection)
		Disconnect() //clear the current connection handle so isconnected() calls stop invoking rustg
		connection = null //make sure its cleared even if runtimes happened

	if(failed_connection_timeout <= world.time) //it's been long enough since we failed to connect, reset the counter
		failed_connections = 0
		failed_connection_timeout = 0

	if(failed_connection_timeout > 0)
		return FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return FALSE

	start_db_daemon()

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)
	var/timeout = max(CONFIG_GET(number/async_query_timeout), CONFIG_GET(number/blocking_query_timeout))
	var/min_sql_connections = CONFIG_GET(number/pooling_min_sql_connections)
	var/max_sql_connections = CONFIG_GET(number/pooling_max_sql_connections)

	var/result = json_decode(rustg_sql_connect_pool(json_encode(list(
		"host" = address,
		"port" = port,
		"user" = user,
		"pass" = pass,
		"db_name" = db,
		"read_timeout" = timeout,
		"write_timeout" = timeout,
		"min_threads" = min_sql_connections,
		"max_threads" = max_sql_connections,
	))))
	. = (result["status"] == "ok")
	if (.)
		connection = result["handle"]
	else
		connection = null
		last_error = result["data"]
		log_sql("Connect() failed | [last_error]")
		++failed_connections
		//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect for a time.
		if(failed_connections > max_connection_failures)
			failed_connection_timeout_count++
			//basic exponential backoff algorithm
			failed_connection_timeout = world.time + ((2 ** failed_connection_timeout_count) SECONDS)

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

/datum/controller/subsystem/dbcore/proc/InitializeRound()
	CheckSchemaVersion()

	if(!Connect())
		return
	var/datum/db_query/query_round_initialize = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("round")] (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(:internet_address), :port)",
		list("internet_address" = world.internet_address || "0", "port" = "[world.port]")
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
		list("game_mode_result" = SSticker.mode_result, "station_name" = station_name(), "round_id" = GLOB.round_id)
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

/datum/controller/subsystem/dbcore/proc/NewQuery(sql_query, arguments, allow_during_shutdown=FALSE)
	//If the subsystem is shutting down, disallow new queries
	if(!allow_during_shutdown && shutting_down)
		CRASH("Attempting to create a new db query during the world shutdown")

	if(IsAdminAdvancedProcCall())
		log_admin_private("ERROR: Advanced admin proc call led to sql query: [sql_query]. Query has been blocked")
		message_admins("ERROR: Advanced admin proc call led to sql query. Query has been blocked")
		return FALSE
	return new /datum/db_query(connection, sql_query, arguments)

/**
 * Creates and executes a query without waiting for or tracking the results.
 * Query is executed asynchronously (without blocking) and deleted afterwards - any results or errors are discarded.
 *
 * Arguments:
 * * sql_query - The SQL query string to execute
 * * arguments - List of arguments to pass to the query for parameter binding
 * * allow_during_shutdown - If TRUE, allows query to be created during subsystem shutdown. Generally, only cleanup queries should set this.
 */
/datum/controller/subsystem/dbcore/proc/FireAndForget(sql_query, arguments, allow_during_shutdown = FALSE)
	var/datum/db_query/query = NewQuery(sql_query, arguments, allow_during_shutdown)
	if(!query)
		return
	ASYNC
		query.Execute()
		qdel(query)

/** QuerySelect
	Run a list of query datums in parallel, blocking until they all complete.
	* queries - List of queries or single query datum to run.
	* warn - Controls rather warn_execute() or Execute() is called.
	* qdel - If you don't care about the result or checking for errors, you can have the queries be deleted afterwards.
		This can be combined with invoke_async as a way of running queries async without having to care about waiting for them to finish so they can be deleted,
		however you should probably just use FireAndForget instead if it's just a single query.
*/
/datum/controller/subsystem/dbcore/proc/QuerySelect(list/queries, warn = FALSE, qdel = FALSE)
	if (!islist(queries))
		if (!istype(queries, /datum/db_query))
			CRASH("Invalid query passed to QuerySelect: [queries]")
		queries = list(queries)
	else
		queries = queries.Copy() //we don't want to hide bugs in the parent caller by removing invalid values from this list.

	for (var/datum/db_query/query as anything in queries)
		if (!istype(query))
			queries -= query
			stack_trace("Invalid query passed to QuerySelect: `[query]` [REF(query)]")
			continue

		if (warn)
			INVOKE_ASYNC(query, TYPE_PROC_REF(/datum/db_query, warn_execute))
		else
			INVOKE_ASYNC(query, TYPE_PROC_REF(/datum/db_query, Execute))

	for (var/datum/db_query/query as anything in queries)
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
*/
/datum/controller/subsystem/dbcore/proc/MassInsert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, warn = FALSE, async = TRUE, special_columns = null)
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

/datum/controller/subsystem/dbcore/proc/start_db_daemon()
	set waitfor = FALSE

	if (db_daemon_started)
		return

	db_daemon_started = TRUE

	var/daemon = CONFIG_GET(string/db_daemon)
	if (!daemon)
		return

	ASSERT(fexists(daemon), "Configured db_daemon doesn't exist")

	var/list/result = world.shelleo("echo \"Starting ezdb daemon, do not close this window\" && [daemon]")
	var/result_code = result[1]
	if (!result_code || result_code == 1)
		return

	stack_trace("Failed to start DB daemon: [result_code]\n[result[3]]")

/datum/controller/subsystem/dbcore/proc/stop_db_daemon()
	set waitfor = FALSE

	if (!db_daemon_started)
		return

	db_daemon_started = FALSE

	var/daemon = CONFIG_GET(string/db_daemon)
	if (!daemon)
		return

	switch (world.system_type)
		if (MS_WINDOWS)
			var/list/result = world.shelleo("Get-Process | ? { $_.Path -eq '[daemon]' } | Stop-Process")
			ASSERT(result[1], "Failed to stop DB daemon: [result[3]]")
		if (UNIX)
			var/list/result = world.shelleo("kill $(pgrep -f '[daemon]')")
			ASSERT(result[1], "Failed to stop DB daemon: [result[3]]")

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
		if(!MC_RUNNING(SSdbcore.init_stage))
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
		logger.Log(LOG_CATEGORY_DEBUG_SQL, "sql query failed", list(
			"query" = sql,
			"arguments" = json_encode(arguments),
			"error" = last_error,
		))

	if(!async && timed_out)
		logger.Log(LOG_CATEGORY_DEBUG_SQL, "slow query timeout", list(
			"query" = sql,
			"start_time" = start_time,
			"end_time" = REALTIMEOFDAY,
		))
		slow_query_check()

/// Sleeps until execution of the query has finished.
/datum/db_query/proc/sync()
	while(status < DB_QUERY_FINISHED)
		stoplag()

/datum/db_query/process(seconds_per_tick)
	if(status >= DB_QUERY_FINISHED)
		return TRUE // we are done processing after all

	status = DB_QUERY_STARTED
	var/job_result = rustg_sql_check_query(job_id)
	if(job_result == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE //no results yet

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
	message_admins("HEY! A database query timed out. Did the server just hang? <a href='byond://?_src_=holder;[HrefToken()];slowquery=yes'>\[YES\]</a>|<a href='byond://?_src_=holder;[HrefToken()];slowquery=no'>\[NO\]</a>")

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
#undef SHUTDOWN_QUERY_TIMELIMIT
