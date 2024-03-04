/// Look up levels[z].traits[trait]
/datum/controller/subsystem/mapping/proc/level_trait(z, trait)
	if (!isnum(z) || z < 1)
		return null
	if (z_list)
		if (z > z_list.len)
			stack_trace("Unmanaged z-level [z]! maxz = [world.maxz], z_list.len = [z_list.len]")
			return list()
		var/datum/space_level/S = z_list[z]
		return S.traits[trait]
	else
		var/list/default = DEFAULT_MAP_TRAITS
		if (z > default.len)
			stack_trace("Unmanaged z-level [z]! maxz = [world.maxz], default.len = [default.len]")
			return list()
		return default[z][DL_TRAITS][trait]

/// Check if levels[z] has any of the specified traits
/datum/controller/subsystem/mapping/proc/level_has_any_trait(z, list/traits)
	var/datum/space_level/level_to_check = z_list[z]
	if (length(level_to_check.traits & traits))
		return TRUE
	return FALSE

/// Check if levels[z] has all of the specified traits
/datum/controller/subsystem/mapping/proc/level_has_all_traits(z, list/traits)
	var/datum/space_level/level_to_check = z_list[z]
	if (length(level_to_check.traits & traits) == length(traits))
		return TRUE
	return FALSE

/// Get a list of all z which have the specified trait
/datum/controller/subsystem/mapping/proc/levels_by_trait(trait)
	return z_trait_levels[trait] || list()

/// Get a list of all z which have any of the specified traits
/datum/controller/subsystem/mapping/proc/levels_by_any_trait(list/traits)
	var/list/final_return = list()
	for (var/trait in traits)
		if (z_trait_levels[trait])
			final_return |= z_trait_levels[trait]
	return final_return

/// Get a list of all z which have all of the specified traits
/datum/controller/subsystem/mapping/proc/levels_by_all_traits(list/traits)
	var/list/final_return = list()
	for(var/datum/space_level/level as anything in z_list)
		if(level_has_all_traits(level.z_value, traits))
			final_return += level.z_value
	return final_return

/// Prefer not to use this one too often
/datum/controller/subsystem/mapping/proc/get_station_center()
	var/station_z = levels_by_trait(ZTRAIT_STATION)[1]
	return locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), station_z)
