/datum/language/codespeak
	name = "Codespeak"
	desc = "Syndicate operatives can use a series of codewords to convey complex information, while sounding like random concepts and drinks to anyone listening in."
	key = "t"
	default_priority = 0
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	icon_state = "codespeak"
	always_use_default_namelist = TRUE // No syllables anyways

/datum/language/codespeak/scramble(input)
	var/lookup = check_cache(input)
	if(lookup)
		return lookup

	. = ""
	var/list/words = list()
	while(length_char(.) < length_char(input))
		words += generate_code_phrase(return_list=TRUE)
		. = jointext(words, ", ")

	. = capitalize(.)

	var/input_ending = copytext_char(input, -1)

	var/static/list/endings
	if(!endings)
		endings = list("!", "?", ".")

	if(input_ending in endings)
		. += input_ending

	add_to_cache(input, .)
