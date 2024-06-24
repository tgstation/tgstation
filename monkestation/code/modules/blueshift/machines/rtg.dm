/obj/machinery/power/rtg/portable
	name = "radioisotope thermoelectric generator"
	desc = "The ultimate in 'middle of nowhere' power generation. Unlike standard RTGs, this particular \
		design of generator has forgone the heavy radiation shielding that most RTG designs include. \
		In better news, these tend to be pretty good with making a passable trickle of power for any \
		application."
	icon = 'monkestation/code/modules/blueshift/icons/machines.dmi'
	circuit = null
	power_gen = 7500
	/// What we turn into when we are repacked
	var/repacked_type = /obj/item/flatpacked_machine/rtg

/obj/machinery/power/rtg/portable/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/radioactive)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	if(!mapload)
		flick("rtg_deploy", src)

// previously NO_DECONSTRUCTION
/obj/machinery/power/rtg/portable/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/power/rtg/portable/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/power/rtg/portable/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

// Item for creating the arc furnace or carrying it around
/obj/item/flatpacked_machine/rtg
	name = "flat-packed radioisotope thermoelectric generator"
	icon_state = "rtg_packed"
	type_to_deploy = /obj/machinery/power/rtg/portable
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
