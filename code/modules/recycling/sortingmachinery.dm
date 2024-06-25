/obj/item/delivery
	icon = 'icons/obj/storage/wrapping.dmi'
	inhand_icon_state = "deliverypackage"
	var/giftwrapped = 0
	var/sort_tag = 0
	var/obj/item/paper/note
	var/obj/item/barcode/sticker

/obj/item/delivery/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))

/**
 * Initial check if manually unwrapping
 */
/obj/item/delivery/proc/attempt_pre_unwrap_contents(mob/user, time = 1.5 SECONDS)
	to_chat(user, span_notice("You start to unwrap the package..."))
	return do_after(user, time, target = user)

/**
 * Signals for unwrapping.
 */
/obj/item/delivery/proc/unwrap_contents()
	if(!sticker)
		return
	for(var/atom/movable/movable_content as anything in contents)
		SEND_SIGNAL(movable_content, COMSIG_ITEM_UNWRAPPED)

/**
 * Effects after completing unwrapping
 */
/obj/item/delivery/proc/post_unwrap_contents(mob/user, rip_open = TRUE)
	var/turf/turf_loc = get_turf(user || src)
	if(rip_open)
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		new /obj/effect/decal/cleanable/wrapping(turf_loc)
	else
		playsound(loc, 'sound/items/box_cut.ogg', 50, TRUE)
		new /obj/item/stack/package_wrap(turf_loc, 1)
	for(var/atom/movable/movable_content as anything in contents)
		movable_content.forceMove(turf_loc)

	qdel(src)

