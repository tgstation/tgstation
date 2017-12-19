/proc/load_mentors(force_legacy = FALSE)
	//clear the datums references
	GLOB.mentors.Cut()
	GLOB.mentor_datums.Cut()

	if(!force_legacy && !CONFIG_GET(flag/admin_legacy_system))
		if(!SSdbcore.Connect())
			log_world("Failed to connect to database in load_mentors().")
			message_admins("Failed to connect to database in load_mentors().")
			load_mentors(TRUE)
			return

		var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor")]")
		query.Execute()
		while(query.NextRow())
			var/ckey = ckey(query.item[1])
			var/datum/mentor/D = new(ckey)				//create the mentor datum and store it for later use
			if(!D)	continue									//will occur if an invalid rank is provided
			D.associate(GLOB.directory[ckey])	//find the client for a ckey if they are connected and associate them with the new mentor datum
	else
		log_world("Using legacy mentor system.")
		var/list/Lines = world.file2list("config/mentors.txt")

		//process each line seperately
		for(var/line in Lines)
			if(!length(line))				continue
			if(findtextEx(line,"#",1,2))	continue

			//ckey is before the first "="
			var/ckey = ckey(line)
			if(!ckey)						continue

			var/datum/mentor/D = new(ckey)	//create the admin datum and store it for later use
			if(!D)	continue									//will occur if an invalid rank is provided
			D.associate(GLOB.directory[ckey])	//find the client for a ckey if they are connected and associate them with the new admin datum

	#ifdef TESTING
	var/msg = "mentors Built:\n"
	for(var/ckey in GLOB.mentor_datums)
		msg += "\t[ckey] - mentor\n"
	testing(msg)
	#endif