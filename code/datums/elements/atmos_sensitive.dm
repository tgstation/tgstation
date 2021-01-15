//This element facilitates reaction to atmos changes when a tile is inactive.
//It adds the object to a list on SSair to be processed for so long as the object wants to be processed
//And removes it as soon as the object is no longer interested
//Don't put it on things that tend to clump into one spot, you will cause lag spikes.
/datum/element/atmos_sensitive
	element_flags = ELEMENT_DETACH

/datum/element/atmos_sensitive/Attach(datum/target)
	if(!isatom(target)) //How
		return ELEMENT_INCOMPATIBLE
	var/atom/to_track = target
	if(isopenturf(to_track.loc))
		to_track.RegisterSignal(to_track.loc, COMSIG_TURF_EXPOSE, /atom/proc/check_atmos_process)
	RegisterSignal(to_track, COMSIG_MOVABLE_MOVED, .proc/handle_move)
	return ..()

/datum/element/atmos_sensitive/Detach(datum/source, force)
	var/atom/us = source
	us.UnregisterSignal(get_turf(us), COMSIG_TURF_EXPOSE)
	if(us.flags_1 & ATMOS_IS_PROCESSING_1)
		us.atmos_end()
		SSair.atom_process -= us
		us.flags_1 &= ~ATMOS_IS_PROCESSING_1
	return ..()

/datum/element/atmos_sensitive/proc/handle_move(datum/source, atom/movable/oldloc, direction, forced)
	var/atom/microchipped_lad = source
	microchipped_lad.UnregisterSignal(oldloc, COMSIG_TURF_EXPOSE)
	if(isopenturf(microchipped_lad.loc))
		var/turf/open/new_spot = microchipped_lad.loc
		microchipped_lad.RegisterSignal(new_spot, COMSIG_TURF_EXPOSE, /atom/proc/check_atmos_process)
		microchipped_lad.check_atmos_process(null, new_spot.air, new_spot.temperature) //Make sure you're properly registered

/atom/proc/check_atmos_process(datum/source, datum/gas_mixture/air, exposed_temperature)
	if(should_atmos_process(air, exposed_temperature))
		if(flags_1 & ATMOS_IS_PROCESSING_1)
			return
		SSair.atom_process += src
		flags_1 |= ATMOS_IS_PROCESSING_1
	else if(flags_1 & ATMOS_IS_PROCESSING_1)
		atmos_end(air, exposed_temperature)
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1

/atom/proc/process_exposure()
	var/turf/open/spot = loc
	if(!istype(loc, /turf/open))
		//If you end up in a locker or a wall reconsider your life decisions
		atmos_end()
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	if(!should_atmos_process(spot.air, spot.air.temperature)) //Things can change without a tile becoming active
		atmos_end(spot.air, spot.air.temperature)
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	atmos_expose(spot.air, spot.air.temperature)

/turf/open/process_exposure()
	if(!should_atmos_process(air, air.temperature))
		atmos_end(air, air.temperature)
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	atmos_expose(air, air.temperature)

///We use this proc to check if we should start processing an item, or continue processing it. Returns true/false as expected
/atom/proc/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return FALSE


///This is your process() proc
/atom/proc/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	return

///What to do when our requirements are no longer met. Null inputs are possible
/atom/proc/atmos_end(datum/gas_mixture/air, exposed_temperature)
	return
