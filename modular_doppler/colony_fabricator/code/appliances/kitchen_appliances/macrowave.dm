/obj/machinery/microwave/frontier_printed
	desc = "A plastic-paneled microwave oven, capable of doing anything a standard microwave could do. \
		This one is special designed to be tightly packed into a shape that can be easily re-assembled \
		later from the factory. There don't seem to be included instructions on getting it folded back \
		together, though..."
	icon = 'modular_doppler/colony_fabricator/icons/kitchen_stuff/microwave.dmi'
	circuit = null
	max_n_of_items = 5
	efficiency = 2
	vampire_charging_capable = TRUE

/obj/machinery/microwave/frontier_printed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/microwave/frontier_printed/RefreshParts()
	. = ..()
	max_n_of_items = 5
	efficiency = 2
	vampire_charging_capable = TRUE

/obj/machinery/microwave/frontier_printed/examine(mob/user)
	. = ..()
	. += span_notice("It cannot be repacked, but can be deconstructed normally.")

/obj/machinery/microwave/frontier_printed/unanchored
	anchored = FALSE

// Deployable item for cargo

/obj/item/flatpacked_machine/macrowave
	name = "microwave oven parts kit"
	icon = 'modular_doppler/colony_fabricator/icons/kitchen_stuff/microwave.dmi'
	icon_state = "packed_microwave"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/microwave/frontier_printed
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
