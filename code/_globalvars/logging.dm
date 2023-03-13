GLOBAL_LIST_EMPTY(active_turfs_startlist)

GLOBAL_LIST_EMPTY(admin_log)
GLOBAL_PROTECT(admin_log)

GLOBAL_LIST_EMPTY(adminlog)
GLOBAL_PROTECT(adminlog)

GLOBAL_LIST_EMPTY(bombers)
GLOBAL_PROTECT(bombers)

GLOBAL_LIST_EMPTY(combatlog)
GLOBAL_PROTECT(combatlog)

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

GLOBAL_VAR(perf_log)
GLOBAL_PROTECT(perf_log)

/// Picture logging
GLOBAL_VAR(picture_log_directory)
GLOBAL_PROTECT(picture_log_directory)

GLOBAL_VAR_INIT(picture_logging_id, 1)
GLOBAL_PROTECT(picture_logging_id)

GLOBAL_VAR(picture_logging_prefix)
GLOBAL_PROTECT(picture_logging_prefix)

GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)

GLOBAL_VAR(world_runtime_log)
GLOBAL_PROTECT(world_runtime_log)
