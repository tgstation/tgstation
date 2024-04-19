// TODO: Prefs for autohiss?

/obj/item/organ/internal/tongue/rat/modify_speech(datum/source, list/speech_args)
	. = ..()
	var/message = lowertext(speech_args[SPEECH_MESSAGE])
	if(message == "привет" || message == "привет.")
		speech_args[SPEECH_MESSAGE] = "Сыррретствую вас!"
	if(message == "привет?")
		speech_args[SPEECH_MESSAGE] = "Мм... сыррретствую вас?"

/obj/item/organ/internal/tongue/fly/modify_speech(datum/source, list/speech_args)
	. = ..()
	var/static/regex/fly_buzz = new("з+", "g")
	var/static/regex/fly_buZZ = new("З+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "ззз")
		message = fly_buZZ.Replace(message, "ЗЗЗ")
		message = replacetext(message, "с", "з")
		message = replacetext(message, "С", "З")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/lizard/modify_speech(datum/source, list/speech_args)
	. = ..()
	var/static/regex/lizard_hiss = new("с+", "g")
	var/static/regex/lizard_hiSS = new("С+", "g")
	var/static/regex/lizard_che = new("ч+", "g")
	var/static/regex/lizard_cHE = new("Ч+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "ссс")
		message = lizard_hiSS.Replace(message, "ССС")
		message = lizard_che.Replace(message, "щ")
		message = lizard_cHE.Replace(message, "Щ")
	speech_args[SPEECH_MESSAGE] = message

/* TODO: Do these someday later
/obj/item/organ/internal/tongue/zombie/modify_speech(datum/source, list/speech_args)

/obj/item/organ/internal/tongue/snail/modify_speech(datum/source, list/speech_args)
*/
