//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !istype(M) || !M.ckey)
		return 0

	if(!M.client) //no cache. fallback to a DBQuery
		var/DBQuery/query_jobban_check_ban = dbcon.NewQuery("SELECT reason FROM [format_table_name("ban")] WHERE ckey = '[sanitizeSQL(M.ckey)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned) AND job = '[sanitizeSQL(rank)]'")
		if(!query_jobban_check_ban.warn_execute())
			return
		if(query_jobban_check_ban.NextRow())
			var/reason = query_jobban_check_ban.item[1]
			return reason ? reason : 1 //we don't want to return "" if there is no ban reason, as that would evaluate to false
		else
			return 0

	if(!M.client.jobbancache)
		jobban_buildcache(M.client)

	if(rank in M.client.jobbancache)
		var/reason = M.client.jobbancache[rank]
		return (reason) ? reason : 1 //see above for why we need to do this
	return 0

/proc/jobban_buildcache(client/C)
	if(C && istype(C))
		C.jobbancache = list()
		var/DBQuery/query_jobban_build_cache = dbcon.NewQuery("SELECT job, reason FROM [format_table_name("ban")] WHERE ckey = '[sanitizeSQL(C.ckey)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query_jobban_build_cache.warn_execute())
			return
		while(query_jobban_build_cache.NextRow())
			C.jobbancache[query_jobban_build_cache.item[1]] = query_jobban_build_cache.item[2]

/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")
