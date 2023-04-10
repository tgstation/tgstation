//just helps read better
#define FUGITIVE_NOT_PRESERVING 0//will not become night immune tonight
#define FUGITIVE_WILL_PRESERVE 1 //will become night immune tonight

/datum/mafia_role/fugitive
	name = "Fugitive"
	desc = "You're on the run. You can become immune to night kills exactly twice, and you win by surviving to the end of the game with anyone."
	win_condition = "survive to the end of the game, with anyone"
	revealed_outfit = /datum/outfit/mafia/fugitive
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudfugitive"
	revealed_icon = "fugitive"
	winner_award = /datum/award/achievement/mafia/fugitive

	role_unique_actions = list("Self Preservation")
	var/charges = 2
	var/protection_status = FUGITIVE_NOT_PRESERVING


/datum/mafia_role/fugitive/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN, PROC_REF(night_start))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END, PROC_REF(night_end))
	RegisterSignal(game,COMSIG_MAFIA_GAME_END, PROC_REF(survived))

/datum/mafia_role/fugitive/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!charges)
		to_chat(body,span_danger("You're out of supplies and cannot protect yourself anymore."))
		return
	if(game.phase == MAFIA_PHASE_NIGHT)
		to_chat(body,span_danger("You don't have time to prepare, night has already arrived."))
		return
	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,span_danger("You decide to not prepare tonight."))
	else
		to_chat(body,span_danger("You decide to prepare for a horrible night."))
	protection_status = !protection_status

/datum/mafia_role/fugitive/proc/night_start(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,span_danger("Your preparations are complete. Nothing could kill you tonight!"))
		RegisterSignal(src,COMSIG_MAFIA_ON_KILL, PROC_REF(prevent_death))

/datum/mafia_role/fugitive/proc/night_end(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == FUGITIVE_WILL_PRESERVE)
		charges--
		UnregisterSignal(src,COMSIG_MAFIA_ON_KILL)
		to_chat(body,span_danger("You are no longer protected. You have [charges] use[charges == 1 ? "" : "s"] left of your power."))
		protection_status = FUGITIVE_NOT_PRESERVING

/datum/mafia_role/fugitive/proc/prevent_death(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	to_chat(body,span_userdanger("You were attacked! Luckily, you were ready for this!"))
	return MAFIA_PREVENT_KILL

/datum/mafia_role/fugitive/proc/survived(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(game_status == MAFIA_ALIVE)
		game.award_role(winner_award, src)
		game.send_message("<span class='big comradio'>!! FUGITIVE VICTORY !!</span>")

#undef FUGITIVE_NOT_PRESERVING
#undef FUGITIVE_WILL_PRESERVE
