/obj/item/wallframe
	icon = 'icons/obj/machines/wallmounts.dmi'
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT * 2)
	obj_flags = CONDUCTS_ELECTRICITY
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/result_path
	var/wall_external = FALSE // For frames that are external to the wall they are placed on, like light fixtures and cameras.
	var/pixel_shift //The amount of pixels

/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall,user) > 1)
		balloon_alert(user, "you are too far!")
		return
	var/floor_to_wall = get_dir(user, on_wall)
	if(!(floor_to_wall in GLOB.cardinals))
		balloon_alert(user, "stand in line with wall!")
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		balloon_alert(user, "cannot place here!")
		return
	if(A.always_unpowered)
		balloon_alert(user, "cannot place in this area!")
		return
	if(check_wall_item(T, floor_to_wall, wall_external))
		balloon_alert(user, "already something here!")
		return

	return TRUE

/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] attaches [src] to the wall."),
			span_notice("You attach [src] to the wall."),
			span_hear("You hear clicking."))
		var/floor_to_wall = get_dir(user, on_wall)

		var/obj/hanging_object = new result_path(get_turf(user), floor_to_wall, TRUE)
		hanging_object.setDir(floor_to_wall)
		if(pixel_shift)
			switch(floor_to_wall)
				if(NORTH)
					hanging_object.pixel_y = pixel_shift
				if(SOUTH)
					hanging_object.pixel_y = -pixel_shift
				if(EAST)
					hanging_object.pixel_x = pixel_shift
				if(WEST)
					hanging_object.pixel_x = -pixel_shift
		after_attach(hanging_object)

	qdel(src)

/obj/item/wallframe/proc/after_attach(obj/attached_to)
	transfer_fingerprints_to(attached_to)

/obj/item/wallframe/screwdriver_act(mob/living/user, obj/item/tool)
	// For camera-building borgs
	var/turf/wall_turf = get_step(get_turf(user), user.dir)
	if(iswallturf(wall_turf))
		wall_turf.item_interaction(user, src)
	return ITEM_INTERACT_SUCCESS

/obj/item/wallframe/wrench_act(mob/living/user, obj/item/tool)
	var/metal_amt = round(custom_materials[GET_MATERIAL_REF(/datum/material/iron)]/SHEET_MATERIAL_AMOUNT) //Replace this shit later
	var/glass_amt = round(custom_materials[GET_MATERIAL_REF(/datum/material/glass)]/SHEET_MATERIAL_AMOUNT) //Replace this shit later

	if(!metal_amt && !glass_amt)
		return FALSE
	to_chat(user, span_notice("You dismantle [src]."))
	tool.play_tool_sound(src)
	if(metal_amt)
		new /obj/item/stack/sheet/iron(get_turf(src), metal_amt)
	if(glass_amt)
		new /obj/item/stack/sheet/glass(get_turf(src), glass_amt)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/electronics
	desc = "Looks like a circuit. Probably is."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "door_electronics"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 0.5)
	grind_results = list(/datum/reagent/iron = 10, /datum/reagent/silicon = 10)
	custom_price = PAYCHECK_CREW * 0.5
