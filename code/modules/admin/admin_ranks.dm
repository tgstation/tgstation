var/list/admin_ranks = list()								//list of all admin_rank datums

/datum/admin_rank
	var/name = "NoRank"
	var/rights = 0
	var/list/adds
	var/list/subs

/datum/admin_rank/SDQL_update()
	return FALSE	//Nice try trivialadmin!

/datum/admin_rank/New(init_name, init_rights, list/init_adds, list/init_subs)
	name = init_name
	switch(name)
		if("Removed",null,"")
			spawn(0)
				qdel(src)
			throw EXCEPTION("invalid admin-rank name")
			return
	if(init_rights)
		rights = init_rights
	if(!init_adds)
		init_adds = list()
	if(!init_subs)
		init_subs = list()
	adds = init_adds
	subs = init_subs

/datum/admin_rank/vv_edit_var(var_name, var_value)
	return FALSE

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
		if("rejuv","rejuvinate")
			flag = R_REJUVINATE
		if("varedit")
			flag = R_VAREDIT
		if("everything","host","all")
			flag = 65535
		if("sound","sounds")
			flag = R_SOUNDS
		if("spawn","create")
			flag = R_SPAWN
		if("@","prev")
			flag = previous_rights
	return flag

/proc/admin_keyword_to_path(word) //use this with verb keywords eg +/client/proc/blah
	return text2path(copytext(word, 2, findtext(word, " ", 2, 0)))

// Adds/removes rights to this admin_rank
/datum/admin_rank/proc/process_keyword(word, previous_rights=0)
	var/flag = admin_keyword_to_flag(word, previous_rights)
	if(flag)
		switch(text2ascii(word,1))
			if(43)
				rights |= flag	//+
			if(45)
				rights &= ~flag	//-
	else
		//isn't a keyword so maybe it's a verbpath?
		var/path = admin_keyword_to_path(word)
		if(path)
			switch(text2ascii(word,1))
				if(43)
					if(!subs.Remove(path))
						adds += path	//+
				if(45)
					if(!adds.Remove(path))
						subs += path	//-

// Checks for (keyword-formatted) rights on this admin
/datum/admins/proc/check_keyword(word)
	var/flag = admin_keyword_to_flag(word)
	if(flag)
		return ((rank.rights & flag) == flag) //true only if right has everything in flag
	else
		var/path = admin_keyword_to_path(word)
		for(var/i in owner.verbs) //this needs to be a foreach loop for some reason. in operator and verbs.Find() don't work
			if(i == path)
				return 1
		return 0

//load our rank - > rights associations
/proc/load_admin_ranks()
	admin_ranks.Cut()

	if(config.admin_legacy_system)
		var/previous_rights = 0
		//load text from file and process each line seperately
		for(var/line in file2list("config/admin_ranks.txt"))
			if(!line)
				continue
			if(findtextEx(line,"#",1,2))
				continue

			var/next = findtext(line, "=")
			var/datum/admin_rank/R = new(ckeyEx(copytext(line, 1, next)))
			if(!R)
				continue
			admin_ranks += R

			var/prev = findchar(line, "+-", next, 0)
			while(prev)
				next = findchar(line, "+-", prev + 1, 0)
				R.process_keyword(copytext(line, prev, next), previous_rights)
				prev = next

			previous_rights = R.rights
	else
		if(!dbcon.Connect())
			log_world("Failed to connect to database in load_admin_ranks(). Reverting to legacy system.")
			diary << "Failed to connect to database in load_admin_ranks(). Reverting to legacy system."
			config.admin_legacy_system = 1
			load_admin_ranks()
			return

		var/DBQuery/query = dbcon.NewQuery("SELECT rank, flags FROM [format_table_name("admin_ranks")]")
		query.Execute()
		while(query.NextRow())
			var/rank_name = ckeyEx(query.item[1])
			var/flags = query.item[2]
			if(istext(flags))
				flags = text2num(flags)
			var/datum/admin_rank/R = new(rank_name, flags)
			if(!R)
				continue
			admin_ranks += R

	#ifdef TESTING
	var/msg = "Permission Sets Built:\n"
	for(var/datum/admin_rank/R in admin_ranks)
		msg += "\t[R.name]"
		var/rights = rights2text(R.rights,"\n\t\t",R.adds,R.subs)
		if(rights)
			msg += "\t\t[rights]\n"
	testing(msg)
	#endif


/proc/load_admins(target = null)
	//clear the datums references
	if(!target)
		admin_datums.Cut()
		for(var/client/C in admins)
			C.remove_admin_verbs()
			C.holder = null
		admins.Cut()
		load_admin_ranks()
		//Clear profile access
		for(var/A in world.GetConfig("admin"))
			world.SetConfig("APP/admin", A, null)

	var/list/rank_names = list()
	for(var/datum/admin_rank/R in admin_ranks)
		rank_names[R.name] = R

	if(config.admin_legacy_system)
		//load text from file
		var/list/lines = file2list("config/admins.txt")

		//process each line seperately
		for(var/line in lines)
			if(!length(line))
				continue
			if(findtextEx(line, "#", 1, 2))
				continue

			var/list/entry = splittext(line, "=")
			if(entry.len < 2)
				continue

			var/ckey = ckey(entry[1])
			var/rank = ckeyEx(entry[2])
			if(!ckey || !rank || (target && ckey != target))
				continue

			var/datum/admins/D = new(rank_names[rank], ckey)	//create the admin datum and store it for later use
			if(!D)
				continue									//will occur if an invalid rank is provided
			if(D.rank.rights & R_DEBUG) //grant profile access
				world.SetConfig("APP/admin", ckey, "role=admin")
			D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new admin datum
	else
		if(!dbcon.Connect())
			log_world("Failed to connect to database in load_admins(). Reverting to legacy system.")
			diary << "Failed to connect to database in load_admins(). Reverting to legacy system."
			config.admin_legacy_system = 1
			load_admins()
			return

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, rank FROM [format_table_name("admin")]")
		query.Execute()
		while(query.NextRow())
			var/ckey = ckey(query.item[1])
			var/rank = ckeyEx(query.item[2])
			if(target && ckey != target)
				continue

			if(rank_names[rank] == null)
				WARNING("Admin rank ([rank]) does not exist.")
				continue

			var/datum/admins/D = new(rank_names[rank], ckey)				//create the admin datum and store it for later use
			if(!D)
				continue									//will occur if an invalid rank is provided
			if(D.rank.rights & R_DEBUG) //grant profile access
				world.SetConfig("APP/admin", ckey, "role=admin")
			D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new admin datum

	#ifdef TESTING
	var/msg = "Admins Built:\n"
	for(var/ckey in admin_datums)
		var/datum/admins/D = admin_datums[ckey]
		msg += "\t[ckey] - [D.rank.name]\n"
	testing(msg)
	#endif


