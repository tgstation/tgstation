/**
 * Seance
 *
 * An ability that doesn't give you any actions, you instead
 * gain the ability to speak with the dead during the Night.
 * We overwrite perform_action_target's parent to ensure this is triggered automatically.
 */
/datum/mafia_ability/seance
	name = "Speak with the Dead"
	action_priority = COMSIG_MAFIA_SUNDOWN
	use_flags = NONE

/datum/mafia_ability/seance/post_greet()
	RegisterSignal(host_role.body, COMSIG_MOB_SAY, PROC_REF(handle_message))
	ADD_TRAIT(host_role.body, TRAIT_MAFIA_SEANCE, MAFIA_TRAIT)

/**
 * handle_message
 *
 * During the night, Seancers speaking will instead be talking to deadchat.
 */
/datum/mafia_ability/seance/proc/handle_message(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if (host_role.mafia_game_controller.phase != MAFIA_PHASE_NIGHT)
		return FALSE

	var/phrase = html_decode(speech_args[SPEECH_MESSAGE])

	to_chat(host_role.body, span_changeling("MAFIA CHAPLAIN: [phrase]"))
	for(var/datum/mafia_role/dead_role in host_role.mafia_game_controller.all_roles - host_role.mafia_game_controller.living_roles)
		if(!HAS_TRAIT(dead_role.body, TRAIT_MAFIA_SEANCE))
			continue
		var/mob/dead/observer/dead_ghost = dead_role.body.get_ghost()
		if(dead_ghost)
			to_chat(dead_ghost, span_changeling("MAFIA CHAPLAIN: [phrase]"))

	speech_args[SPEECH_MESSAGE] = ""
