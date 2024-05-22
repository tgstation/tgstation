/obj/effect/meteor/dark_matteor
	/// If the dark matter singuloth successfully spawned on the station z-level.
	var/successfully_hit = FALSE

/obj/effect/meteor/dark_matteor/make_debris()
	var/turf/current_turf = get_turf(src)
	if(is_station_level(current_turf.z))
		successfully_hit = TRUE
	return ..()
