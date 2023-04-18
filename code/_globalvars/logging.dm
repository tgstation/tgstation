GLOBAL_LIST_EMPTY(active_turfs_startlist)

GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)

/// The directory in which ALL log files should be stored
GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)

#define DECLARE_LOG_NAMED(log_var_name, log_file_name, start)\
GLOBAL_VAR(##log_var_name);\
GLOBAL_PROTECT(##log_var_name);\
/world/_initialize_log_files(temp_log_override = null){\
	..();\
	GLOB.##log_var_name = temp_log_override || "[GLOB.log_directory]/[##log_file_name].log";\
	if(!temp_log_override && ##start){\
		start_log(GLOB.##log_var_name);\
	}\
}

#define DECLARE_LOG(log_name, start) DECLARE_LOG_NAMED(##log_name, "[copytext(#log_name, 1, length(#log_name) - 4)]", start)

/// Populated by log declaration macros to set log file names and start messages
/world/proc/_initialize_log_files(temp_log_override = null)
	// Needs to be here to avoid compiler warnings
	SHOULD_CALL_PARENT(TRUE)
	return

// All individual log files
DECLARE_LOG(config_error_log, FALSE)
DECLARE_LOG(dynamic_log, FALSE)
DECLARE_LOG(lua_log, FALSE)
DECLARE_LOG(perf_log, FALSE) // Declared here but name is set in time_track subsystem
DECLARE_LOG(query_debug_log, FALSE)
DECLARE_LOG(signals_log, FALSE)
DECLARE_LOG(tgui_log, TRUE)
#ifdef REFERENCE_DOING_IT_LIVE
DECLARE_LOG_NAMED(harddel_log, "harddels", TRUE)
#endif
#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
DECLARE_LOG_NAMED(test_log, "tests", TRUE)
#endif
DECLARE_LOG_NAMED(filter_log, "filters", FALSE)
DECLARE_LOG_NAMED(sql_error_log, "sql", FALSE)
DECLARE_LOG_NAMED(world_asset_log, "asset", FALSE)
DECLARE_LOG_NAMED(world_attack_log, "attack", TRUE)
DECLARE_LOG_NAMED(world_econ_log, "econ", TRUE)
DECLARE_LOG_NAMED(world_game_log, "game", TRUE)
DECLARE_LOG_NAMED(world_href_log, "hrefs", TRUE)
DECLARE_LOG_NAMED(world_job_debug_log, "job_debug", TRUE)
DECLARE_LOG_NAMED(world_manifest_log, "manifest", TRUE)
DECLARE_LOG_NAMED(world_map_error_log, "map_errors", FALSE)
DECLARE_LOG_NAMED(world_mecha_log, "mecha", FALSE)
DECLARE_LOG_NAMED(world_mob_tag_log, "mob_tags", TRUE)
DECLARE_LOG_NAMED(world_paper_log, "paper", FALSE)
DECLARE_LOG_NAMED(world_pda_log, "pda", TRUE)
DECLARE_LOG_NAMED(world_qdel_log, "qdel", TRUE)
DECLARE_LOG_NAMED(world_runtime_log, "runtime", TRUE)
DECLARE_LOG_NAMED(world_shuttle_log, "shuttle", TRUE)
DECLARE_LOG_NAMED(world_silicon_log, "silicon", FALSE)
DECLARE_LOG_NAMED(world_speech_indicators_log, "speech_indicators", FALSE)
DECLARE_LOG_NAMED(world_telecomms_log, "telecomms", TRUE)
DECLARE_LOG_NAMED(world_tool_log, "tools", FALSE)
DECLARE_LOG_NAMED(world_uplink_log, "uplink", TRUE)
DECLARE_LOG_NAMED(world_virus_log, "virus", FALSE)
/// Log associated with [/proc/log_suspicious_login()]
/// Intended to hold all logins that failed due to suspicious circumstances such as ban detection, CID randomisation etc.
DECLARE_LOG_NAMED(world_suspicious_login_log, "suspicious_logins", FALSE)



/// Picture logging
GLOBAL_VAR(picture_log_directory)
GLOBAL_PROTECT(picture_log_directory)

GLOBAL_VAR_INIT(picture_logging_id, 1)
GLOBAL_PROTECT(picture_logging_id)

GLOBAL_VAR(picture_logging_prefix)
GLOBAL_PROTECT(picture_logging_prefix)

/// All admin related log lines minus their categories
GLOBAL_LIST_EMPTY(admin_activities)
GLOBAL_PROTECT(admin_activities)

/// All bomb related messages
GLOBAL_LIST_EMPTY(bombers)
GLOBAL_PROTECT(bombers)

/// All signals here in format: "[src] used [REF(src)] @ location [src.loc]: [freq]/[code]"
GLOBAL_LIST_EMPTY(lastsignalers)
GLOBAL_PROTECT(lastsignalers)

/// Stores who uploaded laws to which silicon-based lifeform, and what the law was
GLOBAL_LIST_EMPTY(lawchanges)
GLOBAL_PROTECT(lawchanges)

#undef DECLARE_LOG
#undef DECLARE_LOG_NAMED
