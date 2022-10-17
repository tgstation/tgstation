#define CART_HAS_MINIMUM_REAGENT_VOLUME !(reagents.total_volume < 1)

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag
	var/obj/item/mop/mymop
	var/obj/item/pushbroom/mybroom
	var/obj/item/reagent_containers/spray/cleaner/myspray
	var/obj/item/lightreplacer/myreplacer
	var/list/obj/item/clothing/suit/caution/held_signs = list()
	var/max_signs = 4

/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)
	GLOB.janitor_devices += src
	register_context()

/obj/structure/janitorialcart/Destroy()
	GLOB.janitor_devices -= src
	QDEL_NULL(myreplacer)
	QDEL_NULL(myspray)
	QDEL_NULL(mybroom)
	QDEL_NULL(mymop)
	QDEL_NULL(mybag)
	QDEL_LIST(held_signs)
	return ..()

/obj/structure/janitorialcart/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /obj/item/storage/bag/trash))
		mybag = arrived
		update_appearance(UPDATE_ICON)
	else if(istype(arrived, /obj/item/mop))
		mymop = arrived
		update_appearance(UPDATE_ICON)
	else if(istype(arrived, /obj/item/pushbroom))
		mybroom = arrived
		update_appearance(UPDATE_ICON)
	else if(istype(arrived, /obj/item/reagent_containers/spray/cleaner))
		myspray = arrived
		update_appearance(UPDATE_ICON)
	else if(istype(arrived, /obj/item/lightreplacer))
		myreplacer = arrived
		update_appearance(UPDATE_ICON)
	else if(istype(arrived, /obj/item/clothing/suit/caution))
		held_signs += arrived
		update_appearance(UPDATE_ICON)
	return ..()

/obj/structure/janitorialcart/Exited(atom/movable/gone, direction)
	if(gone == mybag)
		mybag = null
		update_appearance(UPDATE_ICON)
	else if(gone == mymop)
		mymop = null
		update_appearance(UPDATE_ICON)
	else if(gone == mybroom)
		mybroom = null
		update_appearance(UPDATE_ICON)
	else if(gone == myspray)
		myspray = null
		update_appearance(UPDATE_ICON)
	else if(gone == myreplacer)
		myreplacer = null
		update_appearance(UPDATE_ICON)
	else if(gone in held_signs)
		held_signs -= null
		update_appearance(UPDATE_ICON)
	return ..()

/obj/structure/janitorialcart/examine(mob/user)
	. = ..()
	if(contents.len)
		. += span_notice("It is carrying:")
		for(var/thing in contents)
			if(thing in held_signs)
				continue //we'll do this after.
			. += "\t[icon2html(thing, user)] \a [thing]"
		if(held_signs.len)
			var/obj/item/clothing/suit/caution/sign_obj = held_signs[1]
			if(held_signs.len > 1)
				. += "\t[held_signs.len] [icon2html(sign_obj, user)] [sign_obj.name]\s"
			else
				. += "\t[icon2html(sign_obj, user)] \a [sign_obj]"
	if(mymop)
		. += span_notice("<b>Right-click</b> to quickly remove [mymop].")
	if(CART_HAS_MINIMUM_REAGENT_VOLUME)
		. += span_notice("<b>Right-click</b> with a mop to wet it.")
		. += span_info("<b>Crowbar</b> it to empty it onto [get_turf(src)].")
	if(mybag)
		. += span_notice("<b>Right-click</b> with an object to put it in [mybag].")

/obj/structure/janitorialcart/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(!held_item)
		if(!contents.len)
			return NONE
		if(mymop)
			context[SCREENTIP_CONTEXT_RMB] = "Remove [mymop]"
		if(contents.len == 1)
			context[SCREENTIP_CONTEXT_LMB] = "Remove [contents[1]]"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Search cart"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/mop))
		. = NONE
		if(!mymop)
			context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
			. = CONTEXTUAL_SCREENTIP_SET
		if(CART_HAS_MINIMUM_REAGENT_VOLUME && held_item.reagents.total_volume < held_item.reagents.maximum_volume)
			context[SCREENTIP_CONTEXT_RMB] = "Wet [held_item]"
			. = CONTEXTUAL_SCREENTIP_SET
		return
	if(istype(held_item, /obj/item/pushbroom))
		if(mybroom)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/storage/bag/trash))
		if(mybag)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/reagent_containers/spray/cleaner))
		if(myspray)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/clothing/suit/caution))
		if(held_signs.len >= max_signs)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/lightreplacer))
		if(myreplacer)
			return NONE
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		return CONTEXTUAL_SCREENTIP_SET
	if((held_item.is_refillable() && held_item.reagents.total_volume) && reagents.total_volume < reagents.maximum_volume)
		context[SCREENTIP_CONTEXT_RMB] = "Fill [src]'s mop bucket"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR && CART_HAS_MINIMUM_REAGENT_VOLUME)
		context[SCREENTIP_CONTEXT_LMB] = "Empty [src]'s mop bucket on [loc]"
		return CONTEXTUAL_SCREENTIP_SET
	if(mybag?.atom_storage?.max_specific_storage >= held_item.w_class)
		context[SCREENTIP_CONTEXT_RMB] = "Insert [held_item] into [mybag]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/structure/janitorialcart/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/mop))
		if(mymop)
			to_chat(user, span_warning("There is already a mop in [src]!"))
		else if(user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_notice("You put [attacking_item] into [src]."))
		return

	if(istype(attacking_item, /obj/item/pushbroom))
		if(mybroom)
			to_chat(user, span_warning("There is already a broom in [src]!"))
		else if(user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_notice("You put [attacking_item] into [src]."))
		return

	if(istype(attacking_item, /obj/item/storage/bag/trash))
		if(mybag)
			to_chat(user, span_warning("There is already a trash bag in [src]!"))
		else if(user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_notice("You put [attacking_item] into [src]."))
		return

	if(istype(attacking_item, /obj/item/reagent_containers/spray/cleaner))
		if(myspray)
			to_chat(user, span_warning("There is already a spray bottle in [src]!"))
		else if(user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_notice("You put [attacking_item] into [src]."))
		return

	if(istype(attacking_item, /obj/item/lightreplacer))
		if(myreplacer)
			to_chat(user, span_warning("There is already a light replacer in [src]!"))
		else if(user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_notice("You put [attacking_item] into [src]."))
		return

	else if(istype(attacking_item, /obj/item/clothing/suit/caution))
		if(held_signs.len >= max_signs)
			to_chat(user, span_warning("[src] can't hold any more signs!"))
		else if(user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_notice("You put [attacking_item] into [src]."))
		return

	if(attacking_item.is_drainable())
		return FALSE //so we can fill the cart via our afterattack without bludgeoning it

	return ..()

