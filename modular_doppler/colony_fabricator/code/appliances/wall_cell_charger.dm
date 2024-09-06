/obj/machinery/cell_charger_multi/wall_mounted
	name = "mounted multi-cell charging rack"
	desc = "The innovative technology of a cell charging rack, but mounted neatly on a wall out of the way!"
	icon = 'modular_doppler/colony_fabricator/icons/cell_charger.dmi'
	icon_state = "wall_charger"
	base_icon_state = "wall_charger"
	circuit = null
	max_batteries = 3
	charge_rate = STANDARD_CELL_RATE * 3
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/wallframe/cell_charger_multi

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/cell_charger_multi/wall_mounted, 29)

/obj/machinery/cell_charger_multi/wall_mounted/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/cell_charger_multi/wall_mounted/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	user.balloon_alert(user, "deconstructing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return

// formerly NO_DECONSTRUCTION
/obj/machinery/cell_charger_multi/wall_mounted/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/cell_charger_multi/wall_mounted/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/cell_charger_multi/wall_mounted/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/cell_charger_multi/wall_mounted/on_deconstruction(disassembled)
	if(disassembled)
		new repacked_type(drop_location())

/obj/machinery/cell_charger_multi/wall_mounted/RefreshParts()
	. = ..()
	charge_rate = STANDARD_CELL_RATE * 3 // Nuh uh!

// Item for creating the arc furnace or carrying it around

/obj/item/wallframe/cell_charger_multi
	name = "unmounted wall multi-cell charging rack"
	desc = "The innovative technology of a cell charging rack, but able to be mounted neatly on a wall out of the way!"
	icon = 'modular_doppler/colony_fabricator/icons/packed_machines.dmi'
	icon_state = "cell_charger_packed"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/cell_charger_multi/wall_mounted
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
