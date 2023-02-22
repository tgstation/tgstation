/// Logging for loading and caching assets
/proc/log_asset(text)
	Logger.Log(LOG_CATEGORY_ASSET, text)

/// Logging for config errors
/// Rarely gets called; just here in case the config breaks.
/proc/log_config(text)
	WRITE_LOG(GLOB.config_error_log, text)
	SEND_TEXT(world.log, text)

/proc/log_filter_raw(text)
	WRITE_LOG(GLOB.filter_log, "FILTER: [text]")

/// Logging for job slot changes
/proc/log_job_debug(text)
	Logger.Log(LOG_CATEGORY_JOB_DEBUG, text)

/// Logging for lua scripting
/proc/log_lua(text)
	WRITE_LOG(GLOB.lua_log, text)

/// Logging for mapping errors
/proc/log_mapping(text, skip_world_log)
#ifdef UNIT_TESTS
	GLOB.unit_test_mapping_logs += text
#endif
	Logger.Log(LOG_CATEGORY_MAP_ERRORS, text)
	if(skip_world_log)
		return
	SEND_TEXT(world.log, text)

/// Logging for game performance
/proc/log_perf(list/perf_info)
	. = "[perf_info.Join(",")]\n"
	WRITE_LOG_NO_FORMAT(GLOB.perf_log, .)

/// Logging for hard deletes
/proc/log_qdel(text)
	Logger.Log(LOG_CATEGORY_QDEL, text)

/// Logging for SQL errors
/proc/log_query_debug(text)
	Logger.Log(LOG_CATEGORY_QUERY_DEBUG, text)

/* Log to the logfile only. */
/proc/log_runtime(text)
	Logger.Log(LOG_CATEGORY_RUNTIME, text)

/proc/log_signal(text)
	WRITE_LOG(GLOB.signals_log, text)

/// Logging for DB errors
/proc/log_sql(text)
	WRITE_LOG(GLOB.sql_error_log, "SQL: [text]")

/// Logging for world/Topic
/proc/log_topic(text)
	Logger.Log(LOG_CATEGORY_GAME_TOPIC, text)

/// Log to both DD and the logfile.
/proc/log_world(text)
#ifdef USE_CUSTOM_ERROR_HANDLER
	Logger.Log(LOG_CATEGORY_RUNTIME, text)
#endif
	SEND_TEXT(world.log, text)
