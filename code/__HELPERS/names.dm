#define ION_FILE "ion_laws.json"

/proc/lizard_name(gender)
	if(gender == MALE)
		return "[SSrng.pick_from_list(GLOB.lizard_names_male)]-[SSrng.pick_from_list(GLOB.lizard_names_male)]"
	else
		return "[SSrng.pick_from_list(GLOB.lizard_names_female)]-[SSrng.pick_from_list(GLOB.lizard_names_female)]"

/proc/plasmaman_name()
	return "[SSrng.pick_from_list(GLOB.plasmaman_names)] \Roman[SSrng.random(1,99)]"

/proc/church_name()
	var/static/church_name
	if (church_name)
		return church_name

	var/name = ""

	name += SSrng.pick_from_list("Holy", "United", "First", "Second", "Last")

	if (SSrng.probability(20))
		name += " Space"

	name += " " + SSrng.pick_from_list("Church", "Cathedral", "Body", "Worshippers", "Movement", "Witnesses")
	name += " of [religion_name()]"

	return name

GLOBAL_VAR(command_name)
/proc/command_name()
	if (GLOB.command_name)
		return GLOB.command_name

	var/name = "Central Command"

	GLOB.command_name = name
	return name

/proc/change_command_name(name)

	GLOB.command_name = name

	return name

/proc/religion_name()
	var/static/religion_name
	if (religion_name)
		return religion_name

	var/name = ""

	name += SSrng.pick_from_list("bee", "science", "edu", "captain", "assistant", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "goon", "robot", "ivor", "hobnob")
	name += SSrng.pick_from_list("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")

	return capitalize(name)

/proc/station_name()
	if(!GLOB.station_name)
		var/newname
		if(config && config.station_name)
			newname = config.station_name
		else
			newname = new_station_name()

		set_station_name(newname)

	return GLOB.station_name

/proc/set_station_name(newname)
	GLOB.station_name = newname

	if(config && config.server_name)
		world.name = "[config.server_name][config.server_name==GLOB.station_name ? "" : ": [GLOB.station_name]"]"
	else
		world.name = GLOB.station_name


/proc/new_station_name()
	var/random = SSrng.random(1,5)
	var/name = ""
	var/new_station_name = ""

	//Rare: Pre-Prefix
	if (SSrng.probability(10))
		name = SSrng.pick_from_list(GLOB.station_prefixes)
		new_station_name = name + " "
		name = ""

	// Prefix
	for(var/holiday_name in SSevents.holidays)
		if(holiday_name == "Friday the 13th")
			random = 13
		var/datum/holiday/holiday = SSevents.holidays[holiday_name]
		name = holiday.getStationPrefix()
		//get normal name
	if(!name)
		name = SSrng.pick_from_list(GLOB.station_names)
	if(name)
		new_station_name += name + " "

	// Suffix
	name = SSrng.pick_from_list(GLOB.station_suffixes)
	new_station_name += name + " "

	// ID Number
	switch(random)
		if(1)
			new_station_name += "[SSrng.random(1, 99)]"
		if(2)
			new_station_name += SSrng.pick_from_list(GLOB.greek_letters)
		if(3)
			new_station_name += "\Roman[SSrng.random(1,99)]"
		if(4)
			new_station_name += SSrng.pick_from_list(GLOB.phonetic_alphabet)
		if(5)
			new_station_name += SSrng.pick_from_list(GLOB.numbers_as_words)
		if(13)
			new_station_name += SSrng.pick_from_list("13","XIII","Thirteen")
	return new_station_name

