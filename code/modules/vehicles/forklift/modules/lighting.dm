/datum/forklift_module/lighting
	name = "Lights"
	module_ui_display_atom_typepath = /obj/machinery/light/small
	current_selected_typepath = /obj/machinery/light/small
	available_builds = list(
		/obj/machinery/light/small,
		/obj/machinery/light,
	)
	resource_price = list(
		/obj/machinery/light/small = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
		),
		/obj/machinery/light = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		),
	)
	build_length = 2 SECONDS

/datum/forklift_module/lighting/valid_placement_location(location)
	var/obj/possible_light = locate(/obj/machinery/door/airlock) in location
	if(possible_light) // cant stack lights if they're on the same direction
		if(possible_light.dir == direction)
			return FALSE
	if(istype(location, /turf/open/floor))
		var/turf/possible_wall = get_step(location, direction)
		if(istype(possible_wall, /turf/closed)) // gotta put lights on walls
			return TRUE
		else
			return FALSE
	else
		return FALSE
