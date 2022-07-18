SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	can_fire = FALSE // We will control when we fire in this subsystem
	init_order = INIT_ORDER_SECURITY_LEVEL
	/// Currently set security level
	var/datum/security_level/current_security_level
	/// A list of initialised security level datums.
	var/list/available_levels = list()

/datum/controller/subsystem/security_level/Initialize(start_timeofday)
	. = ..()
	for(var/iterating_security_level_type in subtypesof(/datum/security_level))
		var/datum/security_level/new_security_level = new iterating_security_level_type
		available_levels[new_security_level.name] = new_security_level
	current_security_level = available_levels[number_level_to_text(SEC_LEVEL_GREEN)]

/datum/controller/subsystem/security_level/fire(resumed)
	if(!current_security_level.looping_sound) // No sound? No play.
		can_fire = FALSE
		return
	sound_to_playing_players(current_security_level.looping_sound)


/**
 * Sets a new security level as our current level
 *
 * This is how everything should change the security level.
 *
 * Arguments:
 * * new_level - The new security level that will become our current level
 */
/datum/controller/subsystem/security_level/proc/set_level(new_level)
	new_level = istext(new_level) ? new_level : number_level_to_text(new_level)
	if(new_level == current_security_level.name) // If we are already at the desired level, do nothing
		return

	var/datum/security_level/selected_level = available_levels[new_level]

	if(!selected_level)
		CRASH("set_level was called with an invalid security level([new_level])")

	announce_security_level(selected_level) // We want to announce BEFORE updating to the new level

	var/old_shuttle_call_time_mod = current_security_level.shuttle_call_time_mod // Need this before we set the new one

	SSsecurity_level.current_security_level = selected_level

	if(selected_level.looping_sound)
		wait = selected_level.looping_sound_interval
		can_fire = TRUE
	else
		can_fire = FALSE

	if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL) // By god this is absolutely shit
		old_shuttle_call_time_mod = 1 / old_shuttle_call_time_mod
		SSshuttle.emergency.modTimer(old_shuttle_call_time_mod)
		SSshuttle.emergency.modTimer(selected_level.shuttle_call_time_mod)

	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, selected_level.number_level)
	SSnightshift.check_nightshift()
	SSblackbox.record_feedback("tally", "security_level_changes", 1, selected_level.name)

/**
 * Handles announcements of the newly set security level
 *
 * Arguments:
 * * selected_level - The new security level that has been set
 */
/datum/controller/subsystem/security_level/proc/announce_security_level(datum/security_level/selected_level)
	if(selected_level.number_level > current_security_level.number_level) // We are elevating to this level.
		minor_announce(selected_level.elevating_to_announcemnt, "Attention! Security level elevated to [selected_level.name]:")
	else // Going down
		minor_announce(selected_level.lowering_to_announcement, "Attention! Security level lowered to [selected_level.name]:")
	if(selected_level.sound)
		sound_to_playing_players(selected_level.sound)

/**
 * Returns the current security level as a number
 */
/datum/controller/subsystem/security_level/proc/get_current_level_as_number()
	return current_security_level ? current_security_level.number_level : SEC_LEVEL_GREEN //Send a response in case the subsystem hasn't finished setting up yet

/**
 * Returns the current security level as text
 */
/datum/controller/subsystem/security_level/proc/get_current_level_as_text()
	return current_security_level ? current_security_level.name : "green"

/**
 * Converts a text security level to a number
 *
 * Arguments:
 * * level - The text security level to convert
 */
/datum/controller/subsystem/security_level/proc/text_level_to_number(text_level)
	var/datum/security_level/selected_level = available_levels[text_level]
	return selected_level?.number_level

/**
 * Converts a number security level to a text
 *
 * Arguments:
 * * level - The number security level to convert
 */
/datum/controller/subsystem/security_level/proc/number_level_to_text(number_level)
	for(var/iterating_level_text in available_levels)
		var/datum/security_level/iterating_security_level = available_levels[iterating_level_text]
		if(iterating_security_level.number_level == number_level)
			return iterating_security_level.name
