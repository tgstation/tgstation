/obj/machinery/sheetifier
	name = "Sheet-meister 2000"
	desc = "A very sheety machine"
	icon = 'icons/obj/machines/sheetifier.dmi'
	icon_state = "base_machine"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/sheetifier
	layer = BELOW_OBJ_LAYER
	var/busy_processing = FALSE
	var/datum/component/material_container/materials_comp

	var/eat_dir = WEST

/obj/machinery/sheetifier/Initialize(mapload)
	. = ..()

	materials_comp = AddComponent(/datum/component/material_container, list(/datum/material/meat, /datum/material/hauntium), MINERAL_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, MATCONTAINER_EXAMINE|BREAKDOWN_FLAGS_SHEETIFIER, typesof(/datum/material/meat) + /datum/material/hauntium, list(/obj/item/food/meat, /obj/item/photo), null, CALLBACK(src, .proc/CanInsertMaterials), CALLBACK(src, .proc/AfterInsertMaterials))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/sheetifier/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(border_dir == eat_dir)
		return !busy_processing && materials_comp.get_item_material_amount(mover)

/obj/machinery/sheetifier/proc/on_entered(datum/source, atom/movable/enterer)
	materials_comp.userless_insert(enterer)

/obj/machinery/sheetifier/update_overlays()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		return
	var/mutable_appearance/on_overlay = mutable_appearance(icon, "buttons_on")
	. += on_overlay

/obj/machinery/sheetifier/update_icon_state()
	icon_state = "base_machine[busy_processing ? "_processing" : ""]"
	return ..()

/obj/machinery/sheetifier/proc/CanInsertMaterials()
	return !busy_processing

/obj/machinery/sheetifier/proc/AfterInsertMaterials(item_inserted, id_inserted, amount_inserted)
	busy_processing = TRUE
	update_appearance()
	var/datum/material/last_inserted_material = id_inserted
	var/mutable_appearance/processing_overlay = mutable_appearance(icon, "processing")
	processing_overlay.color = last_inserted_material.color
	flick_overlay_static(processing_overlay, src, 64)
	addtimer(CALLBACK(src, .proc/finish_processing), 64)

/obj/machinery/sheetifier/proc/finish_processing()
	busy_processing = FALSE
	update_appearance()
	materials_comp.retrieve_all() //Returns all as sheets

/obj/machinery/sheetifier/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/sheetifier/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		update_appearance()
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()
