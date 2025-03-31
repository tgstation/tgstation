GLOBAL_LIST_EMPTY(admin_ranks) //list of all admin_rank datums
GLOBAL_PROTECT(admin_ranks)

GLOBAL_LIST_EMPTY(protected_ranks) //admin ranks loaded from txt
GLOBAL_PROTECT(protected_ranks)

/datum/admin_rank
	var/name = "NoRank"
	var/rights = R_DEFAULT
	var/exclude_rights = NONE
	var/include_rights = NONE
	var/can_edit_rights = NONE

/datum/admin_rank/New(init_name, init_rights, init_exclude_rights, init_edit_rights)
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		if (name == "NoRank") //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	name = init_name
	if(!name)
		qdel(src)
		CRASH("Admin rank created without name.")
	if(init_rights)
		rights = init_rights
	include_rights = rights
	if(init_exclude_rights)
		exclude_rights = init_exclude_rights
		rights &= ~exclude_rights
	if(init_edit_rights)
		can_edit_rights = init_edit_rights

/datum/admin_rank/Destroy()
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return QDEL_HINT_LETMELIVE
	. = ..()

/datum/admin_rank/vv_edit_var(var_name, var_value)
	return FALSE

// Adds/removes rights to this admin_rank
/datum/admin_rank/proc/process_keyword(group, group_count, datum/admin_rank/previous_rank)
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return
	var/list/keywords = splittext(group, " ")
	var/flag = 0
	for(var/k in keywords)
		switch(k)
			if("BUILD")
				flag = R_BUILD
			if("ADMIN")
				flag = R_ADMIN
			if("BAN")
				flag = R_BAN
			if("FUN")
				flag = R_FUN
			if("SERVER")
				flag = R_SERVER
			if("DEBUG")
				flag = R_DEBUG
			if("PERMISSIONS")
				flag = R_PERMISSIONS
			if("POSSESS")
				flag = R_POSSESS
			if("STEALTH")
				flag = R_STEALTH
			if("POLL")
				flag = R_POLL
			if("VAREDIT")
				flag = R_VAREDIT
			if("EVERYTHING")
				flag = R_EVERYTHING
			if("SOUND")
				flag = R_SOUND
			if("SPAWN")
				flag = R_SPAWN
			if("AUTOADMIN")
				flag = R_AUTOADMIN
			if("DBRANKS")
				flag = R_DBRANKS
			if("@")
				if(previous_rank)
					switch(group_count)
						if(1)
							flag = previous_rank.include_rights
						if(2)
							flag = previous_rank.exclude_rights
						if(3)
							flag = previous_rank.can_edit_rights
				else
					continue
		switch(group_count)
			if(1)
				rights |= flag
				include_rights |= flag
			if(2)
				rights &= ~flag
				exclude_rights |= flag
			if(3)
				can_edit_rights |= flag

