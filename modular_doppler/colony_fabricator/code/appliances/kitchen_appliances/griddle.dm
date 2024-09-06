/obj/machinery/griddle/frontier_tabletop
	name = "tabletop griddle"
	desc = "A griddle type slim enough to fit atop a table without much fuss. This type in particular \
		was made to be broken down into many parts and shipped across the glaxy. This makes it a favourite in \
		pop-up food stalls and colony kitchens all around."
	icon = 'modular_doppler/colony_fabricator/icons/kitchen_stuff/griddle.dmi'
	icon_state = "griddletable_off"
	variant = "table"
	pass_flags_self = LETPASSTHROW
	pass_flags = PASSTABLE
	circuit = null
	// Lines up perfectly with tables when anchored on them
	anchored_tabletop_offset = 3
	/// What type this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/frontier_griddle

/obj/machinery/griddle/frontier_tabletop/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/griddle/frontier_tabletop/unanchored
	anchored = FALSE

// Deployable item for cargo

/obj/item/flatpacked_machine/frontier_griddle
	name = "flat-packed tabletop griddle"
	icon = 'modular_doppler/colony_fabricator/icons/kitchen_stuff/griddle.dmi'
	icon_state = "griddle_parts"
	w_class = WEIGHT_CLASS_NORMAL
	type_to_deploy = /obj/machinery/griddle/frontier_tabletop
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
