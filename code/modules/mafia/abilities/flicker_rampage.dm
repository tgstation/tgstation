/**
 * Flicker/Rampage
 *
 * During the night, turns the lights off in a player's house.
 * If they visit someone with the lights off again, they will kill all players they previously visited.
 */
/datum/mafia_ability/flicker_rampage
	name = "Flicker/Rampage"
	ability_action = "attempt to attack or darken"

	///List of all players in the dark, which we can rampage.
	var/list/datum/mafia_role/darkened_players = list()

/datum/mafia_ability/flicker_rampage/perform_action(datum/mafia_controller/game)
	if(!validate_action_target(game))
		return ..()

	if(!(target_role in darkened_players))
		to_chat(target_role.body, span_userdanger("The lights begin to flicker and dim. You're in danger."))
		darkened_players += target_role
		return ..()

	for(var/datum/mafia_role/dead_players as anything in darkened_players)
		to_chat(dead_players.body, span_userdanger("A shadowy figure appears out of the darkness!"))
		dead_players.kill(game, src, FALSE)
		darkened_players -= dead_players
