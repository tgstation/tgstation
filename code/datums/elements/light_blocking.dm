/**
 * Attached to movable atoms with opacity. Listens to them move and updates their old and new turf loc's opacity accordingly.
 */
/datum/element/light_blocking
	element_flags = ELEMENT_DETACH


/datum/element/light_blocking/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_target_move)
	var/atom/movable/movable_target = target
	if(!isturf(movable_target.loc))
		return
	for(var/turf/turf_loc as anything in movable_target.locs)
		turf_loc.add_opacity_source(target)


/datum/element/light_blocking/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_MOVABLE_MOVED))
	var/atom/movable/movable_target = target
	if(!isturf(movable_target.loc))
		return
	for(var/turf/turf_loc as anything in movable_target.locs)
		turf_loc.remove_opacity_source(target)


///Updates old and new turf loc opacities.
/datum/element/light_blocking/proc/on_target_move(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		if(old_locs)
			for(var/turf/old_turf as anything in old_locs)
				old_turf.remove_opacity_source(source)
		else
			var/turf/old_turf = old_loc
			old_turf.remove_opacity_source(source)
	if(isturf(source.loc))
		for(var/turf/new_turf as anything in source.locs)
			new_turf.add_opacity_source(source)
