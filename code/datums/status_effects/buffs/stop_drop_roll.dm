/datum/status_effect/stop_drop_roll
	id = "stop_drop_roll"
	alert_type = null
	tick_interval = 0.8 SECONDS
	processing_speed = STATUS_EFFECT_PRIORITY

/datum/status_effect/stop_drop_roll/on_apply()
	if(!iscarbon(owner))
		return FALSE

	var/actual_interval = initial(tick_interval)
	if(!owner.Knockdown(actual_interval * 2, ignore_canstun = TRUE) || owner.body_position != LYING_DOWN)
		to_chat(owner, span_warning("You try to stop, drop, and roll - but you can't get on the ground!"))
		return FALSE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(stop_rolling))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(body_position_changed))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id)) // they're kinda busy!

	start_rolling()

	for (var/obj/item/dropped in owner.loc)
		dropped.extinguish() // Effectively extinguish your items by rolling on them
	return TRUE

/datum/status_effect/stop_drop_roll/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/stop_drop_roll/proc/start_rolling()
	owner.visible_message(
		span_danger("[owner] rolls on the floor, trying to put [owner.p_them()]self out!"),
		span_notice("You stop, drop, and roll!"),
	)
	// Start with one weaker roll
	reduce_firestacks(0.25)

/datum/status_effect/stop_drop_roll/tick(seconds_between_ticks)
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		qdel(src)
		return

	var/actual_interval = initial(tick_interval)
	if(!owner.Knockdown(actual_interval * 1.2, ignore_canstun = TRUE))
		stop_rolling()
		return

	owner.spin(spintime = actual_interval, speed = actual_interval / 4)
	if(!reduce_firestacks(1))
		return

	stop_rolling_successful()

/// Return TRUE to stop the us from rolling.
/datum/status_effect/stop_drop_roll/proc/reduce_firestacks(amt = 1)
	owner.adjust_fire_stacks(-1 * amt)
	return owner.fire_stacks <= 0

/// Called when we just, stop rolling, due to movement or other reasons. Maybe still on fire, maybe not.
/datum/status_effect/stop_drop_roll/proc/stop_rolling(datum/source, ...)
	SIGNAL_HANDLER

	if(!QDELING(owner))
		to_chat(owner, span_notice("You stop rolling around."))
	qdel(src)

/// Called when we've successfully extinguished ourselves.
/datum/status_effect/stop_drop_roll/proc/stop_rolling_successful()
	owner.visible_message(
		span_danger("[owner] successfully extinguishes [owner.p_them()]self!"),
		span_notice("You extinguish yourself."),
	)
	qdel(src)

/datum/status_effect/stop_drop_roll/proc/body_position_changed(datum/source, new_value, old_value)
	SIGNAL_HANDLER

	if(new_value != LYING_DOWN)
		stop_rolling()

/// Subtype of rolling triggered when someone hallucinating fire tries to stop, drop, and roll.
/datum/status_effect/stop_drop_roll/hallucinating
	/// Weakref to the fire hallucination
	var/datum/weakref/hallucination_weakref

/datum/status_effect/stop_drop_roll/hallucinating/on_creation(mob/living/new_owner, datum/weakref/hallucination_weakref)
	src.hallucination_weakref = hallucination_weakref
	return ..()

/datum/status_effect/stop_drop_roll/hallucinating/start_rolling()
	owner.visible_message(
		span_danger("[owner] starts rolling around on the floor, flailing about!"),
		span_notice("You stop, drop, and roll!"),
	)
	reduce_firestacks(1) // more effective cause it's not real

/datum/status_effect/stop_drop_roll/hallucinating/reduce_firestacks(amt = 1)
	var/datum/hallucination/fire/hallucination = hallucination_weakref?.resolve()
	if(!istype(hallucination))
		return TRUE

	hallucination.fake_firestacks += (-1 * amt)
	if(hallucination.fake_firestacks <= 0)
		hallucination.clear_fire()
		return TRUE
	return FALSE

/datum/status_effect/stop_drop_roll/hallucinating/stop_rolling_successful()
	var/datum/hallucination/fire/hallucination = hallucination_weakref?.resolve()
	if(istype(hallucination))
		hallucination.clear_fire()

	owner.visible_message(
		span_danger("[owner] stops flailing around on the ground."),
		span_notice("You extinguish yourself."),
	)
	qdel(src)
