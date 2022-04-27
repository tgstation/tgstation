///simple element to handle: 1. mobs that are on fire bumping into other mobs
///and 2. mobs on fire moving into a turf containing mobs not on fire, but not bumping into them
/datum/element/on_fire_connector
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	id_arg_index = 2
	///given to connect_loc attached to our target
	var/static/list/connect_loc_signals = list(
		COMSIG_ATOM_ENTERED = /mob/living/proc/on_entered_fire,
	)
	///becomes a typecache of what types we are allowed to spread fire to.
	var/list/types_to_consider

/datum/element/on_fire_connector/Attach(mob/living/target, list/types_to_consider = /mob/living)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!target.on_fire)
		return ELEMENT_INCOMPATIBLE
	if(!types_to_consider)
		return ELEMENT_INCOMPATIBLE

	src.types_to_consider = typecacheof(types_to_consider)

	target.AddElement(/datum/element/connect_loc, connect_loc_signals)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	return ..()

/datum/element/on_fire_connector/Detach(datum/target, ...)
	if(!target)
		return ..()

	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.RemoveElement(/datum/element/connect_loc, connect_loc_signals)

	return ..()

/datum/element/on_fire_connector/proc/on_moved(mob/living/target, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	var/atom/target_loc = target.loc
	if(!target_loc || target.loc == old_loc)
		return NONE

	for(var/atom/movable/contents as anything in target_loc)
		if(contents == target)
			continue
		if(!is_type_in_typecache(contents, types_to_consider))
			continue

		target.spreadFire(contents)
