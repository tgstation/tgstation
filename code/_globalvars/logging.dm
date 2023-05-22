GLOBAL_LIST_EMPTY(active_turfs_startlist)

GLOBAL_LIST_EMPTY(admin_log)
GLOBAL_PROTECT(admin_log)

GLOBAL_LIST_EMPTY(adminlog)
GLOBAL_PROTECT(adminlog)

GLOBAL_LIST_EMPTY(bombers)
GLOBAL_PROTECT(bombers)

GLOBAL_LIST_EMPTY(combatlog)
GLOBAL_PROTECT(combatlog)

GLOBAL_VAR(config_error_log)
GLOBAL_PROTECT(config_error_log)

GLOBAL_VAR(demo_log)
GLOBAL_PROTECT(demo_log)


GLOBAL_VAR(dynamic_log)
GLOBAL_PROTECT(dynamic_log)

GLOBAL_VAR(filter_log)
GLOBAL_PROTECT(filter_log)

#ifdef REFERENCE_DOING_IT_LIVE
GLOBAL_LIST_EMPTY(harddel_log)
GLOBAL_PROTECT(harddel_log)
#endif

GLOBAL_LIST_EMPTY(IClog)
GLOBAL_PROTECT(IClog)

/// Keeps last 100 signals here in format: "[src] used [REF(src)] @ location [src.loc]: [freq]/[code]"
GLOBAL_LIST_EMPTY(lastsignalers)
GLOBAL_PROTECT(lastsignalers)

/// Stores who uploaded laws to which silicon-based lifeform, and what the law was
GLOBAL_LIST_EMPTY(lawchanges)
GLOBAL_PROTECT(lawchanges)
GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)

GLOBAL_VAR(lua_log)
GLOBAL_PROTECT(lua_log)

#define DECLARE_LOG(log_name, start) DECLARE_LOG_NAMED(##log_name, "[copytext(#log_name, 1, length(#log_name) - 3)]", start)
#define START_LOG TRUE
#define DONT_START_LOG FALSE

/// Populated by log declaration macros to set log file names and start messages
/world/proc/_initialize_log_files(temp_log_override = null)
	// Needs to be here to avoid compiler warnings
	SHOULD_CALL_PARENT(TRUE)
	return

// All individual log files.
// These should be used where the log category cannot easily be a json log file.
DECLARE_LOG(config_error_log, DONT_START_LOG)
DECLARE_LOG(perf_log, DONT_START_LOG) // Declared here but name is set in time_track subsystem

#ifdef REFERENCE_DOING_IT_LIVE
DECLARE_LOG_NAMED(harddel_log, "harddels", START_LOG)
#endif

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
DECLARE_LOG_NAMED(test_log, "tests", START_LOG)
#endif

GLOBAL_LIST_EMPTY(mechcomp_log)
GLOBAL_PROTECT(mechcomp_log)

/// Picture logging
GLOBAL_VAR(picture_log_directory)
GLOBAL_PROTECT(picture_log_directory)

GLOBAL_VAR_INIT(picture_logging_id, 1)
GLOBAL_PROTECT(picture_logging_id)

GLOBAL_VAR(picture_logging_prefix)
GLOBAL_PROTECT(picture_logging_prefix)

GLOBAL_VAR(query_debug_log)
GLOBAL_PROTECT(query_debug_log)

GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)

GLOBAL_VAR(signals_log)
GLOBAL_PROTECT(signals_log)

GLOBAL_VAR(sql_error_log)
GLOBAL_PROTECT(sql_error_log)

GLOBAL_VAR(tgui_log)
GLOBAL_PROTECT(tgui_log)

GLOBAL_VAR(world_asset_log)
GLOBAL_PROTECT(world_asset_log)

GLOBAL_VAR(world_attack_log)
GLOBAL_PROTECT(world_attack_log)

GLOBAL_VAR(world_cloning_log)
GLOBAL_PROTECT(world_cloning_log)

GLOBAL_VAR(world_econ_log)
GLOBAL_PROTECT(world_econ_log)

GLOBAL_VAR(world_game_log)
GLOBAL_PROTECT(world_game_log)

GLOBAL_VAR(world_href_log)
GLOBAL_PROTECT(world_href_log)

GLOBAL_VAR(world_job_debug_log)
GLOBAL_PROTECT(world_job_debug_log)

GLOBAL_VAR(world_manifest_log)
GLOBAL_PROTECT(world_manifest_log)

GLOBAL_VAR(world_map_error_log)
GLOBAL_PROTECT(world_map_error_log)

GLOBAL_VAR(world_mecha_log)
GLOBAL_PROTECT(world_mecha_log)

GLOBAL_VAR(world_mob_tag_log)
GLOBAL_PROTECT(world_mob_tag_log)

GLOBAL_VAR(world_paper_log)
GLOBAL_PROTECT(world_paper_log)

GLOBAL_VAR(world_pda_log)
GLOBAL_PROTECT(world_pda_log)

GLOBAL_VAR(world_qdel_log)
GLOBAL_PROTECT(world_qdel_log)

GLOBAL_VAR(world_runtime_log)
GLOBAL_PROTECT(world_runtime_log)

GLOBAL_VAR(world_shuttle_log)
GLOBAL_PROTECT(world_shuttle_log)

GLOBAL_VAR(world_silicon_log)
GLOBAL_PROTECT(world_silicon_log)

GLOBAL_VAR(world_speech_indicators_log)
GLOBAL_PROTECT(world_speech_indicators_log)

/// Log associated with [/proc/log_suspicious_login()]
/// Intended to hold all logins that failed due to suspicious circumstances such as ban detection, CID randomisation etc.
GLOBAL_VAR(world_suspicious_login_log)
GLOBAL_PROTECT(world_suspicious_login_log)

GLOBAL_VAR(world_telecomms_log)
GLOBAL_PROTECT(world_telecomms_log)

GLOBAL_VAR(world_tool_log)
GLOBAL_PROTECT(world_tool_log)

GLOBAL_VAR(world_uplink_log)
GLOBAL_PROTECT(world_uplink_log)

GLOBAL_VAR(world_virus_log)
GLOBAL_PROTECT(world_virus_log)
