/datum/map_template/automap_template
	name = "Automap Template"
	should_place_on_top = FALSE
	keep_cached_map = FALSE

	/// The map for which we load on
	var/required_map
	/// Touches builtin map. Clears the area manually instead of blacklisting
	var/affects_builtin_map
	/// Our load turf
	var/turf/load_turf

/datum/map_template/automap_template/New(path, rename, incoming_required_map, incoming_load_turf)
	. = ..(path, rename, cache = TRUE)

	if(!incoming_required_map || !incoming_load_turf)
		return

	required_map = incoming_required_map
	load_turf = incoming_load_turf
	affects_builtin_map = incoming_required_map == AUTOMAPPER_MAP_BUILTIN
