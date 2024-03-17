/datum/forklift_module/furniture
	name = "Basic Furniture"
	current_selected_typepath = /obj/structure/table
	available_builds = list(
		/obj/structure/table,
		/obj/structure/table/glass,
		/obj/structure/table/wood,
		/obj/structure/table/wood/fancy,
		/obj/structure/table/wood/poker,
		/obj/structure/chair,
		/obj/structure/chair/wood,
		/obj/structure/chair/wood/wings,
		/obj/structure/chair/office,
		/obj/structure/chair/office/light,
		/obj/structure/chair/comfy/beige,
		/obj/structure/grille,
		/obj/structure/window,
		/obj/structure/window/fulltile,
		/obj/structure/window/reinforced,
		/obj/structure/window/reinforced/fulltile,
		/obj/structure/closet,
	)
	resource_price = list(
		/obj/structure/table/wood = list(
			/datum/material/wood = SHEET_MATERIAL_AMOUNT * 3,
		),
		/obj/structure/table/wood/fancy = list(
			/datum/material/wood = SHEET_MATERIAL_AMOUNT * 3,
		),
		/obj/structure/table/wood/poker = list(
			/datum/material/wood = SHEET_MATERIAL_AMOUNT * 3,
		),
		/obj/structure/table/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/structure/table = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		),
		/obj/structure/chair/wood = list(
			/datum/material/wood = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/structure/chair/wood/wings = list(
			/datum/material/wood = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/structure/chair/office = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/structure/chair/office/light = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/structure/chair/comfy/beige = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/structure/chair = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/structure/grille = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1, // 1 sheet = 2 rods = 1 grille
		),
		/obj/structure/window/reinforced/fulltile = list(
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/structure/window/reinforced = list(
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5,
		),
		/obj/structure/window/fulltile = list(
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/structure/window = list(
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		),
		/obj/structure/closet = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		),
	)
	build_length = 1 SECONDS
	deconstruction_cooldown = 5 SECONDS

/datum/forklift_module/furniture/valid_placement_location(location)
	if(istype(location, /turf/open/floor))
		return TRUE
	else
		return FALSE
