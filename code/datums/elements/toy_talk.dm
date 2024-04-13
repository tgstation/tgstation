/**
 * Allows people to talk via the item with .l or .r
 *
 * Be sure to override [/atom/movable/proc/GetVoice] if you want the item's "voice" to not default to itself
 */
/datum/element/toy_talk

/datum/element/toy_talk/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_TALK_INTO, PROC_REF(do_talk))

/datum/element/toy_talk/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_TALK_INTO)

/datum/element/toy_talk/proc/do_talk(obj/item/source, mob/speaker, message, channel, list/spans, language, list/message_mods)
	SIGNAL_HANDLER

	if(!ismob(speaker) || message_mods[MODE_HEADSET] || message_mods[MODE_RELAY])
		return NONE

	message_mods[MODE_RELAY] = TRUE // Redundant (given NOPASS) but covers our bases
	speaker.log_talk(message, LOG_SAY, tag = "toy talk ([source])")
	source.say(message, language = language, sanitize = FALSE, message_mods = list(MODE_RELAY = TRUE))
	return NOPASS