/// Loads admin ranks.
///	Return a list containing the backup data if they were loaded from the database backup json
/proc/load_admin_ranks(dbfail, no_update)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Reload blocked: Advanced ProcCall detected.</span>", confidential = TRUE)
		return
	GLOB.admin_ranks.Cut()
	GLOB.protected_ranks.Cut()
	//load text from file and process each entry
	var/ranks_text = file2text("[global.config.directory]/admin_ranks.txt")
	var/datum/admin_rank/previous_rank
	var/regex/admin_ranks_regex = new(@"^Name\s*=\s*(.+?)\s*\n+Include\s*=\s*([\l @]*?)\s*\n+Exclude\s*=\s*([\l @]*?)\s*\n+Edit\s*=\s*([\l @]*?)\s*\n*$", "gm")
	while(admin_ranks_regex.Find(ranks_text))
		var/datum/admin_rank/R = new(admin_ranks_regex.group[1])
		if(!R)
			continue
		var/count = 1
		for(var/i in admin_ranks_regex.group - admin_ranks_regex.group[1])
			if(i)
				R.process_keyword(i, count, previous_rank)
			count++
		GLOB.admin_ranks += R
		GLOB.protected_ranks += R
		previous_rank = R
	if(!CONFIG_GET(flag/admin_legacy_system) && !dbfail)
		if(CONFIG_GET(flag/load_legacy_ranks_only))
			if(!no_update)
				sync_ranks_with_db()
		else
			var/datum/db_query/query_load_admin_ranks = SSdbcore.NewQuery("SELECT `rank`, flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")]")
			if(!query_load_admin_ranks.Execute())
				message_admins("Error loading admin ranks from database. Loading from backup.")
				log_sql("Error loading admin ranks from database. Loading from backup.")
				dbfail = TRUE
			else
				while(query_load_admin_ranks.NextRow())
					var/skip
					var/rank_name = query_load_admin_ranks.item[1]
					for(var/datum/admin_rank/R in GLOB.admin_ranks)
						if(R.name == rank_name) //this rank was already loaded from txt override
							skip = 1
							break
					if(!skip)
						var/rank_flags = text2num(query_load_admin_ranks.item[2])
						var/rank_exclude_flags = text2num(query_load_admin_ranks.item[3])
						var/rank_can_edit_flags = text2num(query_load_admin_ranks.item[4])
						var/datum/admin_rank/R = new(rank_name, rank_flags, rank_exclude_flags, rank_can_edit_flags)
						if(!R)
							continue
						GLOB.admin_ranks += R
			qdel(query_load_admin_ranks)
	//load ranks from backup file
	if(dbfail)
		var/backup_file = file2text("data/admins_backup.json")
		if(backup_file == null)
			log_world("Unable to locate admins backup file.")
			return FALSE
		var/list/json = json_decode(backup_file)
		for(var/J in json["ranks"])
			var/skip
			for(var/datum/admin_rank/R in GLOB.admin_ranks)
				if(R.name == "[J]") //this rank was already loaded from txt override
					skip = TRUE
			if(skip)
				continue
			var/datum/admin_rank/R = new("[J]", json["ranks"]["[J]"]["include rights"], json["ranks"]["[J]"]["exclude rights"], json["ranks"]["[J]"]["can edit rights"])
			if(!R)
				continue
			GLOB.admin_ranks += R
		return json
	#ifdef TESTING
	var/msg = "Permission Sets Built:\n"
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		msg += "\t[R.name]"
		var/rights = rights2text(R.rights,"\n\t\t")
		if(rights)
			msg += "\t\t[rights]\n"
	testing(msg)
	#endif

/// Converts a rank name (such as "Coder+Moth") into a list of /datum/admin_rank
/proc/ranks_from_rank_name(rank_name)
	var/list/rank_names = splittext(rank_name, "+")
	var/list/ranks = list()

	for (var/datum/admin_rank/rank as anything in GLOB.admin_ranks)
		if (rank.name in rank_names)
			rank_names -= rank.name
			ranks += rank

			if (rank_names.len == 0)
				break

	if (rank_names.len > 0)
		log_config("Admin rank names were invalid: [jointext(ranks, ", ")]")

	return ranks

/// Takes a list of rank names and joins them with +
/proc/join_admin_ranks(list/datum/admin_rank/ranks)
	var/list/names = list()

	for (var/datum/admin_rank/rank as anything in ranks)
		names += rank.name

	return jointext(names, "+")

