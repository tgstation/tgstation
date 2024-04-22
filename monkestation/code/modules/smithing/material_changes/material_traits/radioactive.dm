/datum/material_trait/radioactive
	name = "Radioactive"
	desc = "Makes this item shoot radiation out (scales based on radiation)"
	trait_flags = MATERIAL_TRACK_NO_STACK_PROCESS

/datum/material_trait/radioactive/on_process(atom/movable/parent, datum/material_stats/host)
	radiation_pulse(get_turf(parent), max_range = 2 * host.radioactivity * 0.01, threshold = 0.05)
