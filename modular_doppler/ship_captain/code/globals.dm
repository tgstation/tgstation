GLOBAL_LIST_INIT(purchasable_ship_hulls, generate_purchasable_ship_hulls())

/proc/generate_purchasable_ship_hulls()
	var/list/hulls = list()
	var/list/shuttle_types = subtypesof(/datum/map_template/shuttle/personal_buyable/ferries) + subtypesof(/datum/map_template/shuttle/personal_buyable/mining) + subtypesof(/datum/map_template/shuttle/personal_buyable/incomplete) + subtypesof(/datum/map_template/shuttle/personal_buyable/pod)
	// remove the mothership from it
	for(var/datum/map_template/shuttle/personal_buyable/path as anything in shuttle_types)
		hulls["[path.name]"] = path

	return hulls

GLOBAL_LIST_EMPTY(ship_captain_pairs)

GLOBAL_LIST_EMPTY(ship_code_to_spawn_marker)
GLOBAL_LIST_EMPTY(ship_id_to_spawn_marker)
