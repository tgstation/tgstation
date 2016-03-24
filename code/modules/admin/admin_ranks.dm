var/list/admin_ranks = list()								//list of all ranks with associated rights

//load our rank - > rights associations
/proc/load_admin_ranks()
	admin_ranks.Cut()

	var/previous_rights = 0

	//load text from file
	var/list/Lines = file2list("config/admin_ranks.txt")

	//process each line seperately
	for(var/line in Lines)
		if(!length(line))				continue
		if(copytext(line,1,2) == "#")	continue

		var/list/List = splittext(line,"+")
		if(!List.len)					continue

		var/rank = ckeyEx(List[1])
		switch(rank)
			if(null,"")		continue
			if("Removed")	continue				//Reserved

		var/rights = 0
		for(var/i=2, i<=List.len, i++)
			switch(ckey(List[i]))
				if("@","prev")					rights |= previous_rights
				if("admin")						rights |= R_ADMIN
				if("ban")						rights |= R_BAN
				if("fun")						rights |= R_FUN
				if("server")					rights |= R_SERVER
				if("debug")						rights |= R_DEBUG
				if("permissions","rights")		rights |= R_PERMISSIONS
				if("varedit")					rights |= R_VAREDIT
				if("everything","host","all")	rights |= 65535
				if("sound","sounds")			rights |= R_SOUNDS
				if("spawn","create")			rights |= R_SPAWN

		admin_ranks[rank] = rights
		previous_rights = rights

	#ifdef TESTING
	var/msg = "Permission Sets Built:\n"
	for(var/rank in admin_ranks)
		msg += "\t[rank] - [admin_ranks[rank]]\n"
	testing(msg)
	#endif

/proc/load_admins()
	//clear the datums references
	admin_datums.Cut()
	for(var/client/C in admins)
		C.remove_admin_verbs()
		C.holder = null
	admins.Cut()

	if(config.admin_legacy_system)
		load_admin_ranks()

		//load text from file
		var/list/Lines = file2list("config/admins.txt")

		//process each line seperately
		for(var/line in Lines)
			if(!length(line))				continue
			if(copytext(line,1,2) == "#")	continue

			//Split the line at every "-"
			var/list/List = splittext(line, "-")
			if(!List.len)					continue

			//ckey is before the first "-"
			var/ckey = ckey(List[1])
			if(!ckey)						continue

			//rank follows the first "-"
			var/rank = ""
			if(List.len >= 2)
				rank = ckeyEx(List[2])

			//load permissions associated with this rank
			var/rights = admin_ranks[rank]

			//create the admin datum and store it for later use
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(directory[ckey])

	else
		//The current admin system uses SQL

		establish_db_connection()
		if(!dbcon.IsConnected())
			world.log << "Failed to connect to database in load_admins(). Reverting to legacy system."
			diary << "Failed to connect to database in load_admins(). Reverting to legacy system."
			config.admin_legacy_system = 1
			load_admins()
			return

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, rank, flags FROM erro_admin")
		query.Execute()
		while(query.NextRow())
			var/ckey = ckey(query.item[1])
			var/rank = query.item[2]
			if(rank == "Removed")	continue	//This person was de-adminned. They are only in the admin list for archive purposes.

			var/rights = query.item[3]
			if(istext(rights))	rights = text2num(rights)
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(directory[ckey])
		if(!admin_datums)
			world.log << "The database query in load_admins() resulted in no admins being added to the list. Reverting to legacy system."
			diary << "The database query in load_admins() resulted in no admins being added to the list. Reverting to legacy system."
			config.admin_legacy_system = 1
			load_admins()
			return
