/datum/element/muffles_speech
	element_flags = ELEMENT_BESPOKE

/datum/element/muffles_speech/Attach(datum/target, throw_amount, speed_amount)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

/datum/element/muffles_speech/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/element/muffles_speech/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(muzzle_talk))

/datum/element/muffles_speech/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_SAY)

/datum/element/muffles_speech/proc/muzzle_talk(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/spoken_message = speech_args[SPEECH_MESSAGE]
	if(spoken_message)
		var/list/words = splittext(spoken_message, " ")
		var/yell_suffix = copytext(spoken_message, findtext(spoken_message, "!"))
		spoken_message = ""

		for(var/ind = 1 to length(words))
			var/new_word = ""
			for(var/i = 1 to length(words[ind]) + rand(-1,1))
				new_word += "m"
			new_word += "f"
			words[ind] = yell_suffix ? uppertext(new_word) : new_word
		spoken_message = "[jointext(words, " ")][yell_suffix]"
	speech_args[SPEECH_MESSAGE] = spoken_message