/obj/item/delivery/contents_explosion(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents

/obj/item/delivery/atom_deconstruct(dissambled = TRUE)
	unwrap_contents()
	post_unwrap_contents()

/obj/item/delivery/examine(mob/user)
	. = ..()
	if(note)
		if(!in_range(user, src))
			. += span_info("There's a [EXAMINE_HINT(note.name)] attached to it. You can't read it from here.")
		else
			. += span_info("There's a [EXAMINE_HINT(note.name)] attached to it...")
			. += note.examine(user)
	if(sticker)
		. += span_notice("There's a [EXAMINE_HINT("barcode")] attached to the side. The package is marked for [EXAMINE_HINT("export.")]")
	if(sort_tag)
		. += span_notice("There's a [EXAMINE_HINT("sorting tag")] with the destination set to [EXAMINE_HINT("[GLOB.TAGGERLOCATIONS[sort_tag]].")]")

/obj/item/delivery/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

/obj/item/delivery/relay_container_resist_act(mob/living/user, obj/object)
	if(ismovable(loc))
		var/atom/movable/movable_loc = loc //can't unwrap the wrapped container if it's inside something.
		movable_loc.relay_container_resist_act(user, object)
		return
	to_chat(user, span_notice("You lean on the back of [object] and start pushing to rip the wrapping around it."))
	if(do_after(user, 5 SECONDS, target = object))
		if(!user || user.stat != CONSCIOUS || user.loc != object || object.loc != src)
			return
		to_chat(user, span_notice("You successfully removed [object]'s wrapping!"))
		object.forceMove(loc)
		unwrap_contents()
		post_unwrap_contents(user)
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to remove [object]'s wrapping!"))

/obj/item/delivery/update_icon_state()
	. = ..()
	icon_state = giftwrapped ? "gift[base_icon_state]" : base_icon_state

/obj/item/delivery/update_overlays()
	. = ..()
	if(sort_tag)
		. += "[base_icon_state]_sort"
	if(note)
		. += "[base_icon_state]_note"
	if(sticker)
		. += "[base_icon_state]_barcode"

/obj/item/delivery/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/dest_tagger = item

		if(sort_tag != dest_tagger.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[dest_tagger.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sort_tag = dest_tagger.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, TRUE)
			update_appearance()
	else if(IS_WRITING_UTENSIL(item))
		if(!user.can_write(item))
			return
		var/str = tgui_input_text(user, "Label text?", "Set label", max_length = MAX_NAME_LEN)
		if(!user.can_perform_action(src))
			return
		if(!str || !length(str))
			to_chat(user, span_warning("Invalid text!"))
			return
		user.visible_message(span_notice("[user] labels [src] as [str]."))
		name = "[name] ([str])"

	else if(istype(item, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/wrapping_paper = item
		if(wrapping_paper.use(3))
			user.visible_message(span_notice("[user] wraps the package in festive paper!"))
			giftwrapped = TRUE
			greyscale_config = text2path("/datum/greyscale_config/gift[icon_state]")
			set_greyscale(colors = wrapping_paper.greyscale_colors)
			update_appearance()
		else
			to_chat(user, span_warning("You need more paper!"))

	else if(istype(item, /obj/item/paper))
		if(note)
			to_chat(user, span_warning("This package already has a note attached!"))
			return
		if(!user.transferItemToLoc(item, src))
			to_chat(user, span_warning("For some reason, you can't attach [item]!"))
			return
		user.visible_message(span_notice("[user] attaches [item] to [src]."), span_notice("You attach [item] to [src]."))
		note = item
		update_appearance()

	else if(istype(item, /obj/item/universal_scanner))
		var/obj/item/universal_scanner/sales_tagger = item
		if(sales_tagger.scanning_mode != SCAN_SALES_TAG)
			return
		if(sticker)
			to_chat(user, span_warning("This package already has a barcode attached!"))
			return
		if(!(sales_tagger.payments_acc))
			to_chat(user, span_warning("Swipe an ID on [sales_tagger] first!"))
			return
		if(sales_tagger.paper_count <= 0)
			to_chat(user, span_warning("[sales_tagger] is out of paper!"))
			return
		user.visible_message(span_notice("[user] attaches a barcode to [src]."), span_notice("You attach a barcode to [src]."))
		sales_tagger.paper_count -= 1
		sticker = new /obj/item/barcode(src)
		sticker.payments_acc = sales_tagger.payments_acc	//new tag gets the tagger's current account.
		sticker.cut_multiplier = sales_tagger.cut_multiplier	//same, but for the percentage taken.

		for(var/obj/wrapped_item in get_all_contents())
			if(HAS_TRAIT(wrapped_item, TRAIT_NO_BARCODES))
				continue
			wrapped_item.AddComponent(/datum/component/pricetag, sticker.payments_acc, sales_tagger.cut_multiplier)
		update_appearance()

	else if(istype(item, /obj/item/barcode))
		var/obj/item/barcode/stickerA = item
		if(sticker)
			to_chat(user, span_warning("This package already has a barcode attached!"))
			return
		if(!(stickerA.payments_acc))
			to_chat(user, span_warning("This barcode seems to be invalid. Guess it's trash now."))
			return
		if(!user.transferItemToLoc(item, src))
			to_chat(user, span_warning("For some reason, you can't attach [item]!"))
			return
		sticker = stickerA
		for(var/obj/wrapped_item in get_all_contents())
			if(HAS_TRAIT(wrapped_item, TRAIT_NO_BARCODES))
				continue
			wrapped_item.AddComponent(/datum/component/pricetag, sticker.payments_acc, sticker.cut_multiplier)
		update_appearance()

	else if(istype(item, /obj/item/boxcutter))
		var/obj/item/boxcutter/boxcutter_item = item
		if(HAS_TRAIT(boxcutter_item, TRAIT_TRANSFORM_ACTIVE))
			if(!attempt_pre_unwrap_contents(user, time = 0.5 SECONDS))
				return
			unwrap_contents()
			balloon_alert(user, "cutting open package...")
			post_unwrap_contents(user, rip_open = FALSE)
		else
			balloon_alert(user, "prime the boxcutter!")

	else
		return ..()

/**
 * # Wrapped up crates and lockers - too big to carry.
 */
/obj/item/delivery/big
	name = "large parcel"
	desc = "A large delivery parcel."
	icon_state = "deliverycloset"
	density = TRUE
	interaction_flags_item = 0 // Disable the ability to pick it up. Wow!
	layer = BELOW_OBJ_LAYER
	pass_flags_self = PASSSTRUCTURE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

/obj/item/delivery/big/interact(mob/user)
	if(!attempt_pre_unwrap_contents(user))
		return
	unwrap_contents()
	post_unwrap_contents()

/**
 * # Wrapped up items small enough to carry.
 */
/obj/item/delivery/small
	name = "parcel"
	desc = "A brown paper delivery parcel."
	icon_state = "deliverypackage3"

/obj/item/delivery/small/attack_self(mob/user)
	if(!attempt_pre_unwrap_contents(user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	unwrap_contents()
	for(var/atom/movable/movable_content as anything in contents)
		user.put_in_hands(movable_content)
	post_unwrap_contents(user)

/obj/item/delivery/small/attack_self_tk(mob/user)
	if(ismob(loc))
		var/mob/M = loc
		M.temporarilyRemoveItemFromInventory(src, TRUE)
		for(var/atom/movable/movable_content as anything in contents)
			M.put_in_hands(movable_content)
	else
		for(var/atom/movable/movable_content as anything in contents)
			movable_content.forceMove(loc)

	unwrap_contents()
	post_unwrap_contents(user)
	return ITEM_INTERACT_BLOCKING

/obj/item/dest_tagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "cargo tagger"
	worn_icon_state = "cargotagger"
	var/currTag = 0 //Destinations are stored in code\globalvars\lists\flavor_misc.dm
	var/locked_destination = FALSE //if true, users can't open the destination tag window to prevent changing the tagger's current destination
	w_class = WEIGHT_CLASS_TINY
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT

/obj/item/dest_tagger/borg
	name = "cyborg destination tagger"
	desc = "Used to fool the disposal mail network into thinking that you're a harmless parcel. Does actually work as a regular destination tagger as well."

/obj/item/dest_tagger/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins tagging [user.p_their()] final destination! It looks like [user.p_theyre()] trying to commit suicide!"))
	if (islizard(user))
		to_chat(user, span_notice("*HELL*"))//lizard nerf
	else
		to_chat(user, span_notice("*HEAVEN*"))
	playsound(src, 'sound/machines/twobeep_high.ogg', 100, TRUE)
	return BRUTELOSS

/** Standard TGUI actions */
/obj/item/dest_tagger/ui_interact(mob/user, datum/tgui/ui)
	add_fingerprint(user)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DestinationTagger", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/** If the user dropped the tagger */
/obj/item/dest_tagger/ui_state(mob/user)
	return GLOB.inventory_state

/** User activates in hand */
/obj/item/dest_tagger/attack_self(mob/user)
	if(!locked_destination)
		ui_interact(user)
		return

/** Data sent to TGUI window */
/obj/item/dest_tagger/ui_data(mob/user)
	var/list/data = list()
	data["locations"] = GLOB.TAGGERLOCATIONS
	data["currentTag"] = currTag
	return data

/** User clicks a button on the tagger */
/obj/item/dest_tagger/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("change")
			var/new_tag = round(text2num(params["index"]))
			if(new_tag == currTag || new_tag < 1 || new_tag > length(GLOB.TAGGERLOCATIONS))
				return
			currTag = new_tag
	return TRUE

/obj/item/sales_tagger
	name = "sales tagger"
	desc = "A scanner that lets you tag wrapped items for sale, splitting the profit between you and cargo."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "sales tagger"
	worn_icon_state = "salestagger"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	///The account which is receiving the split profits.
	var/datum/bank_account/payments_acc = null
	var/paper_count = 10
	var/max_paper_count = 20
	///The person who tagged this will receive the sale value multiplied by this number.
	var/cut_multiplier = 0.5
	///Maximum value for cut_multiplier.
	var/cut_max = 0.5
	///Minimum value for cut_multiplier.
	var/cut_min = 0.01

/obj/item/sales_tagger/examine(mob/user)
	. = ..()
	. += span_notice("[src] has [paper_count]/[max_paper_count] available barcodes. Refill with paper.")
	. += span_notice("Profit split on sale is currently set to [round(cut_multiplier*100)]%. <b>Alt-click</b> to change.")
	if(payments_acc)
		. += span_notice("<b>Ctrl-click</b> to clear the registered account.")

/obj/item/sales_tagger/attackby(obj/item/item, mob/living/user, params)
	. = ..()
	if(isidcard(item))
		var/obj/item/card/id/potential_acc = item
		if(potential_acc.registered_account)
			if(payments_acc == potential_acc.registered_account)
				to_chat(user, span_notice("ID card already registered."))
				return
			else
				payments_acc = potential_acc.registered_account
				playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
				to_chat(user, span_notice("[src] registers the ID card. Tag a wrapped item to create a barcode."))
		else if(!potential_acc.registered_account)
			to_chat(user, span_warning("This ID card has no account registered!"))
			return
	if(istype(item, /obj/item/paper))
		if (!(paper_count >= max_paper_count))
			paper_count += 10
			qdel(item)
			if (paper_count >= max_paper_count)
				paper_count = max_paper_count
				to_chat(user, span_notice("[src]'s paper supply is now full."))
				return
			to_chat(user, span_notice("You refill [src]'s paper supply, you have [paper_count] left."))
			return
		else
			to_chat(user, span_notice("[src]'s paper supply is full."))
			return

/obj/item/sales_tagger/attack_self(mob/user)
	. = ..()
	if(paper_count <= 0)
		to_chat(user, span_warning("You're out of paper!'."))
		return
	if(!payments_acc)
		to_chat(user, span_warning("You need to swipe [src] with an ID card first."))
		return
	paper_count -= 1
	playsound(src, 'sound/machines/click.ogg', 40, TRUE)
	to_chat(user, span_notice("You print a new barcode."))
	var/obj/item/barcode/new_barcode = new /obj/item/barcode(src)
	new_barcode.payments_acc = payments_acc		// The sticker gets the scanner's registered account.
	new_barcode.cut_multiplier = cut_multiplier		// Also the registered percent cut.
	user.put_in_hands(new_barcode)

/obj/item/sales_tagger/item_ctrl_click(mob/user)
	payments_acc = null
	to_chat(user, span_notice("You clear the registered account."))
	return CLICK_ACTION_SUCCESS

/obj/item/sales_tagger/click_alt(mob/user)
	var/potential_cut = input("How much would you like to pay out to the registered card?","Percentage Profit ([round(cut_min*100)]% - [round(cut_max*100)]%)") as num|null
	if(!potential_cut)
		cut_multiplier = initial(cut_multiplier)
	cut_multiplier = clamp(round(potential_cut/100, cut_min), cut_min, cut_max)
	to_chat(user, span_notice("[round(cut_multiplier*100)]% profit will be received if a package with a barcode is sold."))
	return CLICK_ACTION_SUCCESS
