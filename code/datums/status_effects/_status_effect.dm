/// Status effects are used to apply temporary or permanent effects to mobs.
/// This file contains their code, plus code for applying and removing them.
/datum/status_effect
	/// The ID of the effect. ID is used in adding and removing effects to check for duplicates, among other things.
	var/id = "effect"
	/// When set initially / in on_creation, this is how long the status effect lasts in deciseconds.
	/// While processing, this becomes the world.time when the status effect will expire.
	/// -1 = infinite duration.
	var/duration = STATUS_EFFECT_PERMANENT
	/// When set initially / in on_creation, this is how long between [proc/tick] calls in deciseconds.
	/// Note that this cannot be faster than the processing subsystem you choose to fire the effect on. (See: [var/processing_speed])
	/// While processing, this becomes the world.time when the next tick will occur.
	/// -1 = will prevent ticks, and if duration is also unlimited (-1), stop processing wholesale.
	var/tick_interval = 1 SECONDS
	///If our tick intervals are set to be a dynamic value within a range, the lowerbound of said range
	var/tick_interval_lowerbound
	///If our tick intervals are set to be a dynamic value within a range, the upperbound of said range
	var/tick_interval_upperbound
	/// The mob affected by the status effect.
	VAR_FINAL/mob/living/owner
	/// How many of the effect can be on one mob, and/or what happens when you try to add a duplicate.
	var/status_type = STATUS_EFFECT_UNIQUE
	/// If TRUE, we call [proc/on_remove] when owner is deleted. Otherwise, we call [proc/be_replaced].
	var/on_remove_on_mob_delete = FALSE
	/// The typepath to the alert thrown by the status effect when created.
	/// Status effect "name"s and "description"s are shown to the owner here.
	var/alert_type = /atom/movable/screen/alert/status_effect
	/// The alert itself, created in [proc/on_creation] (if alert_type is specified).
	VAR_FINAL/atom/movable/screen/alert/status_effect/linked_alert
	/// If TRUE, and we have an alert, we will show a duration on the alert
	var/show_duration = FALSE
	/// Used to define if the status effect should be using SSfastprocess or SSprocessing
	var/processing_speed = STATUS_EFFECT_FAST_PROCESS
	/// Do we self-terminate when a fullheal is called?
	var/remove_on_fullheal = FALSE
	/// If remove_on_fullheal is TRUE, what flag do we need to be removed?
	var/heal_flag_necessary = HEAL_STATUS
	/// A particle effect, for things like embers - Should be set on update_particles()
	VAR_FINAL/obj/effect/abstract/particle_holder/particle_effect

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

/// Called from New() with any supplied status effect arguments.
/// Not guaranteed to exist by the end.
/// Returning FALSE from on_apply will stop on_creation and self-delete the effect.
/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(QDELETED(owner) || !on_apply())
		qdel(src)
		return
	if(owner)
		LAZYADD(owner.status_effects, src)
		RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(remove_effect_on_heal))

	if(duration == INFINITY)
		// we will optionally allow INFINITY, because i imagine it'll be convenient in some places,
		// but we'll still set it to -1 / STATUS_EFFECT_PERMANENT for proper unified handling
		duration = STATUS_EFFECT_PERMANENT
	if(duration != STATUS_EFFECT_PERMANENT)
		duration = world.time + duration
	if(tick_interval != STATUS_EFFECT_NO_TICK)
		tick_interval = world.time + tick_interval

	if(alert_type)
		var/atom/movable/screen/alert/status_effect/new_alert = owner.throw_alert(id, alert_type)
		new_alert.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = new_alert //so we can reference the alert, if we need to
		update_shown_duration()

	if(duration > world.time || tick_interval > world.time) //don't process if we don't care
		switch(processing_speed)
			if(STATUS_EFFECT_FAST_PROCESS)
				START_PROCESSING(SSfastprocess, src)
			if(STATUS_EFFECT_NORMAL_PROCESS)
				START_PROCESSING(SSprocessing, src)
			if(STATUS_EFFECT_PRIORITY)
				START_PROCESSING(SSpriority_effects, src)

	update_particles()
	SEND_SIGNAL(owner, COMSIG_LIVING_STATUS_APPLIED, src)
	return TRUE

/datum/status_effect/Destroy()
	switch(processing_speed)
		if(STATUS_EFFECT_FAST_PROCESS)
			STOP_PROCESSING(SSfastprocess, src)
		if(STATUS_EFFECT_NORMAL_PROCESS)
			STOP_PROCESSING(SSprocessing, src)
		if(STATUS_EFFECT_PRIORITY)
			STOP_PROCESSING(SSpriority_effects, src)
	if(owner)
		linked_alert = null
		owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)
		SEND_SIGNAL(owner, COMSIG_LIVING_STATUS_REMOVED, src)
		owner = null
	if(particle_effect)
		QDEL_NULL(particle_effect)
	return ..()

