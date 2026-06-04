/datum/bt_node/ai_behavior/find_and_set/in_list/drillable_ice

/// Finds drillable ice turfs; uses RANGE_TURFS instead of oview
/datum/bt_node/ai_behavior/find_and_set/in_list/drillable_ice/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = RANGE_TURFS(search_range, controller.pawn)
	shuffle_inplace(found)
	for(var/turf/open/misc/ice/ice as anything in found)
		if(!is_type_in_typecache(ice, controller.blackboard[locate_paths]))
			continue
		if(ice.can_make_hole && can_see(controller.pawn, ice, search_range))
			return ice
