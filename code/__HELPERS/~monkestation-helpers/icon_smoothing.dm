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
				if(iswallturf(T) && iswallturf(src))
					var/turf/closed/wall/wall_atom = src
					var/turf/closed/wall/turf_atom = T
					if(turf_atom.trim_color != wall_atom.trim_color)
						var/image/adapater = image("icon" = SMOOTH_ADAPTERS_ICON, "icon_state" = smooth_adapters[type], "layer" = src.layer + 0.03, dir = get_dir(src, T))
						adapater.color = wall_atom.trim_color
						overlays_adapters += adapater

				else
					var/image/adapater = image("icon" = SMOOTH_ADAPTERS_ICON, "icon_state" = smooth_adapters[type], "layer" = src.layer + 0.03, dir = get_dir(src, T))
					if(iswallturf(src))
						var/turf/closed/wall/wall_atom = src
						adapater.color = wall_atom.trim_color
					overlays_adapters += adapater
					skip_content_loop = TRUE

		if(skip_content_loop) // remove it in case if we need more that one adapter per dir
			continue

		for(var/atom/A in T)
			for(var/type in smooth_adapters)
				if(istype(A, type))
					var/image/adapater = image("icon" = SMOOTH_ADAPTERS_ICON, "icon_state" = smooth_adapters[type], "layer" = src.layer + 0.03, dir = get_dir(src, A))
					if(iswallturf(src))
						var/turf/closed/wall/wall_atom = src
						adapater.color = wall_atom.trim_color
					overlays_adapters += adapater
					break

	if(length(overlays_adapters))
		add_overlay(overlays_adapters)
