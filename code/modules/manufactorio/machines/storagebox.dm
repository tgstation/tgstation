/obj/machinery/power/manufacturing/storagebox
	name = "manufacturing storage unit"
	desc = "Its basically a box. Receives resources (if anchored). Needs a machine to take stuff out of without dumping everything out."
	icon_state = "box"
	var/datum/component/remote_materials/rmat
	var/datum/material/selected_material = null // The material type selected for retrieval
	var/processing_speed = 6 SECONDS
	var/activated = FALSE

	COOLDOWN_DECLARE(process_speed)


/obj/machinery/power/manufacturing/silobox/Initialize(mapload)
	. = ..()
	rmat = AddComponent(/datum/component/remote_materials, mapload)


/obj/machinery/power/manufacturing/silobox/attack_hand(mob/user, list/modifiers)
	if(modifiers && modifiers.Find(RIGHT_CLICK)) // Right-click to select material
		var/list/materials = rmat?.mat_container?.materials
		if (!materials || !length(materials))
			to_chat(user, "<span class='warning'>No materials available in the connected silo.</span>")
			return

		var/list/material_choices = list()
		var/list/name_to_type = list()
		for(var/mat_type in materials)
			var/datum/material/M = GET_MATERIAL_REF(mat_type)
			if(!M) continue
			var/obj/item/stack/sheet/display = initial(M.sheet_type)
			material_choices[M.name] = image(icon = initial(display.icon), icon_state = initial(display.icon_state))
			name_to_type[M.name] = M

		var/new_material_name = show_radial_menu(user, src, material_choices, require_near = TRUE)
		if(new_material_name)
			selected_material = name_to_type[new_material_name]
			to_chat(user, "<span class='notice'>Selected [selected_material.name] for retrieval.</span>")
		return

	// Left-click activate/deactivate

	if (!selected_material)
		to_chat(user, "<span class='notice'>No material selected.</span>")
		return
	activated = !activated
	if(activated)
		to_chat(user, "<span class='notice'>Silo retrieval activated.</span>")
	else
		to_chat(user, "<span class='notice'>Silo retrieval deactivated.</span>")




/obj/machinery/power/manufacturing/silobox/process()
	if(!check_factors())
		return

	rmat.eject_sheets(selected_material, 5, src.loc, SILICON_OVERRIDE)

/obj/machinery/power/manufacturing/silobox/proc/check_factors()


	if(!COOLDOWN_FINISHED(src, process_speed))
		return FALSE

	COOLDOWN_START(src, process_speed, processing_speed)

	// Left-click to retrieve material
	if (!selected_material)
		return FALSE

	if (!activated)
		return FALSE

	//we are ready to go
	return TRUE

/obj/machinery/power/manufacturing/request_resource() //returns last inserted item
	var/list/real_contents = contents - circuit
	if(!length(real_contents))
		return
	return (real_contents)[length(real_contents)]

/obj/machinery/power/manufacturing/storagebox/container_resist_act(mob/living/user)
	. = ..()
	user.Move(drop_location())

/obj/machinery/power/manufacturing/storagebox/screwdriver_act(mob/living/user, obj/item/tool)
	. = NONE
	balloon_alert(user, "disassembling...")
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_FAILURE
	atom_destruction()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/storagebox/atom_destruction(damage_flag)
	new /obj/item/stack/sheet/iron(drop_location(), 10)
	dump_inventory_contents()
	return ..()

/obj/machinery/power/manufacturing/storagebox/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		return
	balloon_alert(user, "dumping..")
	if(!do_after(user, 1.25 SECONDS, src))
		return
	dump_inventory_contents()
