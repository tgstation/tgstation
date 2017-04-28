GLOBAL_VAR(diary)
GLOBAL_PROTECT(diary)
GLOBAL_VAR(runtime_diary)
GLOBAL_PROTECT(runtime_diary)
GLOBAL_VAR(diaryofmeanpeople)
GLOBAL_PROTECT(diaryofmeanpeople)
GLOBAL_VAR(href_logfile)
GLOBAL_PROTECT(href_logfile)

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

GLOBAL_LIST_EMPTY(active_turfs_startlist)