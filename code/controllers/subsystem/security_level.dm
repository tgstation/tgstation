SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	/// Currently set security level
	var/datum/security_level/current_security_level
	/// A list of initialised security level datums.
	var/list/datum/security_level/available_levels = list()

/datum/controller/subsystem/security_level/Initialize(start_timeofday)
	. = ..()
	for(var/datum/security_level/iterating_security_level_type in typesof(/datum/security_level))
		available_levels[initial(iterating_security_level_type.number_level)] += new iterating_security_level_type
	current_security_level = available_levels[SEC_LEVEL_GREEN]

/**
 * Sets a new security level as our current level
 *
 * This is how everything should change the security level.
 *
 * Arguments:
 * * new_level The new security level that will become our current level
 */
/datum/controller/subsystem/security_level/proc/set_level(new_level)
	new_level = isnum(new_level) ? new_level : string_level_to_number(new_level)
	if(new_level == current_security_level.number_level) // If we are already at the desired level, do nothing
		return

	var/datum/security_level/selected_level = available_levels[new_level]

	if(!selected_level)
		CRASH("set_level was called with an invalid security level([new_level])")

	announce_security_level(selected_level) // We want to announce BEFORE updating to the new level

	SSsecurity_level.current_security_level = selected_level

	if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
		SSshuttle.emergency.modTimer(selected_level.shuttle_call_time_mod)

	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, new_level)
	SSnightshift.check_nightshift()
	SSblackbox.record_feedback("tally", "security_level_changes", 1, selected_level.name)

/**
 * Handles announcements of the newly set security level
 *
 * Arguments:
 * * new_level The new security level that has been set
 */
/datum/controller/subsystem/security_level/proc/announce_security_level(datum/security_level/selected_level)
	if(selected_level.number_level > current_security_level.number_level) // We are elevating to this level.
		minor_announce(selected_level.elevating_to_announcemnt, "Attention! Security level elevated to [selected_level.name]:")
	else // Going down
		minor_announce(selected_level.lowering_to_announcement, "Attention! Security level lowered to [selected_level.name]:")
	if(selected_level.sound)
		sound_to_playing_players(selected_level.sound)

/**
 * Returns the current security level
 *
 * Arguments:
 * * as_string Whether to return the security level as a string or as a number
 */
/datum/controller/subsystem/security_level/proc/get_current_level(as_number)
	if(as_number)
		return current_security_level.number_level
	else
		return current_security_level.name

/**
 * Converts a string security level to a number
 *
 * Arguments:
 * * level The string security level to convert
 */
/datum/controller/subsystem/security_level/proc/string_level_to_number(string_level)
	string_level = lowertext(string_level)
	for(var/datum/security_level/iterating_security_level as anything in available_levels)
		if(iterating_security_level.name == string_level)
			return iterating_security_level.number_level

/**
 * Converts a number security level to a string
 *
 * Arguments:
 * * level The number security level to convert
 */
/datum/controller/subsystem/security_level/proc/number_level_to_string(number_level)
	return available_levels[number_level].name
