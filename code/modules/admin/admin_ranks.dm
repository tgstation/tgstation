var/list/admin_ranks = list()
								//list of all admin_rank datums
/datum/admin_rank
	var/name = "NoRank"
	var/rights = 0
	var/list/adds
	var/list/subs

/proc/load_admins(target = null)
	//clear the datums references
	if(!target)
		admin_datums.Cut()
		for(var/client/C in admins)
			C.remove_admin_verbs()
			C.holder = null
		admins.Cut()
		//load_admin_ranks()
		//Clear profile access
		for(var/A in world.GetConfig("admin"))
			world.SetConfig("APP/admin", A, null)

//	var/list/rank_names = list()
//	for(var/datum/admin_rank/R in admin_ranks)
//		rank_names[R.name] = R

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

			var/datum/admins/D = new(rank, 65535, ckey)	//create the admin datum and store it for later use
			if(!D)
				continue									//will occur if an invalid rank is provided
			//if(D.rank.rights & R_DEBUG) //grant profile access
			//	world.SetConfig("APP/admin", ckey, "role=admin")
			D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new admin datum
	else
		if(!dbcon.Connect())
			log_world("Failed to connect to database in load_admins(). Reverting to legacy system.")
			diary << "Failed to connect to database in load_admins(). Reverting to legacy system."
			config.admin_legacy_system = 1
			load_admins()
			return

		var/DBQuery/query_load_admins = dbcon.NewQuery("SELECT ckey, rank, flags FROM [format_table_name("admin")]")
		if(!query_load_admins.Execute())
			return
		while(query_load_admins.NextRow())
			var/ckey = ckey(query_load_admins.item[1])
			var/rank = ckeyEx(query_load_admins.item[2])
			if(target && ckey != target)
				continue

			if(rank == null)
				WARNING("Admin rank ([rank]) does not exist.")
				continue

			var/datum/admins/D = new(rank, ckey)				//create the admin datum and store it for later use
			if(!D)
				continue									//will occur if an invalid rank is provided
		//	if(D & R_DEBUG) //grant profile access
		//		world.SetConfig("APP/admin", ckey, "role=admin")
			D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new admin datum
