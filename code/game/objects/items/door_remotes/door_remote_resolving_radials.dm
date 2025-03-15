/obj/item/door_remote/proc/resolve_radial_options(modes_or_responses)
	var/list/resolved_options
	var/list/radial_images
	var/is_emagged = obj_flags & EMAGGED
	if(modes_or_responses != "modes" && modes_or_responses != "responses")
		CRASH("Invalid argument to resolve_radial_options")
	if(modes_or_responses == "modes")
		resolved_options = SSdoor_remote_routing.standard_modes.Copy()
		if(is_emagged)
			resolved_options.Add(SSdoor_remote_routing.emag_mode)
		if(department_name in GLOB.door_remote_radial_images)
			radial_images = GLOB.door_remote_radial_images[department_name]
		else
			radial_images = GLOB.door_remote_radial_images[REGION_ALL_STATION]
	else
		resolved_options = SSdoor_remote_routing.standard_responses.Copy()
		if(is_emagged)
			resolved_options.Add(SSdoor_remote_routing.emag_response)
		radial_images = GLOB.door_remote_radial_images[REQUEST_RESPONSES]
	for(var/option in resolved_options)
		resolved_options[option] = radial_images[option]
	return resolved_options
