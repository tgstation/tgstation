// Map Serialization Admin UI
ADMIN_VERB(map_serialization_ui, R_DEBUG, "Map Serialization", "Opens the map serialization admin interface.", ADMIN_CATEGORY_DEBUG)
	var/datum/map_serialization_ui/ui = new(usr)
	ui.ui_interact(usr)

/// Map Serialization UI datum
/datum/map_serialization_ui
	/// Timer for auto-refreshing the UI during saves
	var/refresh_timer

/datum/map_serialization_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MapSerialization")
		ui.open()

/datum/map_serialization_ui/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/map_serialization_ui/ui_data(mob/user)
	var/list/data = list()
	data["z_levels"] = get_z_level_data()
	data["save_flags"] = get_save_flags_data()
	data["save_enabled"] = CONFIG_GET(flag/persistent_save_enabled)
	data["is_saving"] = SSpersistence.save_in_progress
	data["total_save_time"] = get_total_save_time()
	return data

/datum/map_serialization_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_DEBUG))
		return

	switch(action)
		if("start_save")
			if(!SSpersistence.save_in_progress && CONFIG_GET(flag/persistent_save_enabled))
				message_admins("[key_name_admin(usr)] started a map serialization save operation.")
				log_admin("[key_name(usr)] started a map serialization save operation.")

				// Start auto-refresh timer during save
				if(refresh_timer)
					deltimer(refresh_timer)
				refresh_timer = addtimer(CALLBACK(src, PROC_REF(auto_refresh)), 1 SECONDS, TIMER_LOOP)

				// Start the save operation asynchronously
				INVOKE_ASYNC(SSpersistence, TYPE_PROC_REF(/datum/controller/subsystem/persistence, save_persistent_maps))

		if("stop_save")
			if(SSpersistence.save_in_progress)
				message_admins("[key_name_admin(usr)] stopped the map serialization save operation.")
				log_admin("[key_name(usr)] stopped the map serialization save operation.")
				SSpersistence.save_in_progress = FALSE

				if(refresh_timer)
					deltimer(refresh_timer)
					refresh_timer = null
		if("toggle_z_level")
			var/z_level = text2num(params["z_level"])
			toggle_z_level_enabled(z_level)
		if("toggle_all_z_levels")
			toggle_all_z_levels()
		if("toggle_save_flag")
			var/flag = params["flag"]
			toggle_save_flag(flag)

	return TRUE

/// Auto-refresh the UI during saves and stop when complete
/datum/map_serialization_ui/proc/auto_refresh()
	if(!SSpersistence.save_in_progress)
		if(refresh_timer)
			deltimer(refresh_timer)
			refresh_timer = null
		return

	// Force UI update
	SStgui.update_uis(src)

/// Gets z-level data including real-time progress for display
/datum/map_serialization_ui/proc/get_z_level_data()
	var/list/z_level_list = list()
	var/list/persistent_save_z_levels = CONFIG_GET(keyed_list/persistent_save_z_levels)

	for(var/z in 1 to world.maxz)
		var/datum/space_level/level = SSmapping.z_list[z]
		if(!level)
			continue

		var/list/z_traits = list()
		var/enabled = FALSE

		// Determine traits and enabled status for this z-level
		if(is_station_level(z))
			z_traits += "Station"
			enabled = !!persistent_save_z_levels[ZTRAIT_STATION]
		if(is_centcom_level(z))
			z_traits += "CentCom"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_CENTCOM]
		if(is_mining_level(z))
			z_traits += "Mining"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_MINING]
		if(is_space_empty_level(z))
			z_traits += "Space Empty"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_SPACE_EMPTY]
		if(is_space_ruins_level(z))
			z_traits += "Space Ruins"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_SPACE_RUINS]
		if(is_ice_ruins_level(z))
			z_traits += "Ice Ruins"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_ICE_RUINS]
		if(is_reserved_level(z))
			z_traits += "Transit/Reserved"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_RESERVED]
		if(is_away_level(z))
			z_traits += "Away Mission"
			if(!enabled)
				enabled = !!persistent_save_z_levels[ZTRAIT_AWAY]

		// Check if this z-level is currently being processed
		var/in_progress = (SSpersistence.save_in_progress && SSpersistence.current_save_z_level == z)
		var/progress_percent = 0

		if(in_progress)
			progress_percent = SSpersistence.get_current_progress_percent()

		// Get metrics from the last save if available
		var/save_time = 0
		var/mobs_saved = 0
		var/objs_saved = 0
		var/turfs_saved = 0
		var/areas_saved = 0

		if(islist(SSpersistence.current_save_metrics))
			for(var/list/metric in SSpersistence.current_save_metrics)
				if(metric["z-level"] == z)
					save_time = metric["save_time_seconds"] || 0
					mobs_saved = metric["mobs_saved"] || 0
					objs_saved = metric["objs_saved"] || 0
					turfs_saved = metric["turfs_saved"] || 0
					areas_saved = metric["areas_saved"] || 0
					break

		z_level_list += list(list(
			"z" = z,
			"name" = level.name || "Level [z]",
			"traits" = z_traits,
			"enabled" = enabled,
			"in_progress" = in_progress,
			"progress_percent" = progress_percent,
			"save_time_seconds" = save_time,
			"mobs_saved" = mobs_saved,
			"objs_saved" = objs_saved,
			"turfs_saved" = turfs_saved,
			"areas_saved" = areas_saved
		))

	return z_level_list

