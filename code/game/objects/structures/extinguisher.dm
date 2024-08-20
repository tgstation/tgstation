/obj/structure/extinguisher_cabinet
	name = "extinguisher rack"
	desc = "A small wall mounted rack designed to hold a fire extinguisher."
	icon = 'icons/obj/structures/cabinet.dmi'
	icon_state = "rack"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	integrity_failure = 0.25
	var/obj/item/extinguisher/stored_extinguisher

WALL_MOUNT_DIRECTIONAL_HELPERS(/obj/structure/extinguisher_cabinet)

/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	if(!building)
		stored_extinguisher = new /obj/item/extinguisher(src)
	update_appearance(UPDATE_ICON)
	register_context()
	find_and_hang_on_wall()
	AddComponent(/datum/component/examine_balloon, pixel_y_offset = 36)

/obj/structure/extinguisher_cabinet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		if(stored_extinguisher)
			context[SCREENTIP_CONTEXT_LMB] = "Take extinguisher"
		return CONTEXTUAL_SCREENTIP_SET

	if(stored_extinguisher)
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Disassemble cabinet"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/extinguisher))
		context[SCREENTIP_CONTEXT_LMB] = "Insert extinguisher"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/structure/extinguisher_cabinet/Destroy()
	if(stored_extinguisher)
		QDEL_NULL(stored_extinguisher)
	return ..()

/obj/structure/extinguisher_cabinet/contents_explosion(severity, target)
	if(!stored_extinguisher)
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += stored_extinguisher
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += stored_extinguisher
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += stored_extinguisher

/obj/structure/extinguisher_cabinet/Exited(atom/movable/gone, direction)
	if(gone == stored_extinguisher)
		stored_extinguisher = null
		update_appearance(UPDATE_ICON)

/obj/structure/extinguisher_cabinet/attackby(obj/item/used_item, mob/living/user, params)
	if(used_item.tool_behaviour == TOOL_WRENCH && !stored_extinguisher)
		user.balloon_alert(user, "deconstructing rack...")
		used_item.play_tool_sound(src)
		if(used_item.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			user.balloon_alert(user, "rack deconstructed")
			deconstruct(TRUE)
		return

	if(iscyborg(user) || isalien(user))
		return
	if(istype(used_item, /obj/item/extinguisher))
		if(!stored_extinguisher)
			if(!user.transferItemToLoc(used_item, src))
				return
			stored_extinguisher = used_item
			user.balloon_alert(user, "extinguisher stored")
			update_appearance(UPDATE_ICON)
			return TRUE
		else
			return
	else
		return ..()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(stored_extinguisher)
		user.put_in_hands(stored_extinguisher)
		user.balloon_alert(user, "extinguisher removed")

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	if(stored_extinguisher)
		stored_extinguisher.forceMove(loc)
		to_chat(user, span_notice("You telekinetically remove [stored_extinguisher] from [src]."))
		stored_extinguisher = null
		update_appearance(UPDATE_ICON)
		return

/obj/structure/extinguisher_cabinet/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/extinguisher_cabinet/atom_break(damage_flag)
	. = ..()
	if(!broken)
		broken = 1
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null
		update_appearance(UPDATE_ICON)

/obj/structure/extinguisher_cabinet/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/wallframe/extinguisher_cabinet(loc)
	else
		new /obj/item/stack/sheet/iron (loc, 2)
	if(stored_extinguisher)
		stored_extinguisher.forceMove(loc)
		stored_extinguisher = null

/obj/structure/extinguisher_cabinet/update_overlays()
	. = ..()
	if(stored_extinguisher)
		. += stored_extinguisher.cabinet_icon_state

/obj/item/wallframe/extinguisher_cabinet
	name = "extinguisher rack frame"
	desc = "Used for building wall-mounted extinguisher cabinets."
	icon = 'icons/obj/structures/cabinet.dmi'
	icon_state = "rack"
	result_path = /obj/structure/extinguisher_cabinet
