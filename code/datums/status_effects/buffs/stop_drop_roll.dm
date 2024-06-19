/datum/status_effect/stop_drop_roll
	id = "stop_drop_roll"
	alert_type = null

	tick_interval = 0.8 SECONDS

/datum/status_effect/stop_drop_roll/on_apply()
	if(!iscarbon(owner))
		return FALSE

	var/actual_interval = initial(tick_interval)
	if(!owner.Knockdown(actual_interval * 2, ignore_canstun = TRUE) || owner.body_position != LYING_DOWN)
		to_chat(owner, span_warning("You try to stop, drop, and roll - but you can't get on the ground!"))
		return FALSE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(stop_rolling))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(body_position_changed))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, id) // they're kinda busy!

	owner.visible_message(
		span_danger("[owner] rolls on the floor, trying to put [owner.p_them()]self out!"),
		span_notice("You stop, drop, and roll!"),
	)
	// Start with one weaker roll
	owner.spin(spintime = actual_interval, speed = actual_interval / 4)
	owner.adjust_fire_stacks(-0.25)

	for (var/obj/item/dropped in owner.loc)
		dropped.extinguish() // Effectively extinguish your items by rolling on them
	return TRUE

/datum/status_effect/stop_drop_roll/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, id)

/datum/status_effect/stop_drop_roll/tick(seconds_between_ticks)
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		qdel(src)
		return

	var/actual_interval = initial(tick_interval)
	if(!owner.Knockdown(actual_interval * 1.2, ignore_canstun = TRUE))
		stop_rolling()
		return

	owner.spin(spintime = actual_interval, speed = actual_interval / 4)
	owner.adjust_fire_stacks(-1)

	if(owner.fire_stacks > 0)
		return

	owner.visible_message(
		span_danger("[owner] successfully extinguishes [owner.p_them()]self!"),
		span_notice("You extinguish yourself."),
	)
	qdel(src)

/datum/status_effect/stop_drop_roll/proc/stop_rolling(datum/source, ...)
	SIGNAL_HANDLER

	if(!QDELING(owner))
		to_chat(owner, span_notice("You stop rolling around."))
	qdel(src)

/datum/status_effect/stop_drop_roll/proc/body_position_changed(datum/source, new_value, old_value)
	SIGNAL_HANDLER

	if(new_value != LYING_DOWN)
		stop_rolling()