/proc/syndicate_name()
	var/static/syndicate_name
	if (syndicate_name)
		return syndicate_name

	var/name = ""

	// Prefix
	name += SSrng.pick_from_list("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	// Suffix
	if (SSrng.probability(80))
		name += " "

		// Full
		if (SSrng.probability(60))
			name += SSrng.pick_from_list("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += SSrng.pick_from_list("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += SSrng.pick_from_list("", "-")
			name += SSrng.pick_from_list("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += SSrng.pick_from_list("-", "*", "")
		name += SSrng.pick_from_list("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	syndicate_name = name
	return name


//Traitors and traitor silicons will get these. Revs will not.
GLOBAL_VAR(syndicate_code_phrase) //Code phrase for traitors.
GLOBAL_VAR(syndicate_code_response) //Code response for traitors.

	/*
	Should be expanded.
	How this works:
	Instead of "I'm looking for James Smith," the traitor would say "James Smith" as part of a conversation.
	Another traitor may then respond with: "They enjoy running through the void-filled vacuum of the derelict."
	The phrase should then have the words: James Smith.
	The response should then have the words: run, void, and derelict.
	This way assures that the code is suited to the conversation and is unpredicatable.
	Obviously, some people will be better at this than others but in theory, everyone should be able to do it and it only enhances roleplay.
	Can probably be done through "{ }" but I don't really see the practical benefit.
	One example of an earlier system is commented below.
	/N
	*/

/proc/generate_code_phrase(return_list=FALSE)//Proc is used for phrase and response in master_controller.dm

	if(!return_list)
		. = ""
	else
		. = list()

//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
	var/words = text2num(pickweight(list(
		"2" = 50,
		"3" = 200,
		"4" = 50,
		"5" = 25
	)))

	var/list/safety = list(1,2,3)//Tells the proc which options to remove later on.
	var/nouns = strings(ION_FILE, "ionabstract")
	var/objects = strings(ION_FILE, "ionobjects")
	var/adjectives = strings(ION_FILE, "ionadjectives")
	var/threats = strings(ION_FILE, "ionthreats")
	var/foods = strings(ION_FILE, "ionfood")
	var/drinks = strings(ION_FILE, "iondrinks")
	var/list/locations = GLOB.teleportlocs.len ? GLOB.teleportlocs : drinks //if null, defaults to drinks instead.

	var/list/names = list()
	for(var/datum/data/record/t in GLOB.data_core.general)//Picks from crew manifest.
		names += t.fields["name"]

	var/maxwords = words//Extra var to check for duplicates.

	for(words,words>0,words--)//Randomly picks from one of the choices below.

		if(words==1&&(1 in safety)&&(2 in safety))//If there is only one word remaining and choice 1 or 2 have not been selected.
			safety = list(SSrng.pick_from_list(1,2))//Select choice 1 or 2.
		else if(words==1&&maxwords==2)//Else if there is only one word remaining (and there were two originally), and 1 or 2 were chosen,
			safety = list(3)//Default to list 3

		switch(SSrng.pick_from_list(safety))//Chance based on the safety list.
			if(1)//1 and 2 can only be selected once each to prevent more than two specific names/places/etc.
				switch(SSrng.random(1,2))//Mainly to add more options later.
					if(1)
						if(names.len&&SSrng.probability(70))
							. += SSrng.pick_from_list(names)
						else
							if(SSrng.probability(10))
								. += SSrng.pick_from_list(lizard_name(MALE),lizard_name(FEMALE))
							else
								var/new_name = SSrng.pick_from_list(SSrng.pick_from_list(GLOB.first_names_male,GLOB.first_names_female))
								new_name += " "
								new_name += SSrng.pick_from_list(GLOB.last_names)
								. += new_name
					if(2)
						. += SSrng.pick_from_list(get_all_jobs())//Returns a job.
				safety -= 1
			if(2)
				switch(SSrng.random(1,3))//Food, drinks, or things. Only selectable once.
					if(1)
						. += lowertext(SSrng.pick_from_list(drinks))
					if(2)
						. += lowertext(SSrng.pick_from_list(foods))
					if(3)
						. += lowertext(SSrng.pick_from_list(locations))
				safety -= 2
			if(3)
				switch(SSrng.random(1,4))//Abstract nouns, objects, adjectives, threats. Can be selected more than once.
					if(1)
						. += lowertext(SSrng.pick_from_list(nouns))
					if(2)
						. += lowertext(SSrng.pick_from_list(objects))
					if(3)
						. += lowertext(SSrng.pick_from_list(adjectives))
					if(4)
						. += lowertext(SSrng.pick_from_list(threats))
		if(!return_list)
			if(words==1)
				. += "."
			else
				. += ", "
