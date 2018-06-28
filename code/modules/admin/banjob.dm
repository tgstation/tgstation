//returns a reason if M is banned from rank, returns FALSE otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!M || !istype(M) || !M.ckey)
		return FALSE

	if(!M.client) //no cache. fallback to a datum/DBQuery
		var/datum/DBQuery/query_jobban_check_ban = SSdbcore.NewQuery("SELECT reason FROM [format_table_name("ban")] WHERE ckey = '[sanitizeSQL(M.ckey)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned) AND job = '[sanitizeSQL(rank)]'")
		if(!query_jobban_check_ban.warn_execute())
			qdel(query_jobban_check_ban)
			return
		if(query_jobban_check_ban.NextRow())
			var/reason = query_jobban_check_ban.item[1]
			qdel(query_jobban_check_ban)
			return reason ? reason : TRUE //we don't want to return "" if there is no ban reason, as that would evaluate to false
		qdel(query_jobban_check_ban)
		return FALSE

	if(!M.client.jobbancache)
		jobban_buildcache(M.client)

	if(rank in M.client.jobbancache)
		var/reason = M.client.jobbancache[rank]
		return (reason) ? reason : TRUE //see above for why we need to do this
	return FALSE

/proc/jobban_buildcache(client/C)
	if(!SSdbcore.Connect())
		return
	if(C && istype(C))
		C.jobbancache = list()
		var/datum/DBQuery/query_jobban_build_cache = SSdbcore.NewQuery("SELECT job, reason FROM [format_table_name("ban")] WHERE ckey = '[sanitizeSQL(C.ckey)]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query_jobban_build_cache.warn_execute())
			return
		while(query_jobban_build_cache.NextRow())
			C.jobbancache[query_jobban_build_cache.item[1]] = query_jobban_build_cache.item[2]
		qdel(query_jobban_build_cache)

/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")
