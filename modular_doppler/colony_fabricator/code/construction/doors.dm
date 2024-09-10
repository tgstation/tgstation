// Shutters

/obj/machinery/door/poddoor/shutters/colony_fabricator
	name = "prefab shutters"
	icon = 'modular_doppler/colony_fabricator/icons/doors/shutter.dmi'

/obj/machinery/door/poddoor/shutters/colony_fabricator/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/colony_fabricator/animation_effects(animation)
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			playsound(src, animation_sound, 30, TRUE)
		if(DOOR_CLOSING_ANIMATION)
			playsound(src, animation_sound, 30, TRUE)

/obj/item/flatpacked_machine/shutter_kit
	name = "prefab shutters parts kit"
	icon = 'modular_doppler/colony_fabricator/icons/doors/packed.dmi'
	icon_state = "shutters_parts"
	type_to_deploy = /obj/machinery/door/poddoor/shutters/colony_fabricator/preopen
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)

// Airlocks

/obj/machinery/door/airlock/colony_prefab
	name = "prefab airlock"
	icon = 'modular_doppler/colony_fabricator/icons/doors/airlock.dmi'
	overlays_file = 'modular_doppler/colony_fabricator/icons/doors/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_colony_prefab

/obj/structure/door_assembly/door_assembly_colony_prefab
	name = "prefab airlock assembly"
	icon = 'modular_doppler/colony_fabricator/icons/doors/airlock.dmi'
	base_name = "prefab airlock"
	airlock_type = /obj/machinery/door/airlock/colony_prefab
	noglass = TRUE

/obj/item/flatpacked_machine/airlock_kit
	name = "prefab airlock parts kit"
	icon = 'modular_doppler/colony_fabricator/icons/doors/packed.dmi'
	icon_state = "airlock_parts"
	type_to_deploy = /obj/machinery/door/airlock/colony_prefab
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
