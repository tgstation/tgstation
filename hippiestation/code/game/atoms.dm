/atom/proc/wake_liquids()
	for(var/obj/effect/liquid/L in orange(1, src))
		L.activate()

/atom/Destroy()
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			AA.remove_from_hud(src)

	if(reagents)
		qdel(reagents)

	LAZYCLEARLIST(overlays)
	LAZYCLEARLIST(priority_overlays)

	QDEL_NULL(light)

	if(density)
		wake_liquids()
	return ..()
