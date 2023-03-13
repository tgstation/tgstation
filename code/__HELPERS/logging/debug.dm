/// Logging for loading and caching assets
/proc/log_asset(text)
	logger.Log(LOG_CATEGORY_DEBUG_ASSET, text)

/// Logging for config errors
/// Rarely gets called; just here in case the config breaks.
/proc/log_config(text)
	logger.Log(LOG_CATEGORY_CONFIG, text)
	SEND_TEXT(world.log, text)

/proc/log_filter_raw(text)
	logger.Log(LOG_CATEGORY_FILTER, text)

/// Logging for job slot changes
/proc/log_job_debug(text)
	logger.Log(LOG_CATEGORY_DEBUG_JOB, text)

/// Logging for lua scripting
/proc/log_lua(text)
	logger.Log(LOG_CATEGORY_DEBUG_LUA, text)

/// Logging for mapping errors
/proc/log_mapping(text, skip_world_log)
#ifdef UNIT_TESTS
	GLOB.unit_test_mapping_logs += text
#endif
	logger.Log(LOG_CATEGORY_DEBUG_MAPPING, text)
	if(skip_world_log)
		return
	SEND_TEXT(world.log, text)

/// Logging for game performance
/proc/log_perf(list/perf_info)
	. = "[perf_info.Join(",")]\n"
	WRITE_LOG_NO_FORMAT(GLOB.perf_log, .)

/// Logging for hard deletes
/proc/log_qdel(text)
	logger.Log(LOG_CATEGORY_DEBUG_QDEL, text)

/* Log to the logfile only. */
/proc/log_runtime(text)
	logger.Log(LOG_CATEGORY_DEBUG_RUNTIME, text)
	WRITE_LOG(GLOB.world_runtime_log, text)

/proc/log_signal(text)
	logger.Log(LOG_CATEGORY_SIGNAL, text)

/// Logging for DB errors
/proc/log_sql(text)
	logger.Log(LOG_CATEGORY_DEBUG_SQL, text)

/// Logging for world/Topic
/proc/log_topic(text)
	logger.Log(LOG_CATEGORY_GAME_TOPIC, text)

/// Log to both DD and the logfile.
/proc/log_world(text)
#ifdef USE_CUSTOM_ERROR_HANDLER
	logger.Log(LOG_CATEGORY_DEBUG_RUNTIME, text)
#endif
	SEND_TEXT(world.log, text)
