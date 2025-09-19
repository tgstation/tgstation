//===============================HAND INTERACTION===================================
/obj/machinery/vending/interact(mob/user)
	if(seconds_electrified && !(machine_stat & NOPOWER))
		if(shock(user, 100))
			return

	if(tilted && !user.buckled)
		to_chat(user, span_notice("You begin righting [src]."))
		if(do_after(user, 5 SECONDS, target = src))
			untilt(user)
		return

	return ..()

//================================TOOL ACTS==============================================
/obj/machinery/vending/crowbar_act(mob/living/user, obj/item/attack_item)
	if(!component_parts)
		return ITEM_INTERACT_FAILURE
	default_deconstruction_crowbar(attack_item)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/vending/wrench_act(mob/living/user, obj/item/tool)
	. = NONE
	if(!panel_open)
		return ITEM_INTERACT_FAILURE
	if(default_unfasten_wrench(user, tool, time = 6 SECONDS))
		unbuckle_all_mobs(TRUE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/vending/screwdriver_act(mob/living/user, obj/item/attack_item)
	if(anchored)
		default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item)
		return ITEM_INTERACT_SUCCESS
	else
		to_chat(user, span_warning("You must first secure [src]."))
		return ITEM_INTERACT_FAILURE

/obj/machinery/vending/on_set_panel_open(old_value)
	update_appearance(UPDATE_OVERLAYS)

//=======================================RESTOCKING==========================================
/**
 * Is the passed in user allowed to load this vending machines compartments? This only is ran if we are using a /obj/item/storage/bag to load the vending machine, and not a dedicated restocker.
 *
 * Arguments:
 * * user - mob that is doing the loading of the vending machine
 */
/obj/machinery/vending/proc/compartmentLoadAccessCheck(mob/user)
	PROTECTED_PROC(TRUE)

	return !req_access || allowed(user) || (obj_flags & EMAGGED) || !scan_id

/**
 * Are we able to load the item passed in
 *
 * Arguments:
 * * loaded_item - the item being loaded
 * * user - the user doing the loading
 */
/obj/machinery/vending/proc/canLoadItem(obj/item/loaded_item, mob/user, send_message = TRUE)
	PROTECTED_PROC(TRUE)

	if(!length(loaded_item.contents) && (products[loaded_item.type] || premium[loaded_item.type] || contraband[loaded_item.type]))
		return TRUE
	if(send_message)
		to_chat(user, span_warning("[src] does not accept [loaded_item]!"))
	return FALSE


/**
 * Tries to insert the item into the vendor, and depending on whether the product is a part of the vendor's
 * stock or not, increments an already present product entry's available amount or creates a new entry.
 * arguments:
 * inserted_item - the item we're trying to insert
 * user - mob who's trying to insert the item
 */
/obj/machinery/vending/proc/loadingAttempt(obj/item/inserted_item, mob/user)
	PROTECTED_PROC(TRUE)

	. = TRUE
	if(!canLoadItem(inserted_item, user))
		to_chat(user, span_warning("[src] does not accept [inserted_item]!"))
		return FALSE

	to_chat(user, span_notice("You insert [inserted_item] into [src]'s input compartment."))
	for(var/datum/data/vending_product/product_datum in product_records + coin_records + hidden_records)
		if(inserted_item.type == product_datum.product_path)
			if(product_datum.amount == product_datum.max_amount)
				to_chat(user, span_warning("no space for any more [product_datum.category || "Products"]!"))
				return FALSE

			if(!user.transferItemToLoc(inserted_item, src))
				to_chat(user, span_warning("[inserted_item] is stuck in your hand!"))
				return FALSE

			product_datum.amount++
			LAZYADD(product_datum.returned_products, inserted_item)
			break

