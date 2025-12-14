/**
 * Autopsy
 *
 * During the night, choose someone to check their role.
 */
/datum/mafia_ability/autopsy
	name = "Autopsy"
	ability_action = "perform an autopsy on"
	use_flags = CAN_USE_ON_OTHERS|CAN_USE_ON_DEAD

/datum/mafia_ability/autopsy/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	to_chat(host_role.body, span_warning("Your autopsy report on [target_role.body.real_name] \
		reveals their role was <b>[target_role.name]<b>."))
	return TRUE
