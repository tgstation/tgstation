/obj/item/clothing/mask/fakemoustache
	name = "накладные усы"
	desc = "Осторожно: усы накладные."

/obj/item/clothing/mask/fakemoustache/italian
	name = "итальянские усы"
	desc = "Изготовлен из настоящих итальянских волосков для усов. Дает владельцу непреодолимое желание дико жестикулировать."

/obj/item/clothing/mask/fakemoustache/italian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/static/regex/words = new(@"(?<![a-zA-Zа-яёА-ЯЁ])[a-zA-Zа-яёА-ЯЁ]+?(?![a-zA-Zа-яёА-ЯЁ])", "g")
		message = replacetext(message, words, GLOBAL_PROC_REF(italian_words_replace))

		if(prob(5))
			message += pick(" Равиоли, равиоли, подскажи мне формуоли!"," Мамма-мия!"," Мамма-мия! Какая острая фрикаделька!", " Ла ла ла ла ла фуникули+ фуникуля+!", " Вордс Реплаке!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/proc/italian_words_replace(word)
	var/static/list/italian_words
	if(!italian_words)
		italian_words = strings("italian_replacement_ru.json", "italian")

	var/match = italian_words[lowertext(word)]
	if(!match)
		return word

	if(islist(match))
		match = pick(match)

	if(word == uppertext(word))
		return uppertext(match)

	if(word == capitalize(word))
		return capitalize(match)

	return match
