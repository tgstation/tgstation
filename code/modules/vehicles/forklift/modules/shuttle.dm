/datum/forklift_module/shuttle
	name = "Shuttle"
	current_selected_typepath = /turf/open/floor/mineral/titanium
	available_builds = list(
		/turf/open/floor/mineral/titanium,
		/turf/open/floor/mineral/titanium/blue,
		/turf/open/floor/mineral/titanium/purple,
		/turf/open/floor/mineral/titanium/white,
		/turf/open/floor/mineral/titanium/yellow,
		/turf/open/floor/mineral/plastitanium/red,
		/turf/closed/wall/mineral/titanium,
		/obj/structure/chair/comfy/shuttle,
		/obj/structure/grille,
		/obj/structure/window/reinforced/shuttle,
	)
	resource_price = list(
		/turf/open/floor/mineral/titanium = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25, // 1 rod for lattice = 0.5 iron, 1 floor tile for plating = 0.25 iron, 1 floor tile for covering = 0.25 titanium
		),
		/turf/open/floor/mineral/titanium/blue = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/turf/open/floor/mineral/titanium/purple = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/turf/open/floor/mineral/titanium/white = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/turf/open/floor/mineral/titanium/yellow = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25,
		),
		/turf/open/floor/mineral/plastitanium/red = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.125,
			/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 0.125,
		),
		/turf/closed/wall/mineral/titanium = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/structure/chair/comfy/shuttle = list(
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/structure/grille = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1, // 1 sheet = 2 rods = 1 grille
		),
		/obj/structure/window/reinforced/shuttle = list(
			/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2,
		),
	)
	build_length = 10 SECONDS
	deconstruction_cooldown = 10 SECONDS
	turf_place_on_top = TRUE

/datum/forklift_module/shuttle/valid_placement_location(location)
	if(ispath(current_selected_typepath, /turf/open/floor))
		if(istype(location, /turf/open/openspace) || istype(location, /turf/open/misc) || istype(location, /turf/open/space))
			return TRUE
		else
			return FALSE
	else
		if(istype(location, /turf/open/floor))
			return TRUE
		else
			return FALSE
