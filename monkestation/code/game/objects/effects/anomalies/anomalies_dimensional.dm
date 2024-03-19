/obj/effect/anomaly/dimensional
	/// How many remaining times this anomaly will relocate, before its detonation.
	var/relocations_left

/obj/effect/anomaly/dimensional/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	if(!isnum(relocations_left))
		relocations_left = rand(3, 5)

/obj/effect/anomaly/dimensional/detonate()
	. = ..()
	if(!theme)
		return
	visible_message(span_bolddanger("[src] explodes, distorting the space around it in surreal ways!"))
	var/detonate_range = range + rand(5, 7)
	var/list/turf/target_turfs = spiral_range_turfs(detonate_range, src)
	for(var/turf/target in target_turfs)
		if(prob(15) || QDELING(target)) // the prob is so it looks more erratic
			continue
		theme.apply_theme(target)

/obj/effect/anomaly/dimensional/relocate()
	if(relocations_left == -1)
		return ..()
	if(relocations_left < 1)
		detonate()
		qdel(src)
		return
	. = ..()
	relocations_left -= 1
