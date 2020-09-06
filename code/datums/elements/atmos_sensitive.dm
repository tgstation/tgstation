//This element should be a way to facilitate registering objects for heat behavior
//It adds the object to a list on SSair to be processed for so long as the object wants to be processed
//And removes it as soon as the object is no longer interested
//Don't put it on things that tend to clump into one spot, you will cause lag spikes.
/datum/element/atmos_sensitive
	element_flags = ELEMENT_DETACH

/datum/element/atmos_sensitive/Attach(datum/target)
	if(!isatom(target)) //How
		return ELEMENT_INCOMPATIBLE
	var/atom/to_track = target
	to_track.RegisterSignal(get_turf(to_track), COMSIG_TURF_EXPOSE, /atom/proc/check_atmos_process)
	RegisterSignal(to_track, COMSIG_MOVABLE_MOVED, .proc/handle_move)
	return ..()

/datum/element/atmos_sensitive/Detach(datum/source, force)
	var/atom/us = source
	us.UnregisterSignal(get_turf(us), COMSIG_TURF_EXPOSE)
	if(us.flags_1 & ATMOS_IS_PROCESSING_1)
		SSair.atom_process_list -= us
		us.flags_1 &= ~ATMOS_IS_PROCESSING_1
	return ..()

/datum/element/atmos_sensitive/proc/handle_move(datum/source, atom/movable/oldloc, direction, forced)
	var/atom/microchipped_lad = source
	if(!istype(microchipped_lad))
		return
	microchipped_lad.UnregisterSignal(oldloc, COMSIG_TURF_EXPOSE)
	if(istype(microchipped_lad.loc, /turf/open))
		microchipped_lad.RegisterSignal(microchipped_lad.loc, COMSIG_TURF_EXPOSE, /atom/proc/check_atmos_process)

/atom/proc/check_atmos_process(datum/source, datum/gas_mixture/air, exposed_temperature)
	if(should_atmos_process(air, exposed_temperature))
		if(flags_1 & ATMOS_IS_PROCESSING_1)
			return
		SSair.atom_process_list += src
		flags_1 |= ATMOS_IS_PROCESSING_1
	else if(flags_1 & ATMOS_IS_PROCESSING_1)
		SSair.atom_process_list -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1

/atom/proc/process_exposure()
	var/turf/open/spot
	if(istype(loc, /turf/open))
		spot = loc
	else if(istype(src, /turf/open)) //Need to let turfs operate
		spot = src
	else //If you end up in a locker or a wall reconsider your life decisions
		SSair.atom_process_list -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	var/temp = spot.air.temperature
	if(!should_atmos_process(spot.air, temp)) //Temp and such can move without the tile becoming active. If that ever changes...
		SSair.atom_process_list -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	atmos_expose(spot.air, temp)

/atom/proc/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return FALSE


///Used by the atmos_sensitive component to register onto atmos flow over our turf
/atom/proc/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	return

/*
	TODO:
	Heat (might) need to matter for breakdown so hotpockets don't form. it might also slow down heat settling tho
	Prehaps have it matter for compare()?
	Superconductors need to fucking settle
	They also need a better qualifyier, shouldn't just be heat.
	Maybe link some atmos machinery to this system? idk man.
*/
