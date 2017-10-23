
//Yes, they can only be square.
//Yes, I'm sorry.
/datum/turf_reservation
	var/list/reserved_turfs = list()
	var/top_left_coords[3]
	var/bottom_right_coords[3]
	var/wipe_reservation_on_release = TRUE
	var/turf_type = /turf/open/space

/datum/turf_reservation/transit
	turf_type = /turf/open/space/transit

/datum/turf_reservation/proc/Release()
	for(var/i in reserved_turfs)
		reserved_turfs -= i
		UNRESERVE_TURF(i)

/datum/turf_reservation/proc/Reserve(width, height, zlevel = ZLEVEL_RESERVED)
	if(width > world.maxx || height > world.maxy)
		return FALSE
	var/list/avail = SSmapping.unused_turfs["[zlevel]"]
	var/turf/TL
	var/turf/BR
	var/list/turf/final = list()
	var/passing = FALSE
	for(var/i in avail)
		CHECK_TICK
		TL = i
		if(!(TL.flags_1 & UNUSED_RESERVATION_TURF_1))
			continue
		if(TL.x + width > world.maxx || TL.y + height > world.maxy)
			continue
		BR = locate(TL.x + width, TL.y + height, TL.z)
		if(!(BR.flags_1 & UNUSED_RESERVATION_TURF_1))
			continue
		final = block(TL, BR)
		if(!final)
			continue
		passing = TRUE
		for(var/I in final)
			var/turf/checking = I
			if(!(checking.flags_1 & UNUSED_RESERVATION_TURF_1))
				passing = FALSE
				break
		if(!passing)
			continue
		break
	if(!passing || !istype(TL) || !istype(BR))
		return FALSE
	LAZYINITLIST(SSmapping.used_turfs[src])
	top_left_coords = list(TL.x, TL.y, TL.z)
	bottom_right_coords = list(BR.x, BR.y, BR.z)
	for(var/i in final)
		var/turf/T = i
		RESERVE_TURF(T, src)
		T.ChangeTurf(turf_type, turf_type)
	return TRUE

/datum/turf_reservation/New()
	LAZYADD(SSmapping.turf_reservations, src)

/datum/turf_reservation/Destroy()
	Release()
	LAZYREMOVE(SSmapping.turf_reservations, src)
	return ..()
