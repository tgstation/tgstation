/datum/configuration
	var/mentors_mobname_only = 0	// Only display mob name to mentors in mentorhelps
	var/internet_address_to_use = null
	var/token_generator = null
	var/token_consumer = null

//Here we can load hippie specific config settings.
//They go in config/hippiestation_config.txt
/proc/load_hippie_config(filename, type = "config")
	var/list/Lines = world.file2list(filename)

	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		if(type == "config") //Add new config options here.
			switch(name)
				if ("mentor_mobname_only")
					config.mentors_mobname_only = 1
				if ("internet_address_to_use")
					config.internet_address_to_use = value
				if ("token_generator")
					config.token_generator = value
				if ("token_consumer")
					config.token_consumer = value
		else
			GLOB.world_game_log << "Unknown setting in configuration: '[name]'"
