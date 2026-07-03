/**
 * Returns a list of data for the nanomap map UI
 */
/datum/controller/subsystem/mapping/proc/get_map_ui_data()
	if(!initialized)
		stack_trace("get_map_ui_data called before initialization")
		return list()

	var/static/list/map_ui_data = list()
	if(!length(map_ui_data))
		var/list/station_z_levels = levels_by_trait(ZTRAIT_STATION)
		var/min_station_z_level = station_z_levels[1]
		var/main_station_z_level = isnull(current_map.main_floor) ? min_station_z_level : min_station_z_level + current_map.main_floor - 1
		var/max_station_z_level = station_z_levels[length(station_z_levels)]

		var/list/mining_levels = levels_by_trait(ZTRAIT_MINING)
		var/lavaland_z_level = length(mining_levels) ? mining_levels[1] : null

		map_ui_data["name"] = current_map.map_name
		map_ui_data["minFloor"] = min_station_z_level
		map_ui_data["mainFloor"] = main_station_z_level
		map_ui_data["maxFloor"] = max_station_z_level
		map_ui_data["lavalandLevel"] = lavaland_z_level

		// Add ladders and stairs for navigator UI
		var/list/ladders_and_stairs = list()
		for(var/obj/structure/ladded_or_stairs as anything in (GLOB.ladders + GLOB.stairs))
			ladders_and_stairs += list(list(
				"posX" = ladded_or_stairs.x,
				"posY" = ladded_or_stairs.y,
				"posZ" = ladded_or_stairs.z,
			))
			
		map_ui_data["stairs"] = ladders_and_stairs

	return map_ui_data
