/datum/action/cooldown/spell/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, \
		allowing you to move freely while your enemies and even projectiles are frozen."
	button_icon_state = "time"

	school = SCHOOL_FORBIDDEN // Fucking with time is not appreciated by anyone
	cooldown_time = 50 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "TOKI YO TOMARE!"
	invocation_type = INVOCATION_SHOUT

	/// The radius / range of the time stop.
	var/timestop_range = 2
	/// The duration of the time stop.
	var/timestop_duration = 10 SECONDS

	/// if TRUE, the owner is immune to all time stop, from anyone
	var/owner_is_immune_to_all_timestop = TRUE
	/// if TRUE, the owner is immune to their own timestop (but not other people's, if above is FALSE)
	var/owner_is_immune_to_self_timestop = TRUE

	var/time_stop_type = /obj/effect/timestop/magic

/datum/action/cooldown/spell/timestop/Grant(mob/grant_to)
	. = ..()
	if(!isnull(owner) && owner_is_immune_to_all_timestop)
		ADD_TRAIT(owner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/cooldown/spell/timestop/Remove(mob/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_TIME_STOP_IMMUNE, REF(src))
	return ..()

/datum/action/cooldown/spell/timestop/cast(atom/cast_on)
	. = ..()
	timestop(cast_on)

/datum/action/cooldown/spell/timestop/proc/timestop(atom/cast_on)
	var/list/default_immune_atoms = list()
	if(owner_is_immune_to_self_timestop)
		default_immune_atoms += cast_on

	return new time_stop_type(get_turf(cast_on), timestop_range, timestop_duration, default_immune_atoms)

/datum/action/cooldown/spell/timestop/proc/act_on_timestopped(obj/effect/timestop/magic/field)
	return

/datum/action/cooldown/spell/timestop/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name != NAMEOF(src, owner_is_immune_to_all_timestop) || isnull(owner))
		return

	if(var_value)
		ADD_TRAIT(owner, TRAIT_TIME_STOP_IMMUNE, REF(src))
	else
		REMOVE_TRAIT(owner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/cooldown/spell/timestop/turn_based
	name = "Baldur's Station 13"
	owner_is_immune_to_all_timestop = FALSE
	timestop_range = 7
	timestop_duration = INFINITY
	owner_has_control = FALSE
	cooldown_time = 6 SECONDS
	time_stop_type = /obj/effect/timestop/magic/turn_based
	var/datum/combat_instance/combat

/datum/action/cooldown/spell/timestop/turn_based/Grant(mob/grant_to)
	. = ..()
	if(!HAS_TRAIT(grant_to, TRAIT_RELAYING_ATTACKER))
		grant_to.AddElement(/datum/element/relay_attackers)
	RegisterSignal(grant_to, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(start_turn_based))

/datum/action/cooldown/spell/timestop/turn_based/proc/start_turn_based(datum/source, atom/attacker, ...)
	SIGNAL_HANDLER

	if(HAS_TRAIT(owner, TRAIT_TURN_COMBATANT))
		return
	if(owner == attacker || !isliving(attacker))
		return
	if(isnull(owner.client) && isnull(owner.ai_controller))
		return
	if(owner.stat != CONSCIOUS || owner.incapacitated())
		return

	timestop(owner)

/datum/action/cooldown/spell/timestop/turn_based/timestop(atom/cast_on)
	. = ..()
	combat = new(owner, .)
	RegisterSignal(combat, COMSIG_QDELETING, PROC_REF(reset))

/datum/action/cooldown/spell/timestop/turn_based/proc/reset(...)
	SIGNAL_HANDLER
	combat = null

/datum/combat_instance
	var/obj/effect/timestop/magic/field
	var/mob/living/attacked
	var/mob/living/active_turn_guy
	var/current_round = 1
	var/turn_timerid

/datum/combat_instance/Destroy()
	if(!QDELETED(field))
		UnregisterSignal(field, COMSIG_QDELETING)
		qdel(field)

	field = null
	attacked = null
	active_turn_guy = null
	return ..()

/datum/combat_instance/New(mob/living/attacked, obj/effect/timestop/magic/field)
	src.attacked = attacked
	src.field = field

	RegisterSignal(field, COMSIG_QDELETING, PROC_REF(end_combat_comsig))
	RegisterSignal(attacked, COMSIG_QDELETING, PROC_REF(end_combat_comsig))

	RegisterSignal(field.chronofield, COMSIG_TIMESTOP_ENTERED, PROC_REF(new_combatant))
	RegisterSignal(field.chronofield, COMSIG_TIMESTOP_EXITED, PROC_REF(combatant_left))

	addtimer(CALLBACK(src, PROC_REF(start_combat)), 0.5 SECONDS, TIMER_DELETE_ME)

/datum/combat_instance/proc/enemies_remaining()
	var/list/mob/living/fighters_left = list()
	for(var/mob/living/remaining as anything in get_fighting_mobs())
		if(can_fight(remaining))
			fighters_left += remaining

	var/i = 1
	var/j = 1
	while(i <= length(fighters_left) - 1)
		j = i + 1
		while(j <= length(fighters_left))
			if(fighters_left[i].faction_check_atom(fighters_left[j]))
				return TRUE
			j += 1
		i += 1

	return FALSE

/datum/combat_instance/proc/get_fighting_mobs()
	var/list/mobs = list()
	mobs += attacked
	for(var/turf/field_turf as anything in field.chronofield.edge_turfs + field.chronofield.field_turfs)
		for(var/mob/living/fighter in field_turf)
			if(fighter == attacked)
				continue
			mobs += fighter

	return mobs

/datum/combat_instance/proc/can_fight(mob/living/guy)
#ifndef TESTING
	if(isnull(guy.client) && isnull(guy.ai_controller))
		return FALSE
#endif
	if(HAS_TRAIT(guy, TRAIT_CRITICAL_CONDITION))
		return FALSE
	if(guy.stat == DEAD)
		return FALSE
	// this check is a hack because timestop "stuns" you
	if(guy.incapacitated() && !HAS_TRAIT_FROM(guy, TRAIT_IMMOBILIZED, "stun-trait"))
		return FALSE
	return TRUE

/datum/combat_instance/proc/start_combat()
	if(!enemies_remaining())
		end_combat()
		return

	var/mob/turn_one_guy
	for(var/mob/living/fighter as anything in get_fighting_mobs())
		register_combatant(fighter)
		fighter.balloon_alert(fighter, "combat begin! round [current_round]!")
		if(isnull(turn_one_guy) && can_fight(fighter))
			turn_one_guy = fighter

	ASSERT(turn_one_guy)
	addtimer(CALLBACK(src, PROC_REF(start_turn), turn_one_guy), 0.1 SECONDS, TIMER_DELETE_ME)

/datum/combat_instance/proc/start_turn(mob/living/turn_guy)
	if(!enemies_remaining())
		end_combat()
		return

	active_turn_guy = turn_guy

	turn_guy.add_filter("your_turn_filter", 1, list("type" = "outline", "size" = 2, "color" = COLOR_GOLD, "alpha" = 0))
	var/the_filter = turn_guy.get_filter("your_turn_filter")
	animate(the_filter, alpha = 200, time = 0.3 SECONDS, loop = 2)
	animate(alpha = 0, time = 0.3 SECONDS)

	if(!can_fight(turn_guy))
		turn_guy.balloon_alert(turn_guy, "turn skipped!")
		turn_guy.AdjustParalyzed(-6 SECONDS)
		turn_guy.AdjustKnockdown(-6 SECONDS)
		turn_guy.AdjustImmobilized(-6 SECONDS)
		turn_guy.AdjustUnconscious(-6 SECONDS)
		turn_guy.adjustStaminaLoss(-30)
		end_turn(turn_guy, FALSE)
		return

	turn_guy.get_up(TRUE)
	turn_guy.balloon_alert(turn_guy, "your turn! round [current_round]!")
	field.chronofield.immune[turn_guy] = TRUE
	field.chronofield.unfreeze_atom(turn_guy)

	RegisterSignals(turn_guy, list(
		COMSIG_LIVING_GRAB,
		COMSIG_LIVING_PICKED_UP_ITEM,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_MOB_ITEM_AFTERATTACK,
		COMSIG_MOB_THROW,
		COMSIG_MOVABLE_MOVED,
	), PROC_REF(end_turn_comsig))

	turn_timerid = addtimer(CALLBACK(src, PROC_REF(end_turn), turn_guy), 6 SECONDS, TIMER_DELETE_ME|TIMER_STOPPABLE|TIMER_UNIQUE)

/datum/combat_instance/proc/end_turn_comsig(mob/living/turn_guy)
	SIGNAL_HANDLER
	end_turn(turn_guy)

/datum/combat_instance/proc/end_turn(mob/living/turn_guy, notify = TRUE)
	ASSERT(turn_guy == active_turn_guy)

	deltimer(turn_timerid)
	turn_timerid = null

	if(notify)
		turn_guy.balloon_alert(turn_guy, "turn over!")

	turn_guy.remove_filter("your_turn_filter")
	field.chronofield.immune[turn_guy] = FALSE
	field.chronofield.freeze_atom(turn_guy)

	var/list/affected = get_fighting_mobs()
	var/curr_index = affected.Find(turn_guy)
	if(curr_index == length(affected))
		curr_index = 1
		current_round += 1
	else
		curr_index += 1

	UnregisterSignal(turn_guy, list(
		COMSIG_LIVING_GRAB,
		COMSIG_LIVING_PICKED_UP_ITEM,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_MOB_ITEM_AFTERATTACK,
		COMSIG_MOB_THROW,
		COMSIG_MOVABLE_MOVED,
	))

	if(current_round >= 14)
		end_combat(prepended = "turn limit reached!")
		return

	addtimer(CALLBACK(src, PROC_REF(start_turn), affected[curr_index]), 0.1 SECONDS, TIMER_DELETE_ME)

/datum/combat_instance/proc/end_combat_comsig(...)
	SIGNAL_HANDLER
	end_combat()

/datum/combat_instance/proc/end_combat(prepended = "", appended = "")
	var/end_text = "combat over!"
	if(prepended)
		end_text = "[prepended] [end_text]"
	if(appended)
		end_text = "[end_text] [appended]"

	for(var/mob/living/fighter in field?.chronofield?.frozen_mobs)
		fighter.balloon_alert(fighter, end_text)
		REMOVE_TRAIT(fighter, TRAIT_TURN_COMBATANT, REF(field.chronofield))

	qdel(src)

/datum/combat_instance/proc/new_combatant(datum/source, atom/new_combatant)
	SIGNAL_HANDLER

	if(!isliving(new_combatant))
		return
	if(HAS_TRAIT(new_combatant, TRAIT_TURN_COMBATANT)) // in another combat already
		return

	register_combatant(new_combatant)

/datum/combat_instance/proc/register_combatant(mob/living/new_combatant)
	ADD_TRAIT(new_combatant, TRAIT_TURN_COMBATANT, REF(field.chronofield))
	var/datum/action/end_turn/end_turn_action = new(src)
	end_turn_action.Grant(new_combatant)

/datum/combat_instance/proc/combatant_left(datum/source, atom/combatant)
	SIGNAL_HANDLER

	if(!isliving(combatant))
		return
	if(combatant.loc in (field.chronofield.field_turfs | field.chronofield.edge_turfs))
		return

	REMOVE_TRAIT(combatant, TRAIT_TURN_COMBATANT, REF(field.chronofield))

	if(!enemies_remaining())
		end_combat()

/mob/living/Initialize(mapload)
	. = ..()
	make_turn_based()

/mob/living/proc/make_turn_based()
	GRANT_ACTION(/datum/action/cooldown/spell/timestop/turn_based)

/mob/living/silicon/ai/make_turn_based()
	return

/mob/living/carbon/human/dummy/make_turn_based()
	return

/mob/living/carbon/human/consistent/dummy/make_turn_based()
	return

/datum/action/end_turn
	name = "End Turn"
	desc = "End your turn early."
	overlay_icon_state = "bg_spell_border_active_yellow"

/datum/action/end_turn/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/combat_instance/combat = target
	if(combat.active_turn_guy != owner)
		owner.balloon_alert(owner, "not your turn!")
		return

	combat.end_turn(owner)
