GLOBAL_LIST_EMPTY(admin_ranks)								//list of all admin_rank datums
GLOBAL_PROTECT(admin_ranks)

/datum/admin_rank
	var/name = "NoRank"
	var/rights = R_DEFAULT
	var/exclude_rights = 0

/datum/admin_rank/New(init_name, init_rights, init_exclude_rights)
	if(!name)
		qdel(src)
		throw EXCEPTION("Admin rank created without name.")
		return
	name = init_name
	if(init_rights)
		rights = init_rights
	if(init_exclude_rights)
		exclude_rights = init_exclude_rights
		rights &= ~exclude_rights

/datum/admin_rank/vv_edit_var(var_name, var_value)
	return FALSE

#if DM_VERSION > 512
#error remove the rejuv keyword from this proc
#endif
/proc/admin_keyword_to_flag(word, previous_rights=0)
	var/flag = 0
	switch(ckey(word))
		if("buildmode","build")
			flag = R_BUILDMODE
		if("admin")
			flag = R_ADMIN
		if("ban")
			flag = R_BAN
		if("fun")
			flag = R_FUN
		if("server")
			flag = R_SERVER
		if("debug")
			flag = R_DEBUG
		if("permissions","rights")
			flag = R_PERMISSIONS
		if("possess")
			flag = R_POSSESS
		if("stealth")
			flag = R_STEALTH
		if("poll")
			flag = R_POLL
		if("varedit")
			flag = R_VAREDIT
		if("everything","host","all")
			flag = ALL
		if("sound","sounds")
			flag = R_SOUNDS
		if("spawn","create")
			flag = R_SPAWN
		if("autologin", "autoadmin")
			flag = R_AUTOLOGIN
		if("@","prev")
			flag = previous_rights
		if("rejuv","rejuvinate")
			stack_trace("Legacy keyword rejuvinate used defaulting to R_ADMIN")
			flag = R_ADMIN
	return flag

// Adds/removes rights to this admin_rank
/datum/admin_rank/proc/process_keyword(word, previous_rights=0)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin_private("[key_name(usr)][msg]")
		return
	var/flag = admin_keyword_to_flag(word, previous_rights)
	if(flag)
		switch(text2ascii(word,1))
			if(43)
				rights |= flag	//+
			if(45)
				rights &= ~flag	//-
				exclude_rights	|= flag

// Checks for (keyword-formatted) rights on this admin
/datum/admins/proc/check_keyword(word)
	var/flag = admin_keyword_to_flag(word)
	if(flag)
		return ((rank.rights & flag) == flag) //true only if right has everything in flag

//load our rank - > rights associations
/proc/load_admin_ranks()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Reload blocked: Advanced ProcCall detected.</span>")
		return
	GLOB.admin_ranks.Cut()
	if(!CONFIG_GET(flag/admin_legacy_system))
		var/datum/DBQuery/query_load_admin_ranks = SSdbcore.NewQuery("SELECT rank, flags, exclude_flags FROM [format_table_name("admin_ranks")]")
		if(!query_load_admin_ranks.Execute())
			message_admins("Error loading admin ranks from database. Reverting to legacy system.")
			log_world("Error loading admin ranks from database. Reverting to legacy system.")
			CONFIG_SET(flag/admin_legacy_system, TRUE)
		else
			while(query_load_admin_ranks.NextRow())
				var/rank_name = query_load_admin_ranks.item[1]
				var/rank_flags = text2num(query_load_admin_ranks.item[2])
				var/rank_exclude_flags = text2num(query_load_admin_ranks.item[3])
				var/datum/admin_rank/R = new(rank_name, rank_flags, rank_exclude_flags)
				if(!R)
					continue
				GLOB.admin_ranks += R
	if(CONFIG_GET(flag/admin_legacy_system))
		var/previous_rights = 0
		//load text from file and process each line separately
		for(var/line in world.file2list("[global.config.directory]/admin_ranks.txt"))
			if(!line || findtextEx(line,"#",1,2))
				continue
			var/next = findtext(line, "=")
			var/datum/admin_rank/R = new(ckeyEx(copytext(line, 1, next)))
			if(!R)
				continue
			GLOB.admin_ranks += R
			var/prev = findchar(line, "+-", next, 0)
			while(prev)
				next = findchar(line, "+-", prev + 1, 0)
				R.process_keyword(copytext(line, prev, next), previous_rights)
				prev = next
			previous_rights = R.rights
	#ifdef TESTING
	var/msg = "Permission Sets Built:\n"
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		msg += "\t[R.name]"
		var/rights = rights2text(R.rights,"\n\t\t")
		if(rights)
			msg += "\t\t[rights]\n"
	testing(msg)
	#endif

/proc/load_admins()
	//clear the datums references
	if(CONFIG_GET(flag/admin_legacy_system) && !SSdbcore.Connect())
		message_admins("Failed to connect to database while loading admins. Reverting to legacy system.")
		log_world("Failed to connect to database while loading admins. Reverting to legacy system.")
		CONFIG_SET(flag/admin_legacy_system, TRUE)
	GLOB.admin_datums.Cut()
	for(var/client/C in GLOB.admins)
		C.remove_admin_verbs()
		C.holder = null
	GLOB.admins.Cut()
	GLOB.deadmins.Cut()
	load_admin_ranks()
	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)
	var/list/rank_names = list()
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		rank_names[R.name] = R
	if(!CONFIG_GET(flag/admin_legacy_system))
		var/datum/DBQuery/query_load_admins = SSdbcore.NewQuery("SELECT ckey, rank FROM [format_table_name("admin")]")
		if(!query_load_admins.Execute())
			message_admins("Error loading admins from database. Reverting to legacy system.")
			log_world("Error loading admins from database. Reverting to legacy system.")
			CONFIG_SET(flag/admin_legacy_system, TRUE)
		else
			while(query_load_admins.NextRow())
				var/admin_ckey = query_load_admins.item[1]
				var/admin_rank = query_load_admins.item[2]
				if(rank_names[admin_rank] == null)
					message_admins("[admin_ckey] loaded with invalid admin rank [admin_rank].")
					log_world("[admin_ckey] loaded with invalid admin rank [admin_rank].")
					continue
				new /datum/admins(rank_names[admin_rank], admin_ckey)
	if(CONFIG_GET(flag/admin_legacy_system))
		//load text from file
		var/list/lines = world.file2list("[global.config.directory]/admins.txt")
		//process each line separately
		for(var/line in lines)
			if(!length(line) || findtextEx(line, "#", 1, 2))
				continue
			var/list/entry = splittext(line, "=")
			if(entry.len < 2)
				continue
			var/ckey = ckey(entry[1])
			var/rank = ckeyEx(entry[2])
			if(!ckey || !rank)
				continue
			new /datum/admins(rank_names[rank], ckey)
	#ifdef TESTING
	var/msg = "Admins Built:\n"
	for(var/ckey in GLOB.admin_datums)
		var/datum/admins/D = GLOB.admin_datums[ckey]
		msg += "\t[ckey] - [D.rank.name]\n"
	testing(msg)
	#endif

#ifdef TESTING
/client/verb/changerank(newrank in GLOB.admin_ranks)
	if(holder)
		holder.rank = newrank
	else
		holder = new /datum/admins(newrank, ckey)
	remove_admin_verbs()
	holder.associate(src)

/client/verb/changerights(newrights as num)
	if(holder)
		holder.rank.rights = newrights
	else
		holder = new /datum/admins("testing", newrights, ckey)
	remove_admin_verbs()
	holder.associate(src)
#endif
