
#define PTL_TRACER 1	//Tracer beam, pierces through everything and shows trajectory.
#define PTL_PULSE 2		//Burst of damage
#define PTL_PRIMARY 3	//Primary firing, continuous effect application

/obj/machinery/power/PTL/proc/find_starting_turf()
	var/x_offset = laser_tile_x_offset["[dir]"]
	var/y_offset = laser_tile_y_offset["[dir]"]
	var/turf/T = get_turf(src)
	var/turf/starting = locate((T.x + x_offset), (T.y + y_offset), T.z)
	return starting

/obj/machinery/power/PTL/proc/fire_beam(direction, type = PTL_PRIMARY, power, effect_duration_override = null, fullpierce = PTL_FULLPIERCE_NONE)
	var/turf/T = find_starting_turf()
	var/effect_type = null
	switch(type)
		if(PTL_PRIMARY)
			effect_type = /obj/effect/overlay/temp/PTL/continuous
		if(PTL_PULSE)
			effect_type = /obj/effect/overlay/temp/PTL/pulse
		if(PTL_TRACER)
			effect_type = /obj/effect/overlay/temp/PTL/tracer
	var/list/impacted = hitscan_beamline(T, direction, TRUE, effect_type, effect_duration_override, fullpierce)
	var/result = null
	var/atom/direct_hit = null
	var/list/hit = list()
	for(var/V in impacted)
		if(V == "RESULT")
			result = impacted["RESULT"]
		if(V == "HIT_ATOM")
			direct_hit = impacted["HIT_ATOM"]
		else
			for(var/v in impacted[V])
				hit += v
				CHECK_TICK
	if(istype(direct_hit))
		switch(type)
			if(PTL_PRIMARY)
				primary_hit(power, direct_hit, TRUE)
			if(PTL_TRACER)
				tracer_hit(power, direct_hit, TRUE)
			if(PTL_PULSE)
				pulse_hit(power, direct_hit, TRUE)
	for(var/atom/A in hit)
		switch(type)
			if(PTL_PRIMARY)
				primary_hit(power, direct_hit)
			if(PTL_TRACER)
				tracer_hit(power, direct_hit)
			if(PTL_PULSE)
				pulse_hit(power, direct_hit)
		CHECK_TICK
	if(result == PTL_HITSCAN_RETURN_ZEDGE)
		on_zlevel_edge_hit(power)

/obj/machinery/power/PTL/proc/tracer_hit(power, atom/A, direct_hit = FALSE)
	if(isliving(A))
		var/mob/living/L = A
		L.adjustFireLoss(power/1000000)
		to_chat(L, "<span class='warning'>You are seared by the laser!</span>")


/obj/machinery/power/PTL/proc/pulse_hit(power, atom/A, direct_hit = FALSE)

/obj/machinery/power/PTL/proc/primary_hit(power, atom/A, direct_hit = FALSE)

/obj/machinery/power/PTL/proc/on_zlevel_edge_hit(power)
	transmit_power(power)

/obj/machinery/power/PTL/proc/check_station_impact(area_threshold = 2, turf_threshold = 75)
	var/list/affected = hitscan_beamline(starting = find_starting_turf(), beam_dir = dir, generate_effects = FALSE, full_pierce = PTL_FULLPIERCE_NOHIT)
	var/list/turf_matches = list()
	var/list/area_matches = list()
	for(var/V in affected)
		if(V == "RESULT")
			continue
		if(V == "HIT_ATOM")
			continue
		for(var/v in affected[V])
			if(isturf(v))
				var/turf/T = v
				if(!is_type_in_list(T.loc, the_station_areas))
					area_matches[T.loc] = TRUE
					turf_matches += T
	if((area_matches.len > area_threshold) || (turf_matches > turf_threshold))
		return TRUE
	return FALSE
