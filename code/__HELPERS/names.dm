/**
 * Generate a random name based off of one of the roundstart languages
 *
 * * gender - What gender to pick from. Picks between male, female if not provided.
 * * unique - If the name should be unique, IE, avoid picking names that mobs already have.
 * * list/language_weights - A list of language weights to pick from.
 * If not provided, it will default to a list of roundstart languages, with common being the most likely.
 */
/proc/generate_random_name(gender, unique, list/language_weights)
	if(isnull(language_weights))
		language_weights = list()
		for(var/lang_type in GLOB.uncommon_roundstart_languages)
			language_weights[lang_type] = 1
		language_weights[/datum/language/common] = 20

	var/datum/language/picked = GLOB.language_datum_instances[pick_weight(language_weights)]
	if(unique)
		return picked.get_random_unique_name(gender)
	return picked.get_random_name(gender)

/**
 * Generate a random name based off of a species
 * This will pick a name from the species language, and avoid picking common if there are alternatives
 *
 * * gender - What gender to pick from. Picks between male, female if not provided.
 * * unique - If the name should be unique, IE, avoid picking names that mobs already have.
 * * datum/species/species_type - The species to pick from
 * * include_all - Makes the generated name a mix of all the languages the species can speak rather than just one of them
 * Does this on a per-name basis, IE "Lizard first name, uncommon last name".
 */
/proc/generate_random_name_species_based(gender, unique, datum/species/species_type, include_all = FALSE)
	ASSERT(ispath(species_type, /datum/species))
	var/datum/language_holder/holder = GLOB.prototype_language_holders[species_type::species_language_holder]

	var/list/languages_to_pick_from = list()
	for(var/language in holder.spoken_languages)
		languages_to_pick_from[language] = 1

	if(length(languages_to_pick_from) >= 2)
		// Basically, if we have alternatives, don't pick common it's boring
		languages_to_pick_from -= /datum/language/common

	if(!include_all || length(languages_to_pick_from) <= 1)
		return generate_random_name(gender, unique, languages_to_pick_from)

	var/list/name_parts = list()
	for(var/lang_type in shuffle(languages_to_pick_from))
		name_parts += GLOB.language_datum_instances[lang_type].get_random_name(gender, name_count = 1, force_use_syllables = TRUE)
	return jointext(name_parts, " ")

/**
 * Generates a random name for the mob based on their gender or species (for humans)
 *
 * * unique - If the name should be unique, IE, avoid picking names that mobs already have.
 */
/mob/proc/generate_random_mob_name(unique)
	return generate_random_name_species_based(gender, unique, /datum/species/human)

/mob/living/carbon/generate_random_mob_name(unique)
	return generate_random_name_species_based(gender, unique, dna?.species?.type || /datum/species/human)

/mob/living/silicon/generate_random_mob_name(unique)
	return generate_random_name(gender, unique, list(/datum/language/machine = 1))

/mob/living/basic/drone/generate_random_mob_name(unique)
	return generate_random_name(gender, unique, list(/datum/language/machine = 1))

/mob/living/basic/bot/generate_random_mob_name(unique)
	return generate_random_name(gender, unique, list(/datum/language/machine = 1))

/mob/living/simple_animal/bot/generate_random_mob_name(unique)
	return generate_random_name(gender, unique, list(/datum/language/machine = 1))

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
						if(length(names) && prob(70))
							. += pick(names)
						else
							. += generate_random_name()

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
						. += LOWER_TEXT(pick(drinks))
					if(2)
						. += LOWER_TEXT(pick(foods))
					if(3)
						. += LOWER_TEXT(pick(locations))
				safety -= 2
			if(3)
				switch(rand(1,4))//Abstract nouns, objects, adjectives, threats. Can be selected more than once.
					if(1)
						. += LOWER_TEXT(pick(nouns))
					if(2)
						. += LOWER_TEXT(pick(objects))
					if(3)
						. += LOWER_TEXT(pick(adjectives))
					if(4)
						. += LOWER_TEXT(pick(threats))
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
 * Generate a name devices
 *
 * Creates a randomly generated tag or name for devices or anything really
 * it keeps track of a special list that makes sure no name is used more than
 * once
 *
 * args:
 * * len (int)(Optional) Default=5 The length of the name
 * * prefix (string)(Optional) static text in front of the random name
 * * postfix (string)(Optional) static text in back of the random name
 * Returns (string) The generated name
 */
/proc/assign_random_name(len=5, prefix="", postfix="")
	//DO NOT REMOVE NAMES HERE UNLESS YOU KNOW WHAT YOU'RE DOING
	//All names already used
	var/static/list/used_names = list()

	var/static/valid_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var/list/new_name = list()
	var/text
	// machine id's should be fun random chars hinting at a larger world
	do
		new_name.Cut()
		new_name += prefix
		for(var/i = 1 to len)
			new_name += valid_chars[rand(1,length(valid_chars))]
		new_name += postfix
		text = new_name.Join()
	while(used_names[text])
	used_names[text] = TRUE
	return text


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
