GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)
GLOBAL_VAR(world_game_log)
GLOBAL_PROTECT(world_game_log)
GLOBAL_VAR(world_runtime_log)
GLOBAL_PROTECT(world_runtime_log)
GLOBAL_VAR(world_attack_log)
GLOBAL_PROTECT(world_attack_log)
GLOBAL_VAR(world_href_log)
GLOBAL_PROTECT(world_href_log)
GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)
GLOBAL_VAR(config_error_log)
GLOBAL_PROTECT(config_error_log)
GLOBAL_VAR(sql_error_log)
GLOBAL_PROTECT(sql_error_log)

GLOBAL_LIST_EMPTY(bombers)
GLOBAL_PROTECT(bombers)
GLOBAL_LIST_EMPTY(admin_log)
GLOBAL_PROTECT(admin_log)
GLOBAL_LIST_EMPTY(lastsignalers)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
GLOBAL_PROTECT(lastsignalers)
GLOBAL_LIST_EMPTY(lawchanges) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
GLOBAL_PROTECT(lawchanges)

GLOBAL_LIST_EMPTY(combatlog)
GLOBAL_PROTECT(combatlog)
GLOBAL_LIST_EMPTY(IClog)
GLOBAL_PROTECT(IClog)
GLOBAL_LIST_EMPTY(OOClog)
GLOBAL_PROTECT(OOClog)
GLOBAL_LIST_EMPTY(adminlog)
GLOBAL_PROTECT(adminlog)

GLOBAL_LIST_EMPTY(individual_log_list) // Logs each mob individual logs, a global so it doesn't get lost on cloning/changing mobs

GLOBAL_LIST_EMPTY(active_turfs_startlist)