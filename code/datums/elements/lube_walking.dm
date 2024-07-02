/**
 * # lube_walking
 *
 * Makes a mob cause a turf to get wet as they walk, requires lying down.
 * Has configurable args for wet flags, time, and resting requirements.
 */
/datum/element/lube_walking
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	///The wet flags that we make each tile we are affecting slippery with.
	var/wet_flags
	///The minimum amount of time any tile we wet will be wet for.
	var/min_time_wet_for
	///Boolean on whether the mob has to be 'resting' for the element to properly affect tiles.
	///Used to exclude simple animals that you don't expect to lie down.
	var/require_resting

/datum/element/lube_walking/Attach(atom/movable/target, wet_flags = TURF_WET_LUBE, min_time_wet_for = 2 SECONDS, require_resting = FALSE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.wet_flags = wet_flags
	src.min_time_wet_for = min_time_wet_for
	src.require_resting = require_resting

	if(require_resting)
		if(!isliving(target))
			stack_trace("lube_walking Element was added onto [target] with require_resting set on, which only works on living mobs.")
			return ELEMENT_INCOMPATIBLE
		var/mob/living/living_target = target
		RegisterSignal(living_target, COMSIG_LIVING_RESTING, PROC_REF(on_resting_changed))
		if(living_target.resting) //theyre resting as the element was added, so let them start lubricating.
			on_resting_changed(living_target, new_resting = TRUE)
	else
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(lubricate))

/datum/element/lube_walking/Detach(mob/living/carbon/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_LIVING_RESTING, COMSIG_MOVABLE_MOVED))
	if(istype(target))
		target.remove_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)

///Called when a living mob changes their resting state with require_resting on, giving them their movement speed and ability.
/datum/element/lube_walking/proc/on_resting_changed(mob/snail, new_resting, silent, instant)
	SIGNAL_HANDLER

	if(new_resting && lubricate(snail))
		snail.add_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)
		RegisterSignal(snail, COMSIG_MOVABLE_MOVED, PROC_REF(lubricate))
	else
		snail.remove_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)
		UnregisterSignal(snail, COMSIG_MOVABLE_MOVED)

/datum/element/lube_walking/proc/lubricate(atom/movable/snail)
	SIGNAL_HANDLER

	var/turf/open/turf_standing_on = get_turf(snail)
	if(!istype(turf_standing_on))
		return FALSE
	turf_standing_on.MakeSlippery(wet_flags, min_wet_time = min_time_wet_for)
	return TRUE
