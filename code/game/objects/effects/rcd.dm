/// How many tiles within player radius does it perform a rcd scan in
#define RCD_DESTRUCTIVE_SCAN_RANGE 10

/**
 * Global proc that generates RCD hologram in a range.
 *
 * Arguments:
 * * source - The atom the scans originate from
 * * scan_range - The range of turfs we grab from the source
 * * fade_time - The time for RCD holograms to fade
 */
/proc/rcd_scan(atom/source, scan_range = RCD_DESTRUCTIVE_SCAN_RANGE, fade_time = RCD_HOLOGRAM_FADE_TIME)
	playsound(source, 'sound/items/rcdscan.ogg', 50, vary = TRUE, pressure_affected = FALSE)

	var/turf/source_turf = get_turf(source)
	for(var/turf/open/surrounding_turf as anything in RANGE_TURFS(scan_range, source_turf))
		var/rcd_memory = surrounding_turf.rcd_memory
		if(!rcd_memory)
			continue

		var/skip_to_next_turf = FALSE

		for(var/atom/content_of_turf as anything in surrounding_turf.contents)
			if (content_of_turf.density)
				skip_to_next_turf = TRUE
				break

		if(skip_to_next_turf)
			continue

		var/hologram_icon
		switch(rcd_memory)
			if(RCD_MEMORY_WALL)
				hologram_icon = GLOB.icon_holographic_wall
			if(RCD_MEMORY_WINDOWGRILLE)
				hologram_icon = GLOB.icon_holographic_window

		var/obj/effect/rcd_hologram/hologram = new(surrounding_turf)
		hologram.icon = hologram_icon
		hologram.makeHologram()
		animate(hologram, alpha = 0, time = fade_time, easing = CIRCULAR_EASING | EASE_IN)

#undef RCD_DESTRUCTIVE_SCAN_RANGE
