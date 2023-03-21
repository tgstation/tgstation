/proc/lizard_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.lizard_names_male)]-[pick(GLOB.lizard_names_male)]"
	else
		return "[pick(GLOB.lizard_names_female)]-[pick(GLOB.lizard_names_female)]"

/proc/ethereal_name()
	var/tempname = "[pick(GLOB.ethereal_names)] [random_capital_letter()]"
	if(prob(65))
		tempname += random_capital_letter()
	return tempname

/proc/plasmaman_name()
	return "[pick(GLOB.plasmaman_names)] \Roman[rand(1,99)]"

/proc/moth_name()
	return "[pick(GLOB.moth_first)] [pick(GLOB.moth_last)]"

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

/proc/station_name()
	if(!GLOB.station_name)
		var/newname
		var/config_station_name = CONFIG_GET(string/stationname)
		if(config_station_name)
			newname = config_station_name
		else
			newname = new_station_name()

		set_station_name(newname)

	return GLOB.station_name

/proc/set_station_name(new_name)
	var/old_name = GLOB.station_name
	GLOB.station_name = new_name

	var/config_server_name = CONFIG_GET(string/servername)
	if(config_server_name)
		world.name = "[config_server_name][config_server_name == GLOB.station_name ? "" : ": [html_decode(GLOB.station_name)]"]"
	else
		world.name = html_decode(GLOB.station_name)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STATION_NAME_CHANGED, new_name, old_name)

/proc/new_station_name()
	var/random = rand(1,5)
	var/name = ""
	var/new_station_name = ""

	//Rare: Pre-Prefix
	if (prob(10))
		name = pick(GLOB.station_prefixes)
		new_station_name = name + " "
		name = ""

	if(prob(0.1))
		random = 999999999 //ridiculously long name in written numbers

	// Prefix
	var/holiday_name = length(GLOB.holidays) && pick(GLOB.holidays)
	if(holiday_name)
		var/datum/holiday/holiday = GLOB.holidays[holiday_name]
		if(istype(holiday, /datum/holiday/friday_thirteenth))
			random = 13
		name = holiday.getStationPrefix()
		//get normal name
	if(!name)
		name = pick(GLOB.station_names)
	if(name)
		new_station_name += name + " "

	// Suffix
	name = pick(GLOB.station_suffixes)
	new_station_name += name + " "

	// ID Number
	switch(random)
		if(1)
			new_station_name += "[rand(1, 99)]"
		if(2)
			new_station_name += pick(GLOB.greek_letters)
		if(3)
			new_station_name += "\Roman[rand(1,99)]"
		if(4)
			new_station_name += pick(GLOB.phonetic_alphabet)
		if(5)
			new_station_name += convert_integer_to_words(rand(-1,99), capitalise = TRUE)
		if(13)
			new_station_name += pick("13","XIII","Thirteen")
		if(999999999)
			new_station_name += convert_integer_to_words(rand(111111111,999999999), capitalise = TRUE)
	return new_station_name

/proc/syndicate_name()
	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	return name


//Traitors and traitor silicons will get these. Revs will not.
GLOBAL_VAR(syndicate_code_phrase) //Code phrase for traitors.
GLOBAL_VAR(syndicate_code_response) //Code response for traitors.

