/obj/item/clothing/mask/fakemoustache/italian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/static/regex/words = new(@"(?<![a-zA-Zа-яёА-ЯЁ])[a-zA-Zа-яёА-ЯЁ]+?(?![a-zA-Zа-яёА-ЯЁ])", "g")
		message = replacetext(message, words, GLOBAL_PROC_REF(oguzok_moustache_words_replace_ru))

	speech_args[SPEECH_MESSAGE] = trim(message)

/proc/oguzok_moustache_words_replace_ru(word)
	var/static/list/oguzok_words
	if(!oguzok_words)
		oguzok_words = strings(OGUZOK_PHRASES_FILE, "oguzok")

	var/match = oguzok_words[lowertext(word)]
	if(!match)
		return word

	if(islist(match))
		match = pick(match)

	if(word == uppertext(word))
		return uppertext(match)

	if(word == capitalize(word))
		return capitalize(match)

	return match
