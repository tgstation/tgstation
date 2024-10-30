// TODO: Prefs for autohiss?

/obj/item/organ/tongue/rat/modify_speech(datum/source, list/speech_args)
	. = ..()
	var/message = lowertext(speech_args[SPEECH_MESSAGE])
	if(message == "привет" || message == "привет.")
		speech_args[SPEECH_MESSAGE] = "Сыррретствую вас!"
	if(message == "привет?")
		speech_args[SPEECH_MESSAGE] = "Мм... сыррретствую вас?"
