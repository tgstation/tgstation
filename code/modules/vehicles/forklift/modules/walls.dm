/datum/forklift_module/walls
	name = "Walls"
	current_selected_typepath = /turf/closed/wall
	available_builds = list(
		/turf/closed/wall,
		/turf/closed/wall/r_wall,
		/turf/closed/wall/mineral/iron,
		/turf/closed/wall/mineral/silver,
		/turf/closed/wall/mineral/gold,
		/turf/closed/wall/mineral/diamond,
		/turf/closed/wall/mineral/plasma,
		/turf/closed/wall/mineral/uranium,
		/turf/closed/wall/mineral/bananium,
	)
	resource_price = list(
		/turf/closed/wall = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		),
		/turf/closed/wall/r_wall = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
			/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2, // r-walls are an alloy of 1 iron and 1 plasma, so we assume the RAT just alloys it on the spot
		),
		/turf/closed/wall/mineral/iron = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		),
		/turf/closed/wall/mineral/silver = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
		),
		/turf/closed/wall/mineral/gold = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		),
		/turf/closed/wall/mineral/diamond = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 2,
		),
		/turf/closed/wall/mineral/plasma = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2,
		),
		/turf/closed/wall/mineral/uranium = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 2,
		),
		/turf/closed/wall/mineral/bananium = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/bananium = SHEET_MATERIAL_AMOUNT * 2,
		),
	)
	build_length = 5 SECONDS
	turf_place_on_top = TRUE

/datum/forklift_module/walls/valid_placement_location(location)
	if(istype(location, /turf/open/floor))
		return TRUE
	else
		return FALSE
