/obj/item/clothing/mask/fakemoustache/italian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/static/regex/words = new(@"(?<![a-zA-Zа-яёА-ЯЁ])[a-zA-Zа-яёА-ЯЁ]+?(?![a-zA-Zа-яёА-ЯЁ])", "g")
		message_admins(message) ///
		message = replacetext(message, words, GLOBAL_PROC_REF(italian_moustache_words_replace_ru))
		message_admins("итоговое сообщение - [message]") ///
		if(prob(3))
			message += pick("Белиссимо!"," Мамма-мия!", " Ла ла ла!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/proc/italian_moustache_words_replace_ru(word)
	var/static/list/italian_words
	if(!italian_words)
		italian_words = strings("italian_replacement_ru.json", "italian")
	message_admins("это пришло в фукцию - [word]") ///
	var/match = italian_words[lowertext(word)]

	message_admins("нашел замену - [match]") ///
	if(!match)
		return word

	if(islist(match))
		match = pick(match)

	if(word == uppertext(word))
		return uppertext(match)

	if(word == capitalize(word))
		return capitalize(match)

	return match
