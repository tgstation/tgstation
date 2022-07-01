/datum/saymode
	var/key
	var/mode

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE

/datum/saymode/xeno
	key = "a"
	mode = MODE_ALIEN

/datum/saymode/xeno/handle_message(mob/living/user, message, datum/language/language)
	if(user.hivecheck())
		user.alien_talk(message)
	return FALSE


/datum/saymode/vocal_cords
	key = MODE_KEY_vocal_cords
	mode = MODE_vocal_cords

/datum/saymode/vocal_cords/handle_message(mob/living/user, message, datum/language/language)
	if(iscarbon(user))
		var/mob/living/carbon/speaking_carbon = user
		var/obj/item/organ/internal/vocal_cords/active_cords = speaking_carbon.getorganslot(ORGAN_SLOT_VOICE)
		if(active_cords?.can_speak_with())
			active_cords.handle_speech(message) //message
			active_cords.speak_with(message) //action
	return FALSE


/datum/saymode/binary //everything that uses .b (silicons, drones)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY

/datum/saymode/binary/handle_message(mob/living/user, message, datum/language/language)
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		D.drone_chat(message)
		return FALSE
	if(user.binarycheck())
		user.robot_talk(message)
		return FALSE
	return FALSE


/datum/saymode/holopad
	key = "h"
	mode = MODE_HOLOPAD

/datum/saymode/holopad/handle_message(mob/living/user, message, datum/language/language)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		AI.holopad_talk(message, language)
		return FALSE
	return TRUE

/datum/saymode/mafia
	key = "j"
	mode = MODE_MAFIA

/datum/saymode/mafia/handle_message(mob/living/user, message, datum/language/language)
	var/datum/mafia_controller/MF = GLOB.mafia_game
	if (!MF)
		return TRUE
	var/datum/mafia_role/R = MF.player_role_lookup[user]
	if(!R || R.team != "mafia")
		return TRUE
	MF.send_message(span_changeling("<b>[R.body.real_name]:</b> [message]"),"mafia")
	return FALSE
