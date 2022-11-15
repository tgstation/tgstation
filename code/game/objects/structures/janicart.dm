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

	register_context() //Context sensitive tooltips. See add_context()

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
	else if(istype(arrived, /obj/item/mop))
		mymop = arrived
	else if(istype(arrived, /obj/item/pushbroom))
		mybroom = arrived
	else if(istype(arrived, /obj/item/reagent_containers/spray/cleaner))
		myspray = arrived
	else if(istype(arrived, /obj/item/lightreplacer))
		myreplacer = arrived
	else if(istype(arrived, /obj/item/clothing/suit/caution))
		held_signs += arrived
	update_appearance(UPDATE_ICON)
	return ..()

/obj/structure/janitorialcart/Exited(atom/movable/gone, direction)
	if(gone == mybag)
		mybag = null
	else if(gone == mymop)
		mymop = null
	else if(gone == mybroom)
		mybroom = null
	else if(gone == myspray)
		myspray = null
	else if(gone == myreplacer)
		myreplacer = null
	else if(gone in held_signs)
		held_signs -= gone
	if(!QDELING(src))
		update_appearance(UPDATE_ICON)
	return ..()

/obj/structure/janitorialcart/examine(mob/user)
	. = ..()
	if(contents.len)
		. += span_bold(span_info("\nIt is carrying:"))
		for(var/thing in sort_names(contents))
			if(thing in held_signs)
				continue //we'll do this after.
			. += "\t[icon2html(thing, user)] \a [thing]"
		if(held_signs.len)
			var/obj/item/clothing/suit/caution/sign_obj = held_signs[1]
			if(held_signs.len > 1)
				. += "\t[icon2html(sign_obj, user)] [convert_integer_to_words(length(held_signs))] [sign_obj.name]\s"
			else
				. += "\t[icon2html(sign_obj, user)] \a [sign_obj]"
		. += span_notice("\n<b>Left-click</b> to [contents.len > 1 ? "search [src]" : "remove [contents[1]]"].")
		if(mybag)
			. += span_notice("<b>Right-click</b> with a <b>[weight_class_to_text(mybag.atom_storage.max_specific_storage)] item</b> to put it in [mybag].")
		if(mymop)
			. += span_notice("<b>Right-click</b> to quickly remove [mymop].")
	if(CART_HAS_MINIMUM_REAGENT_VOLUME)
		. += span_notice("<b>Right-click</b> with a <b>mop</b> to wet it.")
		. += span_info("<b>Crowbar</b> it to dump its mop bucket onto [get_turf(src)].")

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
		context[SCREENTIP_CONTEXT_LMB] = "Dump [src]'s mop bucket on [get_turf(src)]"
		return CONTEXTUAL_SCREENTIP_SET
	if(mybag?.atom_storage?.max_specific_storage >= held_item.w_class)
		context[SCREENTIP_CONTEXT_RMB] = "Insert [held_item] into [mybag]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/structure/janitorialcart/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/mop))
		if(mymop)
			balloon_alert(user, "already has \a [mymop]!")
		else if(user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "placed [attacking_item]")
		return

	if(istype(attacking_item, /obj/item/pushbroom))
		if(mybroom)
			balloon_alert(user, "already has \a [mybroom]!")
		else if(user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "placed [attacking_item]")
		return

	if(istype(attacking_item, /obj/item/storage/bag/trash))
		if(mybag)
			balloon_alert(user, "already has \a [mybag]!")
		else if(user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "attached [attacking_item]")
		return

	if(istype(attacking_item, /obj/item/reagent_containers/spray/cleaner))
		if(myspray)
			balloon_alert(user, "already has \a [myspray]!")
		else if(user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "placed [attacking_item]")
		return

	if(istype(attacking_item, /obj/item/lightreplacer))
		if(myreplacer)
			balloon_alert(user, "already has \a [myreplacer]!")
		else if(user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "placed [attacking_item]")
		return

	else if(istype(attacking_item, /obj/item/clothing/suit/caution))
		if(held_signs.len >= max_signs)
			balloon_alert(user, "sign rack is full!")
		else if(user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "placed [attacking_item]")
		return

	if(attacking_item.is_drainable())
		return FALSE //so we can fill the cart via our afterattack without bludgeoning it

	return ..()

/obj/structure/janitorialcart/crowbar_act(mob/living/user, obj/item/tool)
	if(!CART_HAS_MINIMUM_REAGENT_VOLUME)
		balloon_alert(user, "mop bucket is empty!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	user.balloon_alert_to_viewers("starts dumping [src]...", "started dumping [src]...")
	user.visible_message(span_notice("[user] begins to dumping the contents of [src]'s mop bucket."), span_notice("You begin to dump the contents of [src]'s mop bucket..."))
	if(tool.use_tool(src, user, 5 SECONDS, volume = 50))
		balloon_alert(user, "dumped [src]")
		to_chat(user, span_notice("You dumped the contents of [src]'s mop bucket onto the floor."))
		reagents.expose(loc)
		reagents.clear_reagents()
		update_appearance(UPDATE_ICON)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/janitorialcart/attackby_secondary(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mop))
		var/obj/item/mop/your_mop = weapon
		if(your_mop.reagents.total_volume >= your_mop.reagents.maximum_volume)
			balloon_alert(user, "[your_mop] is already soaked!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(!CART_HAS_MINIMUM_REAGENT_VOLUME)
			balloon_alert(user, "mop bucket is empty!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		reagents.trans_to(your_mop, your_mop.reagents.maximum_volume, transfered_by = user)
		balloon_alert(user, "wet [your_mop]")
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
		pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 38, require_near = TRUE)

	if(!pick)
		return
	switch(pick)
		if("Trash bag")
			if(!mybag)
				return
			balloon_alert(user, "detached [mybag]")
			user.put_in_hands(mybag)
		if("Mop")
			if(!mymop)
				return
			balloon_alert(user, "removed [mymop]")
			user.put_in_hands(mymop)
		if("Broom")
			if(!mybroom)
				return
			balloon_alert(user, "removed [mybroom]")
			user.put_in_hands(mybroom)
		if("Spray bottle")
			if(!myspray)
				return
			balloon_alert(user, "removed [myspray]")
			user.put_in_hands(myspray)
		if("Light replacer")
			if(!myreplacer)
				return
			balloon_alert(user, "removed [myreplacer]")
			user.put_in_hands(myreplacer)
		if("Sign")
			if(!held_signs.len)
				return
			var/obj/item/clothing/suit/caution/removed_sign = held_signs[1]
			if(length(held_signs) > 1)
				balloon_alert(user, "removed \a [removed_sign]")
			else
				balloon_alert(user, "removed [removed_sign]")
			user.put_in_hands(removed_sign)
		else
			return

/obj/structure/janitorialcart/attack_hand_secondary(mob/user, list/modifiers)
	if(!mymop)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	balloon_alert(user, "removed [mymop]")
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
