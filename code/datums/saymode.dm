/datum/saymode
	var/key
	var/mode

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE

/datum/saymode/changeling
	key = MODE_KEY_CHANGELING
	mode = MODE_CHANGELING

/datum/saymode/changeling/handle_message(mob/living/user, message, datum/language/language)
	//we can send the message
	if(!user.mind)
		return FALSE
	if(user.mind.has_antag_datum(/datum/antagonist/fallen_changeling))
		to_chat(user, span_changeling("<b>We're cut off from the hivemind! We've lost everything! EVERYTHING!!</b>"))
		return FALSE
	var/datum/antagonist/changeling/ling_sender = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!ling_sender)
		return FALSE
	if(HAS_TRAIT(user, CHANGELING_HIVEMIND_MUTE))
		to_chat(user, span_warning("The poison in the air hinders our ability to interact with the hivemind."))
		return FALSE

	user.log_talk(message, LOG_SAY, tag="changeling [ling_sender.changelingID]")
	var/msg = span_changeling("<b>[ling_sender.changelingID]:</b> [message]")

	//the recipients can recieve the message
	for(var/datum/antagonist/changeling/ling_reciever in GLOB.antagonists)
		if(!ling_reciever.owner)
			continue
		var/mob/living/ling_mob = ling_reciever.owner.current
		//removes types that override the presence of being changeling (for example, borged lings still can't hivemind chat)
		if(!isliving(ling_mob) || issilicon(ling_mob) || isbrain(ling_mob))
			continue
		// can't recieve messages on the hivemind right now
		if(HAS_TRAIT(ling_mob, CHANGELING_HIVEMIND_MUTE))
			continue
		to_chat(ling_mob, msg)

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, user)] [msg]")
	return FALSE

/datum/saymode/xeno
	key = "a"
	mode = MODE_ALIEN

/datum/saymode/xeno/handle_message(mob/living/user, message, datum/language/language)
	if(user.hivecheck())
		user.alien_talk(message)
	return FALSE


/datum/saymode/vocalcords
	key = MODE_KEY_VOCALCORDS
	mode = MODE_VOCALCORDS

/datum/saymode/vocalcords/handle_message(mob/living/user, message, datum/language/language)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/organ/internal/vocal_cords/V = C.get_organ_slot(ORGAN_SLOT_VOICE)
		if(V?.can_speak_with())
			V.handle_speech(message) //message
			V.speak_with(message) //action
	return FALSE


/datum/saymode/binary //everything that uses .b (silicons, drones)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY

/datum/saymode/binary/handle_message(mob/living/user, message, datum/language/language)
	if(isdrone(user))
		var/mob/living/basic/drone/drone_user = user
		drone_user.drone_chat(message)
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
