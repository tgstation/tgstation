/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag
	var/obj/item/mop/mymop
	var/obj/item/pushbroom/mybroom
	var/obj/item/reagent_containers/spray/cleaner/myspray
	var/obj/item/lightreplacer/myreplacer
	var/signs = 0
	var/max_signs = 4


/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)
	GLOB.janitor_devices += src

/obj/structure/janitorialcart/Destroy()
	GLOB.janitor_devices -= src
	return ..()

/obj/structure/janitorialcart/examine(mob/user)
	. = ..()
	if(mymop)
		. += span_info("<b>Right-click</b> to quickly remove [mymop].")
	if(reagents.total_volume > 1)
		. += span_info("<b>Right-click</b> with a mop to wet it.")
		. += span_info("<b>Crowbar</b> it to empty it onto [get_turf(src)].")
	if(mybag)
		. += span_info("<b>Right-click</b> with an object to put it in [mybag].")

/obj/structure/janitorialcart/proc/wet_mop(obj/item/mop/your_mop, mob/user)
	if(your_mop.reagents.total_volume >= your_mop.reagents.maximum_volume)
		to_chat(user, span_warning("[your_mop] is already soaked!"))
		return FALSE
	if(reagents.total_volume < 1)
		to_chat(user, span_warning("[src]'s mop bucket is empty!"))
		return FALSE
	reagents.trans_to(your_mop, your_mop.reagents.maximum_volume, transfered_by = user)
	to_chat(user, span_notice("You wet [your_mop] in [src]."))
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	return TRUE

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	if(!user.transferItemToLoc(I, src))
		return FALSE
	to_chat(user, span_notice("You put [I] into [src]."))
	update_appearance()
	return TRUE


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop))
		if(mymop)
			to_chat(user, span_warning("There is already a mop in [src]!"))
			return
		mymop = I
		if(!put_in_cart(I, user))
			mymop = null
		return

	else if(istype(I, /obj/item/pushbroom))
		if(mybroom)
			to_chat(user, span_warning("There is already a broom in [src]!"))
			return
		mybroom = I
		if(!put_in_cart(I, user))
			mybroom = null
		return

	else if(istype(I, /obj/item/storage/bag/trash))
		if(mybag)
			to_chat(user, span_warning("There is already a trash bag in [src]!"))
			return
		mybag = I
		if(!put_in_cart(I, user))
			mybag = null
		return

	else if(istype(I, /obj/item/reagent_containers/spray/cleaner))
		if(myspray)
			to_chat(user, span_warning("There is already a spray bottle in [src]!"))
			return
		myspray = I
		if(!put_in_cart(I, user))
			myspray = null
		return

	else if(istype(I, /obj/item/lightreplacer))
		if(myreplacer)
			to_chat(user, span_warning("There is already a light replacer in [src]!"))
			return
		myreplacer = I
		if(!put_in_cart(I, user))
			myreplacer = null
		return

	else if(istype(I, /obj/item/clothing/suit/caution))
		if(signs >= max_signs)
			to_chat(user, span_warning("[src] can't hold any more signs!"))
			return
		signs++
		if(!put_in_cart(I, user))
			signs--
		return

	else if(I.tool_behaviour == TOOL_CROWBAR)
		if(reagents.total_volume < 1)
			to_chat(user, span_warning("[src]'s mop bucket is empty!"))
			return
		user.visible_message(span_notice("[user] begins to empty the contents of [src]."), span_notice("You begin to empty the contents of [src]..."))
		if(I.use_tool(src, user, 5 SECONDS))
			to_chat(usr, span_notice("You empty the contents of [src]'s mop bucket onto the floor."))
			reagents.expose(src.loc)
			src.reagents.clear_reagents()
			update_appearance()
		return

	if(I.is_drainable())
		return FALSE //so we can fill the cart via our afterattack without bludgeoning it

	return ..()

/obj/structure/janitorialcart/attackby_secondary(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/mop))
		var/obj/item/mop/your_mop = I
		wet_mop(your_mop, user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(I.is_refillable())
		return SECONDARY_ATTACK_CONTINUE_CHAIN //so we can empty the cart via our afterattack without trying to put the item in the bag

	if(mybag)
		if(mybag.attackby(I, user))
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
	var/obj/item/clothing/suit/caution/sign = locate() in src
	if(sign)
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
			user.put_in_hands(mybag)
			to_chat(user, span_notice("You take [mybag] from [src]."))
			mybag = null
		if("Mop")
			if(!mymop)
				return
			user.put_in_hands(mymop)
			to_chat(user, span_notice("You take [mymop] from [src]."))
			mymop = null
		if("Broom")
			if(!mybroom)
				return
			user.put_in_hands(mybroom)
			to_chat(user, span_notice("You take [mybroom] from [src]."))
			mybroom = null
		if("Spray bottle")
			if(!myspray)
				return
			user.put_in_hands(myspray)
			to_chat(user, span_notice("You take [myspray] from [src]."))
			myspray = null
		if("Light replacer")
			if(!myreplacer)
				return
			user.put_in_hands(myreplacer)
			to_chat(user, span_notice("You take [myreplacer] from [src]."))
			myreplacer = null
		if("Sign")
			if(signs <= 0)
				return
			user.put_in_hands(sign)
			to_chat(user, span_notice("You take \a [sign] from [src]."))
			signs--
		else
			return

	update_appearance()

/obj/structure/janitorialcart/attack_hand_secondary(mob/user, list/modifiers)
	if(!mymop)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	user.put_in_hands(mymop)
	to_chat(user, span_notice("You take [mymop] from [src]."))
	mymop = null
	update_appearance()
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
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		. += "cart_water"
