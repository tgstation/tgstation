GLOBAL_LIST_EMPTY(trackers)
//This component should be a way to facilitate registering objects for heat behavior
//It adds the object to a list on SSair to be processed for so long as the object wants to be processed
//And removes it as soon as the object is no longer interested
//Don't put it on things that tend to clump into one spot, you will cause lag spikes.
/datum/element/atmos_sensitive

/datum/element/atmos_sensitive/Attach(datum/target)
	if(!isatom(target)) //How
		return ELEMENT_INCOMPATIBLE
	var/atom/to_track = target
	GLOB.trackers[to_track] = new /datum/movement_detector(to_track, CALLBACK(src, .proc/reset_register))
	to_track.RegisterSignal(get_turf(to_track), COMSIG_TURF_EXPOSE, /atom/proc/check_atmos_process)
	return ..()

/datum/element/atmos_sensitive/Detach(datum/source, force)
	var/atom/us = source
	GLOB.trackers.Remove(GLOB.trackers[us])
	us.UnregisterSignal(get_turf(us), COMSIG_TURF_EXPOSE)
	if(us.flags_1 & ATMOS_IS_PROCESSING_1)
		SSair.atom_process_list -= us
		us.flags_1 &= ~ATMOS_IS_PROCESSING_1
	return ..()

/datum/element/atmos_sensitive/proc/reset_register(atom/tracked, mover, oldloc)
	var/atom/old = oldloc
	tracked.UnregisterSignal(get_turf(old), COMSIG_TURF_EXPOSE)
	tracked.RegisterSignal(get_turf(tracked), COMSIG_TURF_EXPOSE, /atom/proc/check_atmos_process)

/atom/proc/check_atmos_process(datum/source, datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(should_atmos_process(air, exposed_temperature, exposed_volume))
		if(flags_1 & ATMOS_IS_PROCESSING_1)
			return
		SSair.atom_process_list += src
		flags_1 |= ATMOS_IS_PROCESSING_1
	else if(flags_1 & ATMOS_IS_PROCESSING_1)
		SSair.atom_process_list -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1

/atom/proc/should_atmos_process(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return FALSE
