/datum/forklift_module/floors
	name = "Floors"
	current_selected_typepath = /turf/open/floor/iron
	available_builds = list(/turf/open/floor/iron) // Populated on New
	resource_price = list(
		/turf/open/floor/iron = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1, // 1 rod for lattice = 0.5 iron, 1 floor tile for plating = 0.25 iron, 1 floor tile for covering = 0.25 iron
		),
	)
	build_length = 5 SECONDS
	turf_place_on_top = TRUE
	show_name_on_change = FALSE
	deconstruction_cooldown = 10 SECONDS

/datum/forklift_module/floors/New()
	. = ..()
	for(var/typepath in typesof(/turf/open/floor/iron))
		var/turf/open/floor/iron/checked_path = typepath
		if(initial(checked_path.initial_gas_mix) == OPENTURF_DEFAULT_ATMOS)
			available_builds += typepath
			resource_price[typepath] = list(
				/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1,
			)
		continue

/datum/forklift_module/floors/valid_placement_location(location)
	if(istype(location, /turf/open/openspace) || istype(location, /turf/open/misc) || istype(location, /turf/open/space))
		return TRUE
	else
		return FALSE
