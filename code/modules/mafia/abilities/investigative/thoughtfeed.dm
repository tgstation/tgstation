/**
 * Thoughtfeeding
 *
 * During the night, thoughtfeeding will reveal the person's exact role.
 */
/datum/mafia_ability/thoughtfeeder
	name = "Thoughtfeed"
	ability_action = "feast on the memories of"

/datum/mafia_ability/thoughtfeeder/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	if((target_role.role_flags & ROLE_UNDETECTABLE))
		host_role.send_message_to_player(span_warning("[target_role.body.real_name]'s memories reveal that they are the [pick(game.all_roles - target_role)]."))
	else
		host_role.send_message_to_player(span_warning("[target_role.body.real_name]'s memories reveal that they are the [target_role.name]."))
	return TRUE