/// Returns the save flags data for the UI
/datum/map_serialization_ui/proc/get_save_flags_data()
	var/save_flags = SSpersistence.get_save_flags()
	var/list/flags_data = list()

	flags_data["objects"] = !!(save_flags & SAVE_OBJECTS)
	flags_data["objects_variables"] = !!(save_flags & SAVE_OBJECTS_VARIABLES)
	flags_data["objects_properties"] = !!(save_flags & SAVE_OBJECTS_PROPERTIES)
	flags_data["mobs"] = !!(save_flags & SAVE_MOBS)
	flags_data["turfs"] = !!(save_flags & SAVE_TURFS)
	flags_data["turfs_atmos"] = !!(save_flags & SAVE_TURFS_ATMOS)
	flags_data["turfs_space"] = !!(save_flags & SAVE_TURFS_SPACE)
	flags_data["areas"] = !!(save_flags & SAVE_AREAS)
	flags_data["areas_default_shuttles"] = !!(save_flags & SAVE_AREAS_DEFAULT_SHUTTLES)
	flags_data["areas_custom_shuttles"] = !!(save_flags & SAVE_AREAS_CUSTOM_SHUTTLES)

	return flags_data

/// Gets total save time from all completed z-levels
/datum/map_serialization_ui/proc/get_total_save_time()
	if(!islist(SSpersistence.current_save_metrics))
		return 0

	var/total_time = 0
	for(var/list/metric in SSpersistence.current_save_metrics)
		total_time += metric["save_time_seconds"] || 0

	return total_time

/// Toggles the enabled state of a z-level
/datum/map_serialization_ui/proc/toggle_z_level_enabled(z_level)
	var/trait_key = get_z_level_trait_key(z_level)
	if(!trait_key)
		return FALSE

	var/list/persistent_save_z_levels = CONFIG_GET(keyed_list/persistent_save_z_levels)
	persistent_save_z_levels[trait_key] = !persistent_save_z_levels[trait_key]
	CONFIG_SET(keyed_list/persistent_save_z_levels, persistent_save_z_levels)

	return TRUE

/// Toggles all z-levels on or off
/datum/map_serialization_ui/proc/toggle_all_z_levels()
	var/list/persistent_save_z_levels = CONFIG_GET(keyed_list/persistent_save_z_levels)

	// Check if any are disabled, if so enable all, otherwise disable all
	var/enable_all = FALSE
	for(var/key in persistent_save_z_levels)
		if(!persistent_save_z_levels[key])
			enable_all = TRUE
			break

	for(var/key in persistent_save_z_levels)
		persistent_save_z_levels[key] = enable_all

	CONFIG_SET(keyed_list/persistent_save_z_levels, persistent_save_z_levels)
	return TRUE

/// Toggles a specific save flag
/datum/map_serialization_ui/proc/toggle_save_flag(flag_name)
	var/list/persistent_save_flags = CONFIG_GET(keyed_list/persistent_save_flags)

	switch(flag_name)
		if("objects")
			persistent_save_flags["objects"] = !persistent_save_flags["objects"]
		if("objects_variables")
			persistent_save_flags["objects_variables"] = !persistent_save_flags["objects_variables"]
		if("objects_properties")
			persistent_save_flags["objects_properties"] = !persistent_save_flags["objects_properties"]
		if("mobs")
			persistent_save_flags["mobs"] = !persistent_save_flags["mobs"]
		if("turfs")
			persistent_save_flags["turfs"] = !persistent_save_flags["turfs"]
		if("turfs_atmos")
			persistent_save_flags["turfs_atmos"] = !persistent_save_flags["turfs_atmos"]
		if("turfs_space")
			persistent_save_flags["turfs_space"] = !persistent_save_flags["turfs_space"]
		if("areas")
			persistent_save_flags["areas"] = !persistent_save_flags["areas"]
		if("areas_default_shuttles")
			persistent_save_flags["areas_default_shuttles"] = !persistent_save_flags["areas_default_shuttles"]
		if("areas_custom_shuttles")
			persistent_save_flags["areas_custom_shuttles"] = !persistent_save_flags["areas_custom_shuttles"]

	CONFIG_SET(keyed_list/persistent_save_flags, persistent_save_flags)
	return TRUE

/// Gets the appropriate trait key for a z-level
/datum/map_serialization_ui/proc/get_z_level_trait_key(z)
	if(is_station_level(z))
		return ZTRAIT_STATION
	if(is_centcom_level(z))
		return ZTRAIT_CENTCOM
	if(is_mining_level(z))
		return ZTRAIT_MINING
	if(is_space_empty_level(z))
		return ZTRAIT_SPACE_EMPTY
	if(is_space_ruins_level(z))
		return ZTRAIT_SPACE_RUINS
	if(is_ice_ruins_level(z))
		return ZTRAIT_ICE_RUINS
	if(is_reserved_level(z))
		return ZTRAIT_RESERVED
	if(is_away_level(z))
		return ZTRAIT_AWAY
	return null
