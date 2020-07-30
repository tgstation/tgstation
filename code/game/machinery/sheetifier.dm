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

/obj/machinery/sheetifier/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/meat), MINERAL_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, TRUE, /obj/item/reagent_containers/food/snacks/meat/slab, CALLBACK(src, .proc/CanInsertMaterials), CALLBACK(src, .proc/AfterInsertMaterials))

/obj/machinery/sheetifier/update_overlays()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		return
	var/mutable_appearance/on_overlay = mutable_appearance(icon, "buttons_on")
	. += on_overlay

/obj/machinery/sheetifier/update_icon_state()
	icon_state = "base_machine[busy_processing ? "_processing" : ""]"

/obj/machinery/sheetifier/proc/CanInsertMaterials()
	return !busy_processing

/obj/machinery/sheetifier/proc/AfterInsertMaterials(item_inserted, id_inserted, amount_inserted)
	busy_processing = TRUE
	update_icon()
	var/datum/material/last_inserted_material = id_inserted
	var/mutable_appearance/processing_overlay = mutable_appearance(icon, "processing")
	processing_overlay.color = last_inserted_material.color
	flick_overlay_static(processing_overlay, src, 64)
	addtimer(CALLBACK(src, .proc/finish_processing), 64)

/obj/machinery/sheetifier/proc/finish_processing()
	busy_processing = FALSE
	update_icon()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all() //Returns all as sheets

/obj/machinery/sheetifier/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()
