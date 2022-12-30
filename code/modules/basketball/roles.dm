/datum/basketball_role
	var/team = BASKETBALL_TEAM_HOME
	var/player_key
	var/mob/living/carbon/human/body

/datum/mafia_role/Destroy(force, ...)
	QDEL_NULL(body)
	. = ..()

/datum/mafia_role/proc/greet()
	to_chat(body,span_danger("You are the [name] team."))
	to_chat(body,span_danger("Play with your team to score and win. The total game length is 3 minutes."))
	// Add a basketball wiki at some point?
	// to_chat(body, "<span class='warningplain'><b>Be sure to read <a href=\"https://tgstation13.org/wiki/Mafia\">the wiki page</a> to learn more, if you have no idea what's going on.</b></span>")

/datum/mafia_role/hop
	name = "Head of Personnel"
	desc = "You can reveal yourself once per game, tripling your vote power but becoming unable to be protected!"
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	hud_icon = "hudheadofpersonnel"
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop
	winner_award = /datum/award/achievement/mafia/hop

	targeted_actions = list("Reveal")
	vote_potential = 3

/datum/mafia_role/hop/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || game.phase == MAFIA_PHASE_NIGHT || game.turn == 1 || target.game_status != MAFIA_ALIVE || target != src || (role_flags & ROLE_REVEALED))
		return FALSE

/datum/mafia_role/hop/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	reveal_role(game, TRUE)
	role_flags |= ROLE_VULNERABLE
	vote_power = 3
