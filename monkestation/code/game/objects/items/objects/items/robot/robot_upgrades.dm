// Monkestation change: UwU-speak module for borgs because I hate borg players
/obj/item/borg/upgrade/uwu
	name = "cyborg UwU-speak \"upgrade\""
	desc = "As if existence as an artificial being wasn't torment enough for the unit OR the crew."
	icon_state = "cyborg_upgrade"

/obj/item/borg/upgrade/uwu/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	RegisterSignal(R, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/item/borg/upgrade/uwu/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]

	if(message[1] != "*")
		message = replacetext(message, "ne", "nye")
		message = replacetext(message, "nu", "nyu")
		message = replacetext(message, "na", "nya")
		message = replacetext(message, "no", "nyo")
		message = replacetext(message, "ove", "uv")
		message = replacetext(message, "r", "w")
		message = replacetext(message, "l", "w")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/borg/upgrade/uwu/deactivate(mob/living/silicon/robot/R, user = usr)
	UnregisterSignal(R, COMSIG_MOB_SAY)
//
