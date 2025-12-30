/obj/item/wallframe
	icon = 'icons/obj/machines/wallmounts.dmi'
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT * 2)
	obj_flags = CONDUCTS_ELECTRICITY
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	///The final object to construct after mount
	var/result_path
	/// For frames that are external to the wall they are placed on, like light fixtures and cameras.
	var/wall_external = FALSE
	//The amount of pixels to shift when mounted
	var/pixel_shift

/**
 * Returns an structure to mount on from the atom passed
 * for e.g if its not an closed turf then return an structure on the turf to mount on
 * Arguments
 * * atom/structure - the atom or something in this atom we are trying to mount on
*/
/obj/item/wallframe/proc/find_support_structure(atom/structure)
	SHOULD_BE_PURE(TRUE)

	return isclosedturf(structure) ? structure : null

/obj/item/wallframe/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/atom/support_structure = find_support_structure(interacting_with)
	if(isnull(support_structure))
		return NONE
	if(!try_build(support_structure, user))
		return ITEM_INTERACT_FAILURE

	playsound(loc, 'sound/machines/click.ogg', 75, TRUE)
	user.visible_message(span_notice("[user.name] attaches [src] to the wall."),
		span_notice("You attach [src] to the wall."),
		span_hear("You hear clicking."))

	var/floor_to_support = get_dir(user, support_structure)
	var/obj/hanging_object = new result_path(get_turf(user))
	hanging_object.setDir(floor_to_support)
	if(pixel_shift)
		switch(floor_to_support)
			if(NORTH)
				hanging_object.pixel_y = pixel_shift
			if(SOUTH)
				hanging_object.pixel_y = -pixel_shift
			if(EAST)
				hanging_object.pixel_x = pixel_shift
			if(WEST)
				hanging_object.pixel_x = -pixel_shift
	if(!istype(get_area(user), /area/shuttle)) //due to turf changing issue we don't mount here for now
		hanging_object.AddComponent(/datum/component/atom_mounted, support_structure)
	after_attach(hanging_object)
	qdel(src)

	return ITEM_INTERACT_SUCCESS

/**
 * Check if we can build on this support structure
 *
 * Arguments
 * * atom/support - the atom we are trying to mount on
 * * mob/user - the player attempting to do the mount
*/
/obj/item/wallframe/proc/try_build(atom/support, mob/user)
	if(get_dist(support, user) > 1)
		balloon_alert(user, "you are too far!")
		return FALSE
	var/floor_to_support = get_dir(user, support)
	if(!(floor_to_support in GLOB.cardinals))
		balloon_alert(user, "stand in line with wall!")
		return FALSE
	var/turf/T = get_turf(user)
	if(!isfloorturf(T))
		balloon_alert(user, "cannot place here!")
		return FALSE
	if(check_wall_item(T, floor_to_support, wall_external))
		balloon_alert(user, "already something here!")
		return FALSE

	return TRUE

/**
 * Stuff to do after wallframe attached to support atom
 *
 * Arguments
 * * obj/attached_to - the object that has been created on the atom
*/
/obj/item/wallframe/proc/after_attach(obj/attached_to)
	transfer_fingerprints_to(attached_to)

/obj/item/wallframe/screwdriver_act(mob/living/user, obj/item/tool)
	return interact_with_atom(get_step(get_turf(user), user.dir), user)

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
	custom_price = PAYCHECK_CREW * 0.5
	sound_vary = TRUE
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP

/obj/item/electronics/grind_results()
	return list(/datum/reagent/iron = 10, /datum/reagent/silicon = 10)
