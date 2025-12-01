/// Logging for loading and caching assets
/proc/log_asset(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_ASSET, text, data)

/// Logging for config errors
/// Rarely gets called; just here in case the config breaks.
/proc/log_config(text, list/data)
	logger.Log(LOG_CATEGORY_CONFIG, text, data)
	SEND_TEXT(world.log, text)

/proc/log_filter_raw(text, list/data)
	logger.Log(LOG_CATEGORY_FILTER, text, data)

/// Logging for job slot changes
/proc/log_job_debug(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_JOB, text, data)

/// Logging for TTS
/proc/log_tts(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_TTS, text, data)

/// Logging for lua scripting
/proc/log_lua(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_LUA, text, data)

/// Logging for mapping errors
/proc/log_mapping(text, skip_world_log)
#ifdef UNIT_TESTS
	GLOB.unit_test_mapping_logs += text
#endif
#ifdef MAP_TEST
	message_admins("Mapping: [text]")
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
/proc/log_qdel(text, list/data)
	logger.Log(LOG_CATEGORY_QDEL, text, data)

/* Log to the logfile only. */
/proc/log_runtime(text, list/data)
	logger.Log(LOG_CATEGORY_RUNTIME, text, data)

/proc/log_signal(text, list/data)
	logger.Log(LOG_CATEGORY_SIGNAL, text, data)

/// Logging for DB errors
/proc/log_sql(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_SQL, text, data)

/// Logging for world/Topic
/proc/log_topic(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_TOPIC, text, data)

/// Log to both DD and the logfile.
/proc/log_world(text, list/data)
#ifdef USE_CUSTOM_ERROR_HANDLER
	logger.Log(LOG_CATEGORY_RUNTIME, text, data)
#endif
	SEND_TEXT(world.log, text)
