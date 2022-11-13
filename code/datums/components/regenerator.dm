/**
 * # Regenerator component
 *
 * A mob with this component will regenerate its health over time, as long as it has not received damage
 * in the last X seconds. Taking any damage will reset this cooldown.
 */
/datum/component/regenerator
	/// You will only regain health if you haven't been hurt for this many seconds
	var/regeneration_delay
	/// Health to regenerate per second
	var/health_per_second
	/// List of damage types we don't care about, in case you want to only remove this with fire damage or something
	var/list/ignore_damage_types
	/// Animation state to display on the mob when it starts regenerating
	var/image/regen_start_overlay
	/// Time to display the ovlerya for
	var/start_overlay_duration
	/// If this is active we can't regenerate health
	var/no_regen_timer

/datum/component/regenerator/Initialize(regeneration_delay = 6 SECONDS, health_per_second = 2, list/ignore_damage_types = list(STAMINA), regen_start_overlay = NONE, start_overlay_duration = 0)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.regeneration_delay = regeneration_delay
	src.health_per_second = health_per_second
	src.ignore_damage_types = ignore_damage_types
	src.regen_start_overlay = regen_start_overlay
	src.start_overlay_duration = start_overlay_duration

/datum/component/regenerator/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, .proc/on_take_damage)

/datum/component/regenerator/UnregisterFromParent()
	. = ..()
	if(no_regen_timer)
		deltimer(no_regen_timer)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	STOP_PROCESSING(SSobj, src)

/datum/component/regenerator/Destroy(force, silent)
	. = ..()
	if(no_regen_timer)
		deltimer(no_regen_timer)
	STOP_PROCESSING(SSobj, src)

/// When you take damage, reset the cooldown and start processing
/datum/component/regenerator/proc/on_take_damage(datum/source, damage, damagetype)
	if (damage <= 0)
		return
	if (locate(damagetype) in ignore_damage_types)
		return
	STOP_PROCESSING(SSobj, src)
	if(no_regen_timer)
		deltimer(no_regen_timer)
	no_regen_timer = addtimer(CALLBACK(src, .proc/start_regenerating), regeneration_delay, TIMER_STOPPABLE)

/// Start processing health regeneration, and show animation if provided
/datum/component/regenerator/proc/start_regenerating()
	var/mob/living/living_parent = parent
	if (living_parent.stat == DEAD)
		return
	if (living_parent.health == living_parent.maxHealth)
		return
	if (regen_start_overlay)
		flick_overlay_view(regen_start_overlay, living_parent, start_overlay_duration)
	living_parent.visible_message(span_notice("[living_parent]'s wounds begin to knit closed!"))
	START_PROCESSING(SSobj, src)

/datum/component/regenerator/process(delta_time = SSMOBS_DT)
	var/mob/living/living_parent = parent
	if (living_parent.stat == DEAD)
		STOP_PROCESSING(SSobj, src)
		return
	if (living_parent.health == living_parent.maxHealth)
		STOP_PROCESSING(SSobj, src)
		return
	living_parent.heal_overall_damage(health_per_second * delta_time)
