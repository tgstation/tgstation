/**
 * Voting
 *
 * During the vote period, voting for someone is showing your intent to get them lynched.
 */
/datum/mafia_ability/voting
	name = "Vote"
	ability_action = "vote for hanging"
	valid_use_period = MAFIA_PHASE_VOTING
	action_priority = null

/datum/mafia_ability/voting/perform_action(datum/mafia_controller/game, datum/mafia_role/day_target)
	if(!validate_action_target(game))
		return ..()
	game.vote_for(host_role, day_target, vote_type = "Day")

	return ..()
