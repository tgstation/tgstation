// Solar panels

/obj/machinery/power/solar/deployable
	icon = 'modular_doppler/colony_fabricator/icons/machines.dmi'
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/solar

/obj/machinery/power/solar/deployable/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 1 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/power/solar/deployable/crowbar_act(mob/user, obj/item/I)
	return

/obj/machinery/power/solar/deployable/on_deconstruction(disassembled)
	var/obj/item/solar_assembly/assembly = locate() in src
	if(assembly)
		qdel(assembly)
	return ..()

// formerly NO_DECONSTRUCTION
/obj/machinery/power/solar/deployable/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/power/solar/deployable/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/power/solar/deployable/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

// Solar panel deployable item

/obj/item/flatpacked_machine/solar
	name = "flat-packed solar panel"
	icon_state = "solar_panel_packed"
	type_to_deploy = /obj/machinery/power/solar/deployable
	deploy_time = 2 SECONDS
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT * 3,
	)

// Solar trackers

/obj/machinery/power/tracker/deployable
	icon = 'modular_doppler/colony_fabricator/icons/machines.dmi'
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/solar_tracker

/obj/machinery/power/tracker/deployable/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 1 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/power/tracker/deployable/crowbar_act(mob/user, obj/item/item_acting)
	return NONE

// formerly NO_DECONSTRUCTION
/obj/machinery/power/tracker/deployable/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/power/tracker/deployable/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/power/tracker/deployable/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/power/tracker/deployable/on_deconstruction(disassembled)
	var/obj/item/solar_assembly/assembly = locate() in src
	if(assembly)
		qdel(assembly)
	return ..()

// Solar tracker deployable item

/obj/item/flatpacked_machine/solar_tracker
	name = "flat-packed solar tracker"
	icon_state = "solar_tracker_packed"
	type_to_deploy = /obj/machinery/power/tracker/deployable
	deploy_time = 3 SECONDS
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT * 3.5,
	)
