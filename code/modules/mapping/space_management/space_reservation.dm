//Yes, they can only be rectangular.
//Yes, I'm sorry.
/datum/turf_reservation
	var/list/reserved_turfs = list()
	///Turfs around the reservation for cordoning
	var/list/cordon_turfs = list()
	///Area of turfs next to the cordon to fill with pre_cordon_area's
	var/list/pre_cordon_turfs = list()
	var/width = 0
	var/height = 0
	var/bottom_left_coords[3]
	var/top_right_coords[3]
	var/turf_type = /turf/open/space
	///Area next to the cordon, registers a bunch of signals to the tiles there so you can throw people away if they get too close to the actual cordon
	var/pre_cordon_distance = 0

/datum/turf_reservation/transit
	turf_type = /turf/open/space/transit
	pre_cordon_distance = 7

/datum/turf_reservation/proc/Release()
	var/list/reserved_copy = reserved_turfs.Copy()
	SSmapping.used_turfs -= reserved_turfs
	reserved_turfs = list()

	var/list/cordon_copy = cordon_turfs.Copy()
	SSmapping.used_turfs -= cordon_turfs
	cordon_turfs = list()

	var/release_turfs = reserved_copy + cordon_copy

	for(var/turf/reserved_turf as anything in release_turfs)
		SEND_SIGNAL(reserved_turf, COMSIG_TURF_RESERVATION_RELEASED, src)

	// Makes the linter happy, even tho we don't await this
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, reserve_turfs), release_turfs)

/// Attempts to calaculate and store a list of turfs around the reservation for cordoning. Returns whether a valid cordon was calculated
/datum/turf_reservation/proc/calculate_cordon_turfs(turf/BL, turf/TR)
	if(BL.x < 2 || BL.y < 2 || TR.x > (world.maxx - 2) || TR.y > (world.maxy - 2))
		return FALSE // no space for a cordon here

	var/list/possible_turfs = CORNER_OUTLINE(BL, width, height)
	for(var/turf/cordon_turf as anything in possible_turfs)
		if(!(cordon_turf.flags_1 & UNUSED_RESERVATION_TURF))
			return FALSE
	cordon_turfs = possible_turfs

	pre_cordon_turfs.Cut()

	var/turf/offset_turf = locate(BL.x + pre_cordon_distance, BL.y + pre_cordon_distance, BL.z)
	pre_cordon_turfs += CORNER_OUTLINE(offset_turf, width - pre_cordon_distance * 2, height - pre_cordon_distance * 2) //we step-by-stop move inwards from the outer cordon

	return TRUE

/// Actually generates the cordon around the reservation, and marking the cordon turfs as reserved
/datum/turf_reservation/proc/generate_cordon()
	for(var/turf/cordon_turf as anything in cordon_turfs)
		var/area/misc/cordon/cordon_area = GLOB.areas_by_type[/area/misc/cordon] || new
		var/area/old_area = cordon_turf.loc
		old_area.turfs_to_uncontain += cordon_turf
		cordon_area.contained_turfs += cordon_turf
		cordon_area.contents += cordon_turf
		cordon_turf.ChangeTurf(/turf/cordon, /turf/cordon)

		cordon_turf.flags_1 &= ~UNUSED_RESERVATION_TURF
		SSmapping.unused_turfs["[cordon_turf.z]"] -= cordon_turf
		SSmapping.used_turfs[cordon_turf] = src

	//swap the area with the pre-cordoning area
	for(var/turf/pre_cordon_turf as anything in pre_cordon_turfs)
		MakeRepel(pre_cordon_turf)

///Register signals in the cordon "danger zone" to do something with whoever trespasses
/datum/turf_reservation/proc/MakeRepel(turf/pre_cordon_turf)
	//Okay so hear me out. If we place a special turf IN the reserved area, it will be overwritten, so we can't do that
	//But signals are preserved even between turf changes, so even if we register a signal now it will stay even if that turf is overriden by the template
	RegisterSignal(pre_cordon_turf, COMSIG_PARENT_QDELETING, PROC_REF(OnStopRepel))

/datum/turf_reservation/proc/OnStopRepel(turf/pre_cordon_turf)
	SIGNAL_HANDLER

	StopRepel(pre_cordon_turf)

///Unregister all the signals we added in RegisterRepelSignals
/datum/turf_reservation/proc/StopRepel(turf/pre_cordon_turf)
	UnregisterSignal(pre_cordon_turf, COMSIG_PARENT_QDELETING)

/datum/turf_reservation/transit/MakeRepel(turf/pre_cordon_turf)
	..()

	RegisterSignal(pre_cordon_turf, COMSIG_ATOM_ENTERED, PROC_REF(space_dump))

/datum/turf_reservation/StopRepel(turf/pre_cordon_turf)
	..()

	UnregisterSignal(pre_cordon_turf, COMSIG_ATOM_ENTERED)

/datum/turf_reservation/transit/proc/space_dump(atom/source, atom/movable/enterer)
	SIGNAL_HANDLER

	dump_in_space(enterer)

/datum/turf_reservation/proc/Reserve(width, height, zlevel)
	src.width = width
	src.height = height
	if(width > world.maxx || height > world.maxy || width < 1 || height < 1)
		return FALSE
	var/list/avail = SSmapping.unused_turfs["[zlevel]"]
	var/turf/BL
	var/turf/TR
	var/list/turf/final = list()
	var/passing = FALSE
	for(var/i in avail)
		CHECK_TICK
		BL = i
		if(!(BL.flags_1 & UNUSED_RESERVATION_TURF))
			continue
		if(BL.x + width > world.maxx || BL.y + height > world.maxy)
			continue
		TR = locate(BL.x + width - 1, BL.y + height - 1, BL.z)
		if(!(TR.flags_1 & UNUSED_RESERVATION_TURF))
			continue
		final = block(BL, TR)
		if(!final)
			continue
		passing = TRUE
		for(var/I in final)
			var/turf/checking = I
			if(!(checking.flags_1 & UNUSED_RESERVATION_TURF))
				passing = FALSE
				break
		if(passing) // found a potentially valid area, now try to calculate its cordon
			passing = calculate_cordon_turfs(BL, TR)
		if(!passing)
			continue
		break
	if(!passing || !istype(BL) || !istype(TR))
		return FALSE
	bottom_left_coords = list(BL.x, BL.y, BL.z)
	top_right_coords = list(TR.x, TR.y, TR.z)
	for(var/i in final)
		var/turf/T = i
		reserved_turfs |= T
		T.flags_1 &= ~UNUSED_RESERVATION_TURF
		SSmapping.unused_turfs["[T.z]"] -= T
		SSmapping.used_turfs[T] = src
		T.ChangeTurf(turf_type, turf_type)
	generate_cordon()
	return TRUE

/datum/turf_reservation/New()
	LAZYADD(SSmapping.turf_reservations, src)

/datum/turf_reservation/Destroy()
	Release()
	LAZYREMOVE(SSmapping.turf_reservations, src)
	return ..()