#ifdef TESTING
/client/verb/changerank(newrank in admin_ranks)
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

/datum/admins/proc/edit_rights_topic(list/href_list)
	if(!check_rights(R_PERMISSIONS))
		message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
		log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
		return

	var/adm_ckey
	var/task = href_list["editrights"]
	switch(task)
		if("add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey)
				return
			if(new_ckey in admin_datums)
				usr << "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>"
				return
			adm_ckey = new_ckey
			task = "rank"
		else
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				usr << "<font color='red'>Error: Topic 'editrights': No valid ckey</font>"
				return

	var/datum/admins/D = admin_datums[adm_ckey]

	switch(task)
		if("remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)
					return
				if(!check_if_greater_rights_than_holder(D))
					message_admins("[key_name_admin(usr)] attempted to remove [adm_ckey] from the admins list without sufficient rights.")
					log_admin("[key_name(usr)] attempted to remove [adm_ckey] from the admins list without sufficient rights.")
					return
				admin_datums -= adm_ckey
				D.disassociate()

				updateranktodb(adm_ckey, "player")
				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		if("rank")
			var/datum/admin_rank/R

			var/list/rank_names = list("*New Rank*")
			for(R in admin_ranks)
				rank_names[R.name] = R

			var/new_rank = input("Please select a rank", "New rank", null, null) as null|anything in rank_names

			switch(new_rank)
				if(null)
					return
				if("*New Rank*")
					new_rank = ckeyEx(input("Please input a new rank", "New custom rank", null, null) as null|text)
					if(!new_rank)
						return

			if(D)
				if(!check_if_greater_rights_than_holder(D))
					message_admins("[key_name_admin(usr)] attempted to change the rank of [adm_ckey] to [new_rank] without sufficient rights.")
					log_admin("[key_name(usr)] attempted to change the rank of [adm_ckey] to [new_rank] without sufficient rights.")
					return

			R = rank_names[new_rank]
			if(!R)	//rank with that name doesn't exist yet - make it
				if(D)
					R = new(new_rank, D.rank.rights, D.rank.adds, D.rank.subs)	//duplicate our previous admin_rank but with a new name
				else
					R = new(new_rank)							//blank new admin_rank
				admin_ranks += R

			if(D)	//they were previously an admin
				D.disassociate()	//existing admin needs to be disassociated
				D.rank = R			//set the admin_rank as our rank
			else
				D = new(R,adm_ckey)	//new admin

			var/client/C = directory[adm_ckey]	//find the client with the specified ckey (if they are logged in)
			D.associate(C)						//link up with the client and add verbs

			updateranktodb(adm_ckey, new_rank)
			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		if("permissions")
			if(!D)
				return	//they're not an admin!

			var/keyword = input("Input permission keyword (one at a time):\ne.g. +BAN or -FUN or +/client/proc/someverb", "Permission toggle", null, null) as null|text
			if(!keyword)
				return

			if(!check_keyword(keyword) || !check_if_greater_rights_than_holder(D))
				message_admins("[key_name_admin(usr)] attempted to give [adm_ckey] the keyword [keyword] without sufficient rights.")
				log_admin("[key_name(usr)] attempted to give [adm_ckey] the keyword [keyword] without sufficient rights.")
				return

			D.disassociate()

			if(!findtext(D.rank.name, "([adm_ckey])"))	//not a modified subrank, need to duplicate the admin_rank datum to prevent modifying others too
				D.rank = new("[D.rank.name]([adm_ckey])", D.rank.rights, D.rank.adds, D.rank.subs)	//duplicate our previous admin_rank but with a new name
				//we don't add this clone to the admin_ranks list, as it is unique to that ckey

			D.rank.process_keyword(keyword)

			var/client/C = directory[adm_ckey]	//find the client with the specified ckey (if they are logged in)
			D.associate(C)						//link up with the client and add verbs

			message_admins("[key_name(usr)] added keyword [keyword] to permission of [adm_ckey]")
			log_admin("[key_name(usr)] added keyword [keyword] to permission of [adm_ckey]")
			log_admin_permission_modification(adm_ckey, D.rank.rights)

	edit_admin_permissions()

/datum/admins/proc/updateranktodb(ckey,newrank)
	if(!dbcon.Connect())
		return
	var/sql_ckey = sanitizeSQL(ckey)
	var/sql_admin_rank = sanitizeSQL(newrank)

	var/DBQuery/query_update = dbcon.NewQuery("UPDATE [format_table_name("player")] SET lastadminrank = '[sql_admin_rank]' WHERE ckey = '[sql_ckey]'")
	query_update.Execute()