/// (Re)Loads the admin list.
/// returns TRUE if database admins had to be loaded from the backup json
/proc/load_admins(no_update, initial = FALSE)
	if(!initial)
		if(!global.config.PreConfigReload())
			return

	var/dbfail
	if(!CONFIG_GET(flag/admin_legacy_system) && !SSdbcore.Connect())
		message_admins("Failed to connect to database while loading admins. Loading from backup.")
		log_sql("Failed to connect to database while loading admins. Loading from backup.")
		dbfail = TRUE
	//clear the datums references
	GLOB.admin_datums.Cut()
	for(var/client/C in GLOB.admins)
		C.remove_admin_verbs()
		C.holder = null
	GLOB.admins.Cut()
	GLOB.protected_admins.Cut()
	GLOB.deadmins.Cut()
	var/list/backup_file_json = load_admin_ranks(dbfail, no_update)
	dbfail = backup_file_json != null
	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)
	var/list/rank_names = list()
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		rank_names[R.name] = R
	//ckeys listed in admins.txt are always made admins before sql loading is attempted
	var/admins_text = file2text("[global.config.directory]/admins.txt")
	var/regex/admins_regex = new(@"^(?!#)(.+?)\s+=\s+(.+)", "gm")

	while(admins_regex.Find(admins_text))
		var/admin_key = admins_regex.group[1]
		var/admin_rank = admins_regex.group[2]
		new /datum/admins(ranks_from_rank_name(admin_rank), ckey(admin_key), force_active = FALSE, protected = TRUE)

	if(!CONFIG_GET(flag/admin_legacy_system) && !dbfail)
		var/datum/db_query/query_load_admins = SSdbcore.NewQuery("SELECT ckey, `rank`, feedback FROM [format_table_name("admin")] ORDER BY `rank`")
		if(!query_load_admins.Execute())
			message_admins("Error loading admins from database. Loading from backup.")
			log_sql("Error loading admins from database. Loading from backup.")
			dbfail = 1
		else
			while(query_load_admins.NextRow())
				var/admin_ckey = ckey(query_load_admins.item[1])
				var/admin_rank = query_load_admins.item[2]
				var/admin_feedback = query_load_admins.item[3]
				var/skip

				var/list/admin_ranks = ranks_from_rank_name(admin_rank)

				if(admin_ranks.len == 0)
					message_admins("[admin_ckey] loaded with invalid admin rank [admin_rank].")
					skip = 1
				if(GLOB.admin_datums[admin_ckey] || GLOB.deadmins[admin_ckey])
					skip = 1
				if(!skip)
					var/datum/admins/admin_holder = new(admin_ranks, admin_ckey)
					admin_holder.cached_feedback_link = admin_feedback || NO_FEEDBACK_LINK
		qdel(query_load_admins)
		if (!no_update)
			save_admin_backup()
			sync_admins_with_db()
	//load admins from backup file
	if(dbfail)
		if(!backup_file_json)
			if(backup_file_json != null)
				//already tried
				return
			var/backup_file = file2text("data/admins_backup.json")
			if(backup_file == null)
				log_world("Unable to locate admins backup file.")
				return
			backup_file_json = json_decode(backup_file)
		for(var/backup_admin_ckey in backup_file_json["admins"])
			var/skip
			for(var/admin_ckey in GLOB.admin_datums + GLOB.deadmins)
				if(ckey(admin_ckey) == ckey("[backup_admin_ckey]")) //this admin was already loaded from txt override
					skip = TRUE
					break
			if(skip)
				continue
			new /datum/admins(ranks_from_rank_name(backup_file_json["admins"]["[backup_admin_ckey]"]), ckey("[backup_admin_ckey]"))
	#ifdef TESTING
	var/msg = "Admins Built:\n"
	for(var/ckey in GLOB.admin_datums)
		var/datum/admins/D = GLOB.admin_datums[ckey]
		msg += "\t[ckey] - [D.rank_names()]\n"
	testing(msg)
	#endif
	return dbfail


/proc/sync_ranks_with_db()
	set waitfor = FALSE

	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin rank DB Sync blocked: Advanced ProcCall detected.</span>", confidential = TRUE)
		return

	var/list/sql_ranks = list()
	for(var/datum/admin_rank/R as anything in GLOB.protected_ranks)
		sql_ranks += list(list("rank" = R.name, "flags" = R.include_rights, "exclude_flags" = R.exclude_rights, "can_edit_flags" = R.can_edit_rights))
	SSdbcore.MassInsert(format_table_name("admin_ranks"), sql_ranks, duplicate_key = TRUE)
	update_everything_flag_in_db()


