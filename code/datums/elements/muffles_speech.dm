/datum/element/muffles_speech

/datum/element/muffles_speech/Attach(datum/target)
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
	if(source.slot_flags & slot)
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(muzzle_talk))
		RegisterSignal(user, COMSIG_MOB_PRE_EMOTED, PROC_REF(emote_override))

/datum/element/muffles_speech/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, list(COMSIG_MOB_PRE_EMOTED, COMSIG_MOB_SAY))

/datum/element/muffles_speech/proc/emote_override(mob/living/source, key, params, type_override, intentional, datum/emote/emote)
	SIGNAL_HANDLER
	if(!emote.hands_use_check && (emote.emote_type & EMOTE_AUDIBLE))
		source.audible_message("makes a [pick("strong ", "weak ", "")]noise.", audible_message_flags = EMOTE_MESSAGE|ALWAYS_SHOW_SELF_MESSAGE)
		return COMPONENT_CANT_EMOTE
	return NONE

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
