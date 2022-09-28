/datum/saymode
	var/key
	var/mode

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE

// ling status, their interaction with the hivemind

///not in the hive
#define LINGHIVE_NONE 0
///lost their powers, gets a special message
#define LINGHIVE_FALLEN 1
///can speak normally, unless they have the CHANGELING_HIVEMIND_MUTE trait
#define LINGHIVE_LING 2

/datum/saymode/changeling
	key = MODE_KEY_CHANGELING
	mode = MODE_CHANGELING

/datum/saymode/changeling/handle_message(mob/living/user, message, datum/language/language)
	switch(lingcheck(user))
		if(LINGHIVE_FALLEN)
			to_chat(user, "<span class='changeling bold'>We're cut off from the hivemind! We've lost everything! EVERYTHING!!</span>")
		if(LINGHIVE_LING)
			if (HAS_TRAIT(user, CHANGELING_HIVEMIND_MUTE))
				to_chat(user, "<span class='warning'>The poison in the air hinders our ability to interact with the hivemind.</span>")
				return FALSE
			var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
			var/msg = span_changeling("<b>[changeling.changelingID]:</b> [message]")
			user.log_talk(message, LOG_SAY, tag="changeling [changeling.changelingID]")
			for(var/mob/player as anything in GLOB.player_list)
				if(player in GLOB.dead_mob_list)
					var/link = FOLLOW_LINK(player, user)
					to_chat(player, "[link] [msg]")
				else
					if(lingcheck(player) == LINGHIVE_LING && !HAS_TRAIT(player, CHANGELING_HIVEMIND_MUTE))
						to_chat(player, msg)
	return FALSE

///Returns what status a mob has in the hivemind, see LINGHIVE defines above
/datum/saymode/changeling/proc/lingcheck(mob/player)
	//removes types that override the presence of being changeling (for example, borged lings still can't hivemind chat)
	if(!isliving(player) || issilicon(player) || isbrain(player))
		return LINGHIVE_NONE

	var/mob/living/living_player = player
	if(living_player.mind)
		if(living_player.mind.has_antag_datum(/datum/antagonist/changeling))
			return LINGHIVE_LING
		if(living_player.mind.has_antag_datum(/datum/antagonist/fallen_changeling))
			return LINGHIVE_FALLEN
	return LINGHIVE_NONE

#undef LINGHIVE_NONE
#undef LINGHIVE_FALLEN
#undef LINGHIVE_LING

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
		var/obj/item/organ/internal/vocal_cords/V = C.getorganslot(ORGAN_SLOT_VOICE)
		if(V?.can_speak_with())
			V.handle_speech(message) //message
			V.speak_with(message) //action
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
