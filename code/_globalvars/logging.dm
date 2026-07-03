GLOBAL_LIST_EMPTY(active_turfs_startlist)

GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)

/// The directory in which ALL log files should be stored
GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)

// BANDASTATION ADDITION START - Logis
/// Logis extracts all of the log files, which we don't need.
/// This will be the folder with only logs required for logis.
GLOBAL_VAR(logis_logs_directory)
GLOBAL_PROTECT(logis_logs_directory)
// BANDASTATION ADDITION END - Logis

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

#ifdef REFERENCE_TRACKING_LOG_APART
DECLARE_LOG_NAMED(harddel_log, "harddels", START_LOG)
#endif

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
DECLARE_LOG_NAMED(test_log, "tests", START_LOG)
#endif

DECLARE_LOG_NAMED(reta_log, "reta", START_LOG)


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

/// Investigate log for signaler usage, use the add_to_signaler_investigate_log proc
GLOBAL_LIST_EMPTY(investigate_signaler)
GLOBAL_PROTECT(investigate_signaler)

/// Used to add a text log to the signaler investigation log.
/// Do not add to the list directly; if the list is too large it can cause lag when an admin tries to view it.
/proc/add_to_signaler_investigate_log(text)
	var/log_length = length(GLOB.investigate_signaler)
	if(log_length >= INVESTIGATE_SIGNALER_LOG_MAX_LENGTH)
		GLOB.investigate_signaler = GLOB.investigate_signaler.Copy((INVESTIGATE_SIGNALER_LOG_MAX_LENGTH - log_length) + 2)
	GLOB.investigate_signaler += list(text)

/// Stores who uploaded laws to which silicon-based lifeform, and what the law was
GLOBAL_LIST_EMPTY(lawchanges)
GLOBAL_PROTECT(lawchanges)

#undef DECLARE_LOG
#undef DECLARE_LOG_NAMED
#undef START_LOG
#undef DONT_START_LOG
