/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	integrity_failure = 0.25
	var/obj/item/extinguisher/stored_extinguisher
	var/opened = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/extinguisher_cabinet, 29)

/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		opened = TRUE
	else
		stored_extinguisher = new /obj/item/extinguisher(src)
	update_appearance(UPDATE_ICON)
	register_context()
	find_and_hang_on_wall()

/obj/structure/extinguisher_cabinet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = opened ? "Close" : "Open"
		if(stored_extinguisher)
			context[SCREENTIP_CONTEXT_LMB] = "Take extinguisher" //Yes, this shows whether or not it's open! Extinguishers are taken immediately on LMB click when closed
		return CONTEXTUAL_SCREENTIP_SET

	if(stored_extinguisher)
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Disassemble cabinet"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/extinguisher) && opened)
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
		user.balloon_alert(user, "deconstructing cabinet...")
		used_item.play_tool_sound(src)
		if(used_item.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			user.balloon_alert(user, "cabinet deconstructed")
			deconstruct(TRUE)
		return

	if(iscyborg(user) || isalien(user))
		return
	if(istype(used_item, /obj/item/extinguisher))
		if(!stored_extinguisher && opened)
			if(!user.transferItemToLoc(used_item, src))
				return
			stored_extinguisher = used_item
			user.balloon_alert(user, "extinguisher stored")
			update_appearance(UPDATE_ICON)
			return TRUE
		else
			toggle_cabinet(user)
	else if(!user.combat_mode)
		toggle_cabinet(user)
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
		if(!opened)
			opened = 1
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
			update_appearance(UPDATE_ICON)
	else
		toggle_cabinet(user)

/obj/structure/extinguisher_cabinet/attack_hand_secondary(mob/living/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING))
		return ..()
	toggle_cabinet(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	if(stored_extinguisher)
		stored_extinguisher.forceMove(loc)
		to_chat(user, span_notice("You telekinetically remove [stored_extinguisher] from [src]."))
		stored_extinguisher = null
		opened = TRUE
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		update_appearance(UPDATE_ICON)
		return
	toggle_cabinet(user)


/obj/structure/extinguisher_cabinet/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/extinguisher_cabinet/proc/toggle_cabinet(mob/user)
	if(opened && broken)
		user.balloon_alert(user, "it's broken!")
	else
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		opened = !opened
		update_appearance(UPDATE_ICON)

/obj/structure/extinguisher_cabinet/update_icon_state()
	icon_state = "extinguisher"

	if(isnull(stored_extinguisher))
		icon_state += ""
	else if(istype(stored_extinguisher, /obj/item/extinguisher/mini))
		icon_state += "_mini"
	else if(istype(stored_extinguisher, /obj/item/extinguisher/advanced))
		icon_state += "_advanced"
	else if(istype(stored_extinguisher, /obj/item/extinguisher/crafted))
		icon_state += "_crafted"
	else if(istype(stored_extinguisher, /obj/item/extinguisher))
		icon_state += "_default"

	return ..()

/obj/structure/extinguisher_cabinet/update_overlays()
	. = ..()
	. += mutable_appearance(icon, opened ? "door_open" : "door")

/obj/structure/extinguisher_cabinet/atom_break(damage_flag)
	. = ..()
	if(!broken)
		broken = 1
		opened = 1
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

/obj/item/wallframe/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "Used for building wall-mounted extinguisher cabinets."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher" //Reuses wallmount icon, but no door overlay
	result_path = /obj/structure/extinguisher_cabinet
	pixel_shift = 29
