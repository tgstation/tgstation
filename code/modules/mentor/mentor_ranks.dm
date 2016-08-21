/proc/load_mentors()
	//clear the datums references
	mentor_datums.Cut()
	mentors.Cut()

	if(!config.mentor_legacy_system)
		establish_db_connection()
		if(!dbcon.IsConnected())
			world.log << "Failed to connect to database in load_mentors()."
			diary << "Failed to connect to database in load_mentors()."
			config.mentor_legacy_system = 1
			load_mentors()
			return

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("mentor")]")
		query.Execute()
		while(query.NextRow())
			var/ckey = ckey(query.item[1])
			var/datum/mentors/D = new(ckey)				//create the mentor datum and store it for later use
			if(!D)	continue									//will occur if an invalid rank is provided
			D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new mentor datum
	else
		world.log << "Using legacy mentor system."
		var/list/Lines = file2list("config/mentors.txt")

		//process each line seperately
		for(var/line in Lines)
			if(!length(line))				continue
			if(findtextEx(line,"#",1,2))	continue

			//ckey is before the first "="
			var/ckey = ckey(line)
			if(!ckey)						continue

			var/datum/mentors/D = new(ckey)	//create the admin datum and store it for later use
			if(!D)	continue									//will occur if an invalid rank is provided
			D.associate(directory[ckey])	//find the client for a ckey if they are connected and associate them with the new admin datum

	#ifdef TESTING
	var/msg = "mentors Built:\n"
	for(var/ckey in mentor_datums)
		var/datum/mentors/D = mentor_datums[ckey]
		msg += "\t[ckey] - [D.rank.name]\n"
	testing(msg)
	#endif