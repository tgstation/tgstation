	/datum/configuration/var/mentors_mobname_only = 0		// Only display mob name to mentors in mentorhelps
	/datum/configuration/var/mentor_legacy_system = 0		// Whether to use the legacy mentor system (flat file) instead of SQL

//Here we can load hippie specific config settings.
//They go in hippiestation/config/config.txt
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

		if(pos)
			name = lowertext(copytext(t, 1, pos))
		else
			name = lowertext(t)

		if(!name)
			continue

		if(type == "config") //Add new config options here.
			if ("mentor_mobname_only")
				config.mentors_mobname_only = 1
			if ("mentor_legacy_system")
				config.mentor_legacy_system = 1
		else
			GLOB.world_game_log << "Unknown setting in configuration: '[name]'"