/datum/map_template/modular
	/// Filename for the map
	var/filename = "virtual_domain"
	/// Parent map folder. You can leave this blank if you want to use generic map modules
	var/parent_map = "generic"

/datum/map_template/modular/New(path = null, rename = null, cache = FALSE)
	mappath = "_maps/virtual_domains/modular_segments/[parent_map]/[filename].dmm"

	..(path = mappath)
