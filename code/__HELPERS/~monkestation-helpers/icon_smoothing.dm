// adds apecial transition overlays depending on the `smooth_adapters`
/atom/var/list/overlays_adapters
/atom/var/list/smooth_adapters = null // list of adapters we need to request from neighbors, list(/type/ = "state")
/atom/proc/update_adapters()
	if(!length(smooth_adapters))
		return

	if(length(overlays_adapters))
		cut_overlay(overlays_adapters)

	overlays_adapters = list()

	for(var/direction in GLOB.cardinals) // yeah, this is another get_step_around for smoothing system. Maybe need to merge it with `calculate_adjacencies` somehow. Anyway, it's not soo bad.
		var/turf/T = get_step(src, direction)

		if(!T)
			continue

		var/skip_content_loop = FALSE
		for(var/type in smooth_adapters)
			if(istype(T, type))
				overlays_adapters += image("icon" = SMOOTH_ADAPTERS_ICON, "icon_state" = smooth_adapters[type], dir = get_dir(src, T))
				skip_content_loop = TRUE

		if(skip_content_loop) // remove it in case if we need more that one adapter per dir
			continue

		for(var/atom/A in T)
			for(var/type in smooth_adapters)
				if(istype(A, type))
					overlays_adapters += image("icon" = SMOOTH_ADAPTERS_ICON, "icon_state" = smooth_adapters[type], dir = get_dir(src, A))
					break

	if(length(overlays_adapters))
		add_overlay(overlays_adapters)
