GLOBAL_VAR(diary)
GLOBAL_VAR(runtime_diary)
GLOBAL_VAR(diaryofmeanpeople)
GLOBAL_VAR(href_logfile)

GLOBAL_LIST_INIT(bombers, list())
GLOBAL_LIST_INIT(admin_log, list())
GLOBAL_LIST_INIT(lastsignalers, list())	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
GLOBAL_LIST_INIT(lawchanges, list()) //Stores who uploaded laws to which silicon-based lifeform, and what the law was

GLOBAL_LIST_INIT(combatlog, list())
GLOBAL_LIST_INIT(IClog, list())
GLOBAL_LIST_INIT(OOClog, list())
GLOBAL_LIST_INIT(adminlog, list())

GLOBAL_LIST_INIT(active_turfs_startlist, list())