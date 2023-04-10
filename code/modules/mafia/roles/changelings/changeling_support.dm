//better detective for mafia
/datum/mafia_role/mafia/thoughtfeeder
	name = "Thoughtfeeder"
	desc = "You're a changeling variant that feeds on the memories of others. Use ':j' talk prefix to talk to your fellow lings, and visit people at night to learn their role."
	role_type = MAFIA_SPECIAL
	hud_icon = "hudthoughtfeeder"
	revealed_icon = "thoughtfeeder"
	winner_award = /datum/award/achievement/mafia/thoughtfeeder

	role_unique_actions = list("Learn Role")
	var/datum/mafia_role/current_investigation

/datum/mafia_role/mafia/thoughtfeeder/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game, COMSIG_MAFIA_NIGHT_ACTION_PHASE, PROC_REF(investigate))

/datum/mafia_role/mafia/thoughtfeeder/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/mafia/thoughtfeeder/proc/investigate(datum/mafia_controller/game)
	SIGNAL_HANDLER

	var/datum/mafia_role/target = current_investigation
	current_investigation = null
	if(!target.can_action(game, src, "thought feeding"))
		add_note("N[game.turn] - [target.body.real_name] - Unable to investigate")
		return
	if((target.role_flags & ROLE_UNDETECTABLE))
		to_chat(body,span_warning("[target.body.real_name]'s memories reveal that they are the Assistant."))
		add_note("N[game.turn] - [target.body.real_name] - Assistant")
	else
		to_chat(body,span_warning("[target.body.real_name]'s memories reveal that they are the [target.name]."))
		add_note("N[game.turn] - [target.body.real_name] - [target.name]")
