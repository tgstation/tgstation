/datum/mafia_role/md
	name = "Medical Doctor"
	desc = "You can protect a single person each night from killing."
	revealed_outfit = /datum/outfit/mafia/md
	role_type = TOWN_PROTECT
	hud_icon = "hudmedicaldoctor"
	revealed_icon = "medicaldoctor"
	winner_award = /datum/award/achievement/mafia/md

	role_unique_actions = list("Protect")
	var/datum/mafia_role/current_protected

/datum/mafia_role/md/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE, PROC_REF(protect))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END, PROC_REF(end_protection))

/datum/mafia_role/md/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	if((target.role_flags & ROLE_VULNERABLE) && (target.role_flags & ROLE_REVEALED)) //do not give the option to protect roles that your protection will fail on
		return FALSE
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/md/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,span_warning("You can only protect alive people."))
		return
	to_chat(body,span_warning("You will protect [target.body.real_name] tonight."))
	current_protected = target

/datum/mafia_role/md/proc/protect(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_protected)
		return
	var/datum/mafia_role/target = current_protected
	//current protected is unset at the end, as this action ends at a different phase
	if(!target.can_action(game, src, "medical assistance"))
		return

	RegisterSignal(target,COMSIG_MAFIA_ON_KILL, PROC_REF(prevent_kill))
	add_note("N[game.turn] - Protected [target.body.real_name]")

/datum/mafia_role/md/proc/prevent_kill(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if((current_protected.role_flags & ROLE_VULNERABLE))
		to_chat(body,span_warning("The person you protected could not be saved."))
		return
	to_chat(body,span_warning("The person you protected tonight was attacked!"))
	to_chat(current_protected.body,span_greentext("You were attacked last night, but someone nursed you back to life!"))
	return MAFIA_PREVENT_KILL

/datum/mafia_role/md/proc/end_protection(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_protected)
		UnregisterSignal(current_protected,COMSIG_MAFIA_ON_KILL)
		current_protected = null

/datum/mafia_role/officer
	name = "Security Officer"
	desc = "You can protect a single person each night. If they are attacked, you will retaliate, killing yourself and the attacker."
	revealed_outfit = /datum/outfit/mafia/security
	revealed_icon = "securityofficer"
	hud_icon = "hudsecurityofficer"
	role_type = TOWN_PROTECT
	role_flags = ROLE_CAN_KILL
	winner_award = /datum/award/achievement/mafia/officer

	role_unique_actions = list("Defend")
	var/datum/mafia_role/current_defended

/datum/mafia_role/officer/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE, PROC_REF(defend))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END, PROC_REF(end_defense))

/datum/mafia_role/officer/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	if((role_flags & ROLE_VULNERABLE) && (target.role_flags & ROLE_REVEALED)) //do not give the option to protect roles that your protection will fail on
		return FALSE
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/officer/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,span_warning("You can only defend alive people."))
		return
	to_chat(body,span_warning("You will defend [target.body.real_name] tonight."))
	current_defended = target

/datum/mafia_role/officer/proc/defend(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_defended)
		return
	var/datum/mafia_role/target = current_defended
	//current defended is unset at the end, as this action ends at a different phase
	if(!target.can_action(game, src, "security patrol"))
		return
	if(target)
		RegisterSignal(target,COMSIG_MAFIA_ON_KILL, PROC_REF(retaliate))
		add_note("N[game.turn] - Defended [target.body.real_name]")

/datum/mafia_role/officer/proc/retaliate(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if((current_defended.role_flags & ROLE_VULNERABLE))
		to_chat(body,span_warning("The person you defended could not be saved. You could not attack the killer."))
		return
	to_chat(body,span_userdanger("The person you defended tonight was attacked!"))
	to_chat(current_defended.body,span_userdanger("You were attacked last night, but security fought off the attacker!"))
	if(attacker.kill(game,src,FALSE)) //you attack the attacker
		to_chat(attacker.body, span_userdanger("You have been ambushed by Security!"))
	kill(game,attacker,FALSE) //the attacker attacks you, they were able to attack the target so they can attack you.
	return MAFIA_PREVENT_KILL

/datum/mafia_role/officer/proc/end_defense(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_defended)
		UnregisterSignal(current_defended,COMSIG_MAFIA_ON_KILL)
		current_defended = null