//Cached regex search - for checking if codewords are used.
GLOBAL_DATUM(syndicate_code_phrase_regex, /regex)
GLOBAL_DATUM(syndicate_code_response_regex, /regex)

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

	var/words = pick(//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
		50; 2,
		200; 3,
		50; 4,
		25; 5
	)

	var/list/safety = list(1,2,3)//Tells the proc which options to remove later on.
	var/nouns = strings(ION_FILE, "ionabstract")
	var/objects = strings(ION_FILE, "ionobjects")
	var/adjectives = strings(ION_FILE, "ionadjectives")
	var/threats = strings(ION_FILE, "ionthreats")
	var/foods = strings(ION_FILE, "ionfood")
	var/drinks = strings(ION_FILE, "iondrinks")
	var/locations = strings(LOCATIONS_FILE, "locations")

	var/list/names = list()
	for(var/datum/record/crew/target in GLOB.manifest.general)//Picks from crew manifest.
		names += target.name

	var/maxwords = words//Extra var to check for duplicates.

	for(words,words>0,words--)//Randomly picks from one of the choices below.

		if(words == 1 && (1 in safety) && (2 in safety))//If there is only one word remaining and choice 1 or 2 have not been selected.
			safety = list(pick(1,2))//Select choice 1 or 2.
		else if(words == 1 && maxwords == 2)//Else if there is only one word remaining (and there were two originally), and 1 or 2 were chosen,
			safety = list(3)//Default to list 3

		switch(pick(safety))//Chance based on the safety list.
			if(1)//1 and 2 can only be selected once each to prevent more than two specific names/places/etc.
				switch(rand(1,2))//Mainly to add more options later.
					if(1)
						if(names.len && prob(70))
							. += pick(names)
						else
							if(prob(10))
								. += pick(lizard_name(MALE),lizard_name(FEMALE))
							else
								var/new_name = pick(pick(GLOB.first_names_male,GLOB.first_names_female))
								new_name += " "
								new_name += pick(GLOB.last_names)
								. += new_name
					if(2)
						var/datum/job/job = pick(SSjob.joinable_occupations)
						if(job)
							. += job.title //Returns a job.
						else
							stack_trace("Failed to pick(SSjob.joinable_occupations) on generate_code_phrase()")
							. += "Bug"
				safety -= 1
			if(2)
				switch(rand(1,3))//Food, drinks, or places. Only selectable once.
					if(1)
						. += lowertext(pick(drinks))
					if(2)
						. += lowertext(pick(foods))
					if(3)
						. += lowertext(pick(locations))
				safety -= 2
			if(3)
				switch(rand(1,4))//Abstract nouns, objects, adjectives, threats. Can be selected more than once.
					if(1)
						. += lowertext(pick(nouns))
					if(2)
						. += lowertext(pick(objects))
					if(3)
						. += lowertext(pick(adjectives))
					if(4)
						. += lowertext(pick(threats))
		if(!return_list)
			if(words == 1)
				. += "."
			else
				. += ", "

/proc/odd_organ_name()
	return "[pick(GLOB.gross_adjectives)], [pick(GLOB.gross_adjectives)] organ"

/proc/hive_name()
	return "[pick(GLOB.hive_names)]-hive"

/**
 * returns an ic name of the tool needed
 * Arguments:
 * * tool_behaviour: the tool described!
 */
/proc/tool_behaviour_name(tool_behaviour)
	switch(tool_behaviour)
		if(TOOL_CROWBAR)
			return "a crowbar"
		if(TOOL_MULTITOOL)
			return "a multitool"
		if(TOOL_SCREWDRIVER)
			return "a screwdriver"
		if(TOOL_WIRECUTTER)
			return "a pair of wirecutters"
		if(TOOL_WRENCH)
			return "a wrench"
		if(TOOL_WELDER)
			return "a welder"
		if(TOOL_ANALYZER)
			return "an analyzer tool"
		if(TOOL_MINING)
			return "a mining implement"
		if(TOOL_SHOVEL)
			return "a digging tool"
		if(TOOL_RETRACTOR)
			return "a retractor"
		if(TOOL_HEMOSTAT)
			return "something to clamp bleeding"
		if(TOOL_CAUTERY)
			return "a cautery"
		if(TOOL_DRILL)
			return "a drilling tool"
		if(TOOL_SCALPEL)
			return "a fine cutting tool"
		if(TOOL_SAW)
			return "a saw"
		if(TOOL_BONESET)
			return "a bone setter"
		if(TOOL_KNIFE)
			return "a cutting tool"
		if(TOOL_BLOODFILTER)
			return "a blood filter"
		if(TOOL_ROLLINGPIN)
			return "a rolling pin"
		else
			return "something... but the gods didn't set this up right (Please report this bug)"
