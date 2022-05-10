/obj/item/wallframe
	icon = 'icons/obj/wallframe.dmi'
	custom_materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT*2)
	flags_1 = CONDUCT_1
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/result_path
	var/wall_external = FALSE // For frames that are external to the wall they are placed on, like light fixtures and cameras.
	var/pixel_shift //The amount of pixels

/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall,user)>1)
		return
	var/floor_to_wall = get_dir(user, on_wall)
	if(!(floor_to_wall in GLOB.cardinals))
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(user, span_warning("You cannot place [src] on this spot!"))
		return
	if(A.always_unpowered)
		to_chat(user, span_warning("You cannot place [src] in this area!"))
		return
	if(check_wall_item(T, floor_to_wall, wall_external))
		to_chat(user, span_warning("There's already an item on this wall!"))
		return

	return TRUE

/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] attaches [src] to the wall."),
			span_notice("You attach [src] to the wall."),
			span_hear("You hear clicking."))
		var/floor_to_wall = get_dir(user, on_wall)

		var/obj/O = new result_path(get_turf(user), floor_to_wall, TRUE)
		O.setDir(floor_to_wall)

		if(pixel_shift)
			switch(floor_to_wall)
				if(NORTH)
					O.pixel_y = pixel_shift
				if(SOUTH)
					O.pixel_y = -pixel_shift
				if(EAST)
					O.pixel_x = pixel_shift
				if(WEST)
					O.pixel_x = -pixel_shift
		after_attach(O)

	qdel(src)

/obj/item/wallframe/proc/after_attach(obj/O)
	transfer_fingerprints_to(O)

/obj/item/wallframe/screwdriver_act(mob/living/user, obj/item/tool)
	// For camera-building borgs
	var/turf/T = get_step(get_turf(user), user.dir)
	if(iswallturf(T))
		T.attackby(src, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/wallframe/wrench_act(mob/living/user, obj/item/tool)
	var/metal_amt = round(custom_materials[GET_MATERIAL_REF(/datum/material/iron)]/MINERAL_MATERIAL_AMOUNT) //Replace this shit later
	var/glass_amt = round(custom_materials[GET_MATERIAL_REF(/datum/material/glass)]/MINERAL_MATERIAL_AMOUNT) //Replace this shit later

	if(!metal_amt && !glass_amt)
		return FALSE
	to_chat(user, span_notice("You dismantle [src]."))
	if(metal_amt)
		new /obj/item/stack/sheet/iron(get_turf(src), metal_amt)
	if(glass_amt)
		new /obj/item/stack/sheet/glass(get_turf(src), glass_amt)
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/electronics
	desc = "Looks like a circuit. Probably is."
	icon = 'icons/obj/module.dmi'
	icon_state = "door_electronics"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)
	grind_results = list(/datum/reagent/iron = 10, /datum/reagent/silicon = 10)
	custom_price = PAYCHECK_CREW * 0.5
