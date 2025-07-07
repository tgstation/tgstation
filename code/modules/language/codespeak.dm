/datum/language/codespeak
	name = "Codespeak"
	desc = "Syndicate operatives can use a series of codewords to convey complex information, while sounding like random concepts and drinks to anyone listening in."
	key = "t"
	default_priority = 0
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	icon_state = "codespeak"
	always_use_default_namelist = TRUE // No syllables anyways

/datum/language/codespeak/scramble_sentence(input, list/mutual_languages)
	var/sentence = read_word_cache(input)
	if(sentence)
		return sentence

	sentence = ""
	var/list/words = list()
	while(length_char(sentence) < length_char(input))
		words += generate_code_phrase(return_list=TRUE)
		sentence = jointext(words, ", ")

	sentence = capitalize(sentence)

	sentence += find_last_punctuation(input)

	write_word_cache(input, sentence)

	return sentence