/obj/structure/janitorialcart/crowbar_act(mob/living/user, obj/item/tool)
	if(!CART_HAS_MINIMUM_REAGENT_VOLUME)
		to_chat(user, span_warning("[src]'s mop bucket is empty!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	user.visible_message(span_notice("[user] begins to empty the contents of [src]."), span_notice("You begin to empty the contents of [src]..."))
	if(tool.use_tool(src, user, 5 SECONDS, volume = 50))
		to_chat(user, span_notice("You empty the contents of [src]'s mop bucket onto the floor."))
		reagents.expose(loc)
		reagents.clear_reagents()
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/janitorialcart/attackby_secondary(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mop))
		var/obj/item/mop/your_mop = weapon
		if(your_mop.reagents.total_volume >= your_mop.reagents.maximum_volume)
			to_chat(user, span_warning("[your_mop] is already soaked!"))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(!CART_HAS_MINIMUM_REAGENT_VOLUME)
			to_chat(user, span_warning("[src]'s mop bucket is empty!"))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		reagents.trans_to(your_mop, your_mop.reagents.maximum_volume, transfered_by = user)
		to_chat(user, span_notice("You wet [your_mop] in [src]."))
		playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(weapon.is_refillable())
		return SECONDARY_ATTACK_CONTINUE_CHAIN //so we can empty the cart via our afterattack without trying to put the item in the bag

	if(mybag?.attackby(weapon, user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/structure/janitorialcart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/list/items = list()
	if(mybag)
		items += list("Trash bag" = image(icon = mybag.icon, icon_state = mybag.icon_state))
	if(mymop)
		items += list("Mop" = image(icon = mymop.icon, icon_state = mymop.icon_state))
	if(mybroom)
		items += list("Broom" = image(icon = mybroom.icon, icon_state = mybroom.icon_state))
	if(myspray)
		items += list("Spray bottle" = image(icon = myspray.icon, icon_state = myspray.icon_state))
	if(myreplacer)
		items += list("Light replacer" = image(icon = myreplacer.icon, icon_state = myreplacer.icon_state))
	if(held_signs.len)
		var/obj/item/clothing/suit/caution/sign = held_signs[1]
		items += list("Sign" = image(icon = sign.icon, icon_state = sign.icon_state))

	if(!length(items))
		return

	var/pick = items[1]
	if(length(items) > 1)
		items = sort_list(items)
		pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 38, require_near = TRUE)

	if(!pick)
		return
	switch(pick)
		if("Trash bag")
			if(!mybag)
				return
			to_chat(user, span_notice("You take [mybag] from [src]."))
			user.put_in_hands(mybag)
		if("Mop")
			if(!mymop)
				return
			to_chat(user, span_notice("You take [mymop] from [src]."))
			user.put_in_hands(mymop)
		if("Broom")
			if(!mybroom)
				return
			to_chat(user, span_notice("You take [mybroom] from [src]."))
			user.put_in_hands(mybroom)
		if("Spray bottle")
			if(!myspray)
				return
			to_chat(user, span_notice("You take [myspray] from [src]."))
			user.put_in_hands(myspray)
		if("Light replacer")
			if(!myreplacer)
				return
			to_chat(user, span_notice("You take [myreplacer] from [src]."))
			user.put_in_hands(myreplacer)
		if("Sign")
			if(!held_signs.len)
				return
			var/obj/item/clothing/suit/caution/removed_sign = held_signs[1]
			to_chat(user, span_notice("You take \a [removed_sign] from [src]."))
			user.put_in_hands(removed_sign)
		else
			return

/obj/structure/janitorialcart/attack_hand_secondary(mob/user, list/modifiers)
	if(!mymop)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	to_chat(user, span_notice("You remove [mymop] from [src]."))
	user.put_in_hands(mymop)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/structure/janitorialcart/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(mybag)
		if(istype(mybag, /obj/item/storage/bag/trash/bluespace))
			. += "cart_bluespace_garbage"
		else
			. += "cart_garbage"
	if(mymop)
		. += "cart_mop"
	if(mybroom)
		. += "cart_broom"
	if(myspray)
		. += "cart_spray"
	if(myreplacer)
		. += "cart_replacer"
	if(held_signs.len)
		. += "cart_sign[min(held_signs.len, 4)]"
	if(reagents.total_volume > 0)
		. += "cart_water"


#undef CART_HAS_MINIMUM_REAGENT_VOLUME