/obj/machinery/vending/item_interaction(mob/living/user, obj/item/attack_item, list/modifiers)
	. = NONE
	if(panel_open && is_wire_tool(attack_item))
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS

	if(refill_canister && istype(attack_item, refill_canister))
		. = ITEM_INTERACT_FAILURE
		if (!panel_open)
			to_chat(user, span_warning("You should probably unscrew the service panel first!"))
		else if (!is_operational)
			to_chat(user, span_warning("[src] does not respond."))
		else
			var/obj/item/vending_refill/canister = attack_item
			if(canister.get_part_rating() == 0)
				to_chat(user, span_warning("[canister] is empty!"))
			else
				post_restock(user, restock(canister))
				return ITEM_INTERACT_SUCCESS

	if(compartmentLoadAccessCheck(user) && !user.combat_mode)
		. = ITEM_INTERACT_FAILURE
		if (!is_operational)
			to_chat(user, span_warning("[src] does not respond."))
		else if(istype(attack_item, /obj/item/storage/bag)) //trays USUALLY
			var/obj/item/storage/storage_item = attack_item
			var/loaded = 0
			var/denied_items = 0
			for(var/obj/item/the_item in storage_item.contents)
				if(loadingAttempt(the_item, user))
					loaded++
				else
					denied_items++
			if(denied_items)
				to_chat(user, span_warning("[src] refuses some items!"))
			if(loaded)
				to_chat(user, span_notice("You insert [loaded] dishes into [src]'s compartment."))
				return ITEM_INTERACT_SUCCESS
		else
			return loadingAttempt(attack_item, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_FAILURE

/**
 * After-effects of refilling a vending machine from a refill canister
 *
 * This takes the amount of products restocked and gives the user our contained credits if needed,
 * sending the user a fitting message.
 *
 * Arguments:
 * * user - the user restocking us
 * * restocked - the amount of items we've been refilled with
 */
/obj/machinery/vending/proc/post_restock(mob/living/user, restocked)
	PROTECTED_PROC(TRUE)

	if(!restocked)
		to_chat(user, span_warning("There's nothing to restock!"))
		return

	to_chat(user, span_notice("You loaded [restocked] items in [src][credits_contained > 0 ? ", and are rewarded [credits_contained] credits." : "."]"))
	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_account.adjust_money(round(credits_contained * 0.5), "Vending: Restock")
	var/obj/item/holochip/payday = new(src, credits_contained)
	try_put_in_hand(payday, user)
	credits_contained = 0

/obj/machinery/vending/exchange_parts(mob/user, obj/item/storage/part_replacer/replacer)
	if(!istype(replacer) || !component_parts || !refill_canister)
		return FALSE

	var/works_from_distance = istype(replacer, /obj/item/storage/part_replacer/bluespace)

	if(!panel_open || works_from_distance)
		to_chat(user, display_parts(user))

	if(!panel_open && !works_from_distance)
		return FALSE

	var/restocked = 0
	for(var/replacer_item in replacer)
		if(istype(replacer_item, refill_canister))
			restocked += restock(replacer_item)
	post_restock(user, restocked)
	if(restocked > 0)
		replacer.play_rped_effect()
	return TRUE

//=======================================ATTACKS================================================
/**
 * Dispenses free items from the standard stock.
 *
 * Arguments:
 * freebies - number of free items to vend
 */
/obj/machinery/vending/proc/freebie(freebies)
	PRIVATE_PROC(TRUE)

	visible_message(span_notice("[src] yields [freebies > 1 ? "several free goodies" : "a free goody"][credits_contained > 0 ? " and some credits" : ""]!"))

	for(var/i in 1 to freebies)
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		for(var/datum/data/vending_product/record in shuffle(product_records))
			if(record.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			// Always give out new stuff that costs before free returned stuff, because of the risk getting gibbed involved
			var/only_returned_left = (record.amount <= LAZYLEN(record.returned_products))
			dispense(record, get_turf(src), silent = TRUE, dispense_returned = only_returned_left)
			break

	if(credits_contained > 0)
		var/credits_to_remove = min(CREDITS_DUMP_THRESHOLD, round(credits_contained))
		var/obj/item/holochip/holochip = new(loc, credits_to_remove)
		playsound(src, 'sound/effects/cashregister.ogg', 40, TRUE)
		credits_contained = max(0, credits_contained - credits_to_remove)
		SSblackbox.record_feedback("amount", "vending machine looted", holochip.credits)

/obj/machinery/vending/attacked_by(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!tiltable || tilted || . <= 0)
		return
	if(isclosedturf(get_turf(user))) //If the attacker is inside of a wall, immediately fall in the other direction, with no chance for goodies.
		tilt(get_turf(get_step(src, REVERSE_DIR(get_dir(src, user)))))
		return

	switch(rand(1, 100))
		if(1 to 5)
			freebie(3)
		if(6 to 15)
			freebie(2)
		if(16 to 25)
			freebie(1)
		if(26 to 75)
			pass()
		if(76 to 100)
			tilt(user)

/obj/machinery/vending/attack_tk_grab(mob/user)
	to_chat(user, span_warning("[src] seems to resist your mental grasp!"))

/obj/machinery/vending/attack_robot_secondary(mob/user, list/modifiers)
	. = ..()
	if (!Adjacent(user, src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
