/datum/mafia_role/lawyer
	name = "Lawyer"
	desc = "You can choose a person during the day to provide extensive legal advice to during the night, preventing night actions."
	revealed_outfit = /datum/outfit/mafia/lawyer
	role_type = TOWN_SUPPORT
	hud_icon = "hudlawyer"
	revealed_icon = "lawyer"
	winner_award = /datum/award/achievement/mafia/lawyer

	role_unique_actions = list("Advise")
	var/datum/mafia_role/current_target

/datum/mafia_role/lawyer/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN, PROC_REF(roleblock))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END, PROC_REF(release))

/datum/mafia_role/lawyer/proc/roleblock(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return

	var/datum/mafia_role/target = current_target
	if(!target.can_action(game, src, "roleblock")) //roleblocking a warden moment
		current_target = null
		return

	to_chat(target.body,"<span class='big bold red'>YOU HAVE BEEN BLOCKED! YOU CANNOT PERFORM ANY ACTIONS TONIGHT.</span>")
	add_note("N[game.turn] - [target.body.real_name] - Blocked")
	target.role_flags |= ROLE_ROLEBLOCKED

/datum/mafia_role/lawyer/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(target == src)
		return FALSE
	if(game.phase == MAFIA_PHASE_NIGHT)
		return FALSE
	if(target.game_status != MAFIA_ALIVE)
		return FALSE

/datum/mafia_role/lawyer/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(target == current_target)
		current_target = null
		to_chat(body,span_warning("You have decided against blocking anyone tonight."))
	else
		current_target = target
		to_chat(body,span_warning("You will block [target.body.real_name] tonight."))

/datum/mafia_role/lawyer/proc/release(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_target)
		current_target.role_flags &= ~ROLE_ROLEBLOCKED
		current_target = null

/datum/mafia_role/hop
	name = "Head of Personnel"
	desc = "You can reveal yourself once per game, tripling your vote power but becoming unable to be protected!"
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	hud_icon = "hudheadofpersonnel"
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop
	winner_award = /datum/award/achievement/mafia/hop

	role_unique_actions = list("Reveal")

/datum/mafia_role/hop/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || game.phase == MAFIA_PHASE_NIGHT || game.turn == 1 || target.game_status != MAFIA_ALIVE || target != src || (role_flags & ROLE_REVEALED))
		return FALSE

/datum/mafia_role/hop/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	reveal_role(game, TRUE)
	role_flags |= ROLE_VULNERABLE
	vote_power *= 3
