/obj/machinery/camera
	var/nanomap_png

/obj/machinery/camera/Initialize(mapload, should_add_to_cameranet)
	. = ..()
	var/datum/space_level/z_level = LAZYACCESS(SSmapping.z_list, z)
	if(isnull(z_level))
		return
	if(z_level.name == "Lavaland")
		nanomap_png = "Lavaland_nanomap_z1.png"
		return
	if(!findtext(z_level.name, "Station"))
		return
	nanomap_png = "[SSmapping.config.map_name]_nanomap_z[z-1].png" // Station starts at Z-level 2

/obj/machinery/computer/security
	var/list/z_levels = list() // Assoc list, "z_level":"nanomap.png"
	var/current_z_level_index

/obj/machinery/computer/security/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/obj/machinery/computer/security/ui_act(action, params)
	. = ..()
	if(. && action == "switch_camera")
		if(!active_camera)
			return
		current_z_level_index = z_levels.Find("[active_camera.z]")
	if(.)
		return

	if(action == "switch_z_level")
		var/z_dir = params["z_dir"]
		current_z_level_index = clamp(current_z_level_index + z_dir, 1, length(z_levels))
		return TRUE

/obj/machinery/computer/security/ui_data()
	var/list/data = ..()
	if(!length(z_levels))
		return data
	if(isnull(current_z_level_index))
		current_z_level_index = clamp(z_levels.Find("[z]"), 1, length(z_levels))
	else
		current_z_level_index = clamp(current_z_level_index, 1, length(z_levels))
	// On null, it doesn't give runtime errors on tgui side; empty map
	data["mapUrl"] = LAZYACCESS(z_levels, "[z_levels[current_z_level_index]]")
	data["selected_z_level"] = LAZYACCESS(z_levels, current_z_level_index)
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = ..()
	// Sort it by z levels
	z_levels = sort_list(z_levels)
	return data