/// Updates the status effect alert's maptext (if possible)
/datum/status_effect/proc/update_shown_duration()
	PRIVATE_PROC(TRUE)
	if(!linked_alert || !show_duration)
		return

	linked_alert.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[round((duration - world.time)/10, 1)]s</span>")

// Status effect process. Handles adjusting its duration and ticks.
// If you're adding processed effects, put them in [proc/tick]
// instead of extending / overriding the process() proc.
/datum/status_effect/process(seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(QDELETED(owner))
		qdel(src)
		return

	if(tick_interval == STATUS_EFFECT_AUTO_TICK)
		tick(seconds_per_tick)
	else if(tick_interval != STATUS_EFFECT_NO_TICK && tick_interval < world.time)
		var/tick_length = (tick_interval_upperbound && tick_interval_lowerbound) ? rand(tick_interval_lowerbound, tick_interval_upperbound) : initial(tick_interval)
		tick(tick_length / (1 SECONDS))
		tick_interval = world.time + tick_length

	if(QDELING(src))
		// tick deleted us, no need to continue
		return

	if(duration != STATUS_EFFECT_PERMANENT)
		if(duration < world.time)
			qdel(src)
			return
		update_shown_duration()

/// Called whenever the effect is applied in on_created
/// Returning FALSE will cause it to delete itself during creation instead.
/datum/status_effect/proc/on_apply()
	return TRUE

/// Gets and formats examine text associated with our status effect.
/// Return 'null' to have no examine text appear (default behavior).
/datum/status_effect/proc/get_examine_text()
	return null

/**
 * Called every tick from process().
 * This is only called of tick_interval is not -1.
 *
 * Note that every tick =/= every processing cycle.
 *
 * * seconds_between_ticks = This is how many SECONDS that elapse between ticks.
 * This is a constant value based upon the initial tick interval set on the status effect.
 * It is similar to seconds_per_tick, from processing itself, but adjusted to the status effect's tick interval.
 */
/datum/status_effect/proc/tick(seconds_between_ticks)
	return

/// Called whenever the buff expires or is removed (qdeleted)
/// Note that at the point this is called, it is out of the
/// owner's status_effects list, but owner is not yet null
/datum/status_effect/proc/on_remove()
	return

/// Called instead of on_remove when a status effect
/// of status_type STATUS_EFFECT_REPLACE is replaced by itself,
/// or when a status effect with on_remove_on_mob_delete
/// set to FALSE has its mob deleted
/datum/status_effect/proc/be_replaced()
	linked_alert = null
	owner.clear_alert(id)
	LAZYREMOVE(owner.status_effects, src)
	owner = null
	qdel(src)

/// Called before being fully removed (before on_remove)
/// Returning FALSE will cancel removal
/datum/status_effect/proc/before_remove(...)
	return TRUE

/// Called when a status effect of status_type STATUS_EFFECT_REFRESH
/// has its duration refreshed in apply_status_effect - is passed New() args
/datum/status_effect/proc/refresh(effect, ...)
	var/original_duration = initial(duration)
	if(original_duration == STATUS_EFFECT_PERMANENT)
		return
	duration = world.time + original_duration

/// Adds nextmove modifier multiplicatively to the owner while applied
/datum/status_effect/proc/nextmove_modifier()
	return 1

/// Adds nextmove adjustment additiviely to the owner while applied
/datum/status_effect/proc/nextmove_adjust()
	return 0

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL] to remove us on fullheal
/datum/status_effect/proc/remove_effect_on_heal(datum/source, heal_flags)
	SIGNAL_HANDLER

	if(!remove_on_fullheal)
		return

	if(!heal_flag_necessary || (heal_flags & heal_flag_necessary))
		qdel(src)

/// Remove [seconds] of duration from the status effect, qdeling / ending if we eclipse the current world time.
/datum/status_effect/proc/remove_duration(seconds)
	if(duration == STATUS_EFFECT_PERMANENT) // Infinite duration
		return FALSE

	duration -= seconds
	if(duration <= world.time)
		qdel(src)
		return TRUE

	update_shown_duration()
	return FALSE

/**
 * Updates the particles for the status effects
 * Should be handled by subtypes!
 */
/datum/status_effect/proc/update_particles()
	SHOULD_CALL_PARENT(FALSE)
	return

/datum/status_effect/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name == NAMEOF(src, duration))
		if(var_value == INFINITY)
			duration = STATUS_EFFECT_PERMANENT
		update_shown_duration()

	if(var_name == NAMEOF(src, show_duration))
		update_shown_duration()

/// Alert base type for status effect alerts
/atom/movable/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	maptext_y = 2
	/// The status effect we're linked to
	var/datum/status_effect/attached_effect

/atom/movable/screen/alert/status_effect/Destroy()
	attached_effect = null //Don't keep a ref now
	return ..()