/proc/update_everything_flag_in_db()
	for(var/datum/admin_rank/R as anything in GLOB.admin_ranks)
		var/list/flags = list()
		if(R.include_rights == R_EVERYTHING)
			flags += "flags"
		if(R.exclude_rights == R_EVERYTHING)
			flags += "exclude_flags"
		if(R.can_edit_rights == R_EVERYTHING)
			flags += "can_edit_flags"
		if(!flags.len)
			continue
		var/flags_to_check = flags.Join(" != [R_EVERYTHING] AND ") + " != [R_EVERYTHING]"
		var/datum/db_query/query_check_everything_ranks = SSdbcore.NewQuery(
			"SELECT flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")] WHERE rank = :rank AND ([flags_to_check])",
			list("rank" = R.name)
		)
		if(!query_check_everything_ranks.Execute())
			qdel(query_check_everything_ranks)
			return
		if(query_check_everything_ranks.NextRow()) //no row is returned if the rank already has the correct flag value
			var/flags_to_update = flags.Join(" = [R_EVERYTHING], ") + " = [R_EVERYTHING]"
			var/datum/db_query/query_update_everything_ranks = SSdbcore.NewQuery(
				"UPDATE [format_table_name("admin_ranks")] SET [flags_to_update] WHERE rank = :rank",
				list("rank" = R.name)
			)
			if(!query_update_everything_ranks.Execute())
				qdel(query_update_everything_ranks)
				return
			qdel(query_update_everything_ranks)
		qdel(query_check_everything_ranks)


/proc/sync_admins_with_db()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin rank DB Sync blocked: Advanced ProcCall detected.</span>")
		return

	if(CONFIG_GET(flag/admin_legacy_system) || !SSdbcore.IsConnected()) //we're already using legacy system so there's nothing to save
		return
	sync_ranks_with_db()
	var/list/sql_admins = list()
	for(var/holder_ckey in GLOB.protected_admins)
		var/datum/admins/holder = GLOB.protected_admins[holder_ckey]
		sql_admins += list(list("ckey" = holder.target, "rank" = holder.rank_names()))
	SSdbcore.MassInsert(format_table_name("admin"), sql_admins, duplicate_key = TRUE)
	var/datum/db_query/query_admin_rank_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] AS p INNER JOIN [format_table_name("admin")] AS a ON p.ckey = a.ckey SET p.lastadminrank = a.rank")
	query_admin_rank_update.Execute()
	qdel(query_admin_rank_update)


/proc/save_admin_backup()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin rank DB Sync blocked: Advanced ProcCall detected.</span>")
		return

	if(CONFIG_GET(flag/admin_legacy_system)) //we're already using legacy system so there's nothing to save
		return

	//json format backup file generation stored per server
	var/json_file = file("data/admins_backup.json")
	var/list/file_data = list(
		"ranks" = list(),
		"admins" = list()
	)
	for(var/datum/admin_rank/R as anything in GLOB.admin_ranks)
		file_data["ranks"]["[R.name]"] = list()
		file_data["ranks"]["[R.name]"]["include rights"] = R.include_rights
		file_data["ranks"]["[R.name]"]["exclude rights"] = R.exclude_rights
		file_data["ranks"]["[R.name]"]["can edit rights"] = R.can_edit_rights

	for(var/admin_ckey in GLOB.admin_datums + GLOB.deadmins)
		var/datum/admins/admin = GLOB.admin_datums[admin_ckey]

		if(!admin)
			admin = GLOB.deadmins[admin_ckey]
			if (!admin)
				continue

		file_data["admins"][admin_ckey] = admin.rank_names()

		admin.backup_connections()

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data, JSON_PRETTY_PRINT))
