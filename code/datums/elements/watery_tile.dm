/datum/element/watery_tile
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/watery_tile/Attach(turf/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignals(target, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(enter_water))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(out_of_water))
	for(var/atom/movable/movable as anything in target.contents)
		if(!(movable.flags_1 & INITIALIZED_1) || movable.invisibility >= INVISIBILITY_OBSERVER) //turfs initialize before movables
			continue
		enter_water(target, movable)

/datum/element/watery_tile/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_EXITED))
	for(var/atom/movable/movable as anything in source.contents)
		out_of_water(source, movable)
	return ..()

/datum/element/watery_tile/proc/enter_water(atom/source, atom/movable/entered)
	SIGNAL_HANDLER

	RegisterSignal(entered, SIGNAL_ADDTRAIT(TRAIT_IMMERSED), PROC_REF(dip_in))
	if(isliving(entered))
		RegisterSignal(entered, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED), PROC_REF(dip_out))
	if(HAS_TRAIT(entered, TRAIT_IMMERSED))
		dip_in(entered)

/datum/element/watery_tile/proc/dip_in(atom/movable/source)
	SIGNAL_HANDLER
	source.extinguish()
	if(!isliving(source))
		return
	var/mob/living/our_mob = source
	our_mob.adjust_wet_stacks(3)
	our_mob.apply_status_effect(/datum/status_effect/watery_tile_wetness)

/datum/element/watery_tile/proc/out_of_water(atom/source, atom/movable/gone)
	SIGNAL_HANDLER
	UnregisterSignal(gone, list(SIGNAL_ADDTRAIT(TRAIT_IMMERSED), SIGNAL_REMOVETRAIT(TRAIT_IMMERSED)))
	if(isliving(gone))
		dip_out(gone)

/datum/element/watery_tile/proc/dip_out(mob/living/source)
	SIGNAL_HANDLER
	source.remove_status_effect(/datum/status_effect/watery_tile_wetness)

///Added by the watery_tile element. Keep adding wet stacks over time until removed from the watery turf.
/datum/status_effect/watery_tile_wetness
	id = "watery_tile_wetness"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/watery_tile_wetness/tick(seconds_between_ticks)
	. = ..()
	owner.adjust_wet_stacks(1)
