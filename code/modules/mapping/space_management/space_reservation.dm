
//Yes, they can only be rectangular.
//Yes, I'm sorry.
/datum/turf_reservation
	var/list/reserved_turfs = list()
	var/list/cordon_turfs = list()
	var/width = 0
	var/height = 0
	var/bottom_left_coords[3]
	var/top_right_coords[3]
	var/turf_type = /turf/open/space

/datum/turf_reservation/transit
	turf_type = /turf/open/space/transit

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
