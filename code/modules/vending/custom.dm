///This unique key decides how items are stacked on the UI. We separate them based on name,price & type
#define ITEM_HASH(item)("[item.name][item.custom_price][item.type]")

/obj/machinery/vending/custom
	name = "Custom Vendor"
	icon_state = "custom"
	icon_deny = "custom-deny"
	max_integrity = 400
	payment_department = NO_FREEBIES
	light_mask = "custom-light-mask"
	panel_type = "panel20"
	refill_canister = /obj/item/vending_refill/custom
	fish_source_path = /datum/fish_source/vending/custom

	/// max number of items that the custom vendor can hold
	var/max_loaded_items = 20
	/// where the money is sent
	VAR_PRIVATE/datum/bank_account/linked_account
	/// Base64 cache of custom icons.
	VAR_PRIVATE/static/list/base64_cache = list()

/obj/machinery/vending/custom/on_deconstruction(disassembled)
	var/obj/item/vending_refill/custom/installed_refill = locate() in component_parts

	if(linked_account)
		//we delete the canister so players don't resell our products as their own
		component_parts -= installed_refill
		qdel(installed_refill)

		//self destruct protocol for unauthorized destruction
		explosion(get_turf(src), devastation_range = -1, light_impact_range = 3)

		return

	//copy product hash keys
	installed_refill.products.Cut()
	installed_refill.products += products

	//move products to canister
	for(var/obj/item/stored_item in contents - component_parts)
		stored_item.forceMove(installed_refill)

/obj/machinery/vending/custom/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(panel_open && istype(held_item, refill_canister))
		context[SCREENTIP_CONTEXT_LMB] = "Restock vending machine"
		return CONTEXTUAL_SCREENTIP_SET

	if(isliving(user) && istype(held_item, /obj/item/card/id))
		var/obj/item/card/id/card_used = held_item
		if(card_used?.registered_account)
			if(!linked_account)
				context[SCREENTIP_CONTEXT_LMB] = "Link account"
				return ITEM_INTERACT_SUCCESS
			else if(linked_account == card_used.registered_account)
				context[SCREENTIP_CONTEXT_LMB] = "Unlink account"
				return ITEM_INTERACT_SUCCESS

	return ..()

/obj/machinery/vending/custom/examine(mob/user)
	. = ..()
	if(linked_account)
		. += span_warning("Machine is ID locked. Be sure to unlink before deconstructing the machine.")

/obj/machinery/vending/custom/Exited(obj/item/gone, direction)
	. = ..()

	var/hash_key = ITEM_HASH(gone)
	if(products[hash_key])
		var/new_amount = products[hash_key] - 1
		if(!new_amount)
			products -= hash_key
			update_static_data_for_all_viewers()
		else
			products[hash_key] = new_amount

///Returns the number of products loaded in this machine
/obj/machinery/vending/custom/proc/loaded_items()
	PRIVATE_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)

	. = 0
	for(var/product_hash in products)
		. += products[product_hash]

/obj/machinery/vending/custom/canLoadItem(obj/item/loaded_item, mob/user, send_message = TRUE)
	if(loaded_item.flags_1 & HOLOGRAM_1)
		if(send_message)
			speak("This vendor cannot accept nonexistent items.")
		return FALSE
	if(isstack(loaded_item))
		if(send_message)
			speak("Loose items may cause problems, try to use it inside wrapping paper.")
		return FALSE
	if(!loaded_item.custom_price)
		if(send_message)
			speak("Item needs to have a custom price set.")
		return FALSE
	return TRUE

/obj/machinery/vending/custom/loadingAttempt(obj/item/inserted_item, mob/user)
	if(!canLoadItem(inserted_item, user))
		return FALSE

	if(loaded_items() == max_loaded_items)
		speak("There are too many items in stock.")
		return FALSE

	if(!user.transferItemToLoc(inserted_item, src))
		to_chat(user, span_warning("[inserted_item] is stuck in your hand!"))
		return FALSE

	//the hash key decides how items stack in the UI. We diffrentiate them based on name & price
	var/hash_key = ITEM_HASH(inserted_item)
	if(products[hash_key])
		products[hash_key]++
	else
		products[hash_key] = 1
		update_static_data_for_all_viewers()
	return TRUE

/obj/machinery/vending/custom/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)

	restock(locate(refill_canister) in component_parts)

/obj/machinery/vending/custom/restock(obj/item/vending_refill/canister)
	. = 0
	if(!canister.products?.len)
		if(!canister.products)
			canister.products = list()
		return

	var/update_static_data = FALSE
	var/available_load = max_loaded_items - loaded_items()
	for(var/product_hash in canister.products)
		//get available space
		var/load_count = min(canister.products[product_hash], available_load)
		if(!load_count)
			break
		//update canister record
		canister.products[product_hash] -= load_count
		if(!canister.products[product_hash])
			canister.products -= product_hash
		//update vendor record
		products[product_hash] += load_count
		//reduce from available space
		available_load -= load_count

		//update product
		for(var/obj/item/product in canister)
			if(!load_count)
				break
			if(ITEM_HASH(product) == product_hash)
				. += 1
				product.forceMove(src)
				load_count--

	if(update_static_data)
		update_static_data_for_all_viewers()


/obj/machinery/vending/custom/post_restock(mob/living/user, restocked)
	if(!restocked)
		to_chat(user, span_warning("There's nothing to restock!"))
		return

	to_chat(user, span_notice("You loaded [restocked] items in [src]"))

/obj/machinery/vending/custom/crowbar_act(mob/living/user, obj/item/attack_item)
	if(linked_account)
		visible_message(
			span_warning("Security warning"),
			span_warning("Unauthorized deconstruction of vending machine is prohibited. Please read the warning alert")
		)
		if(tgui_alert(user, "Vending machine is ID locked.\
		Deconstruction will result in an catrostrophic self destruct.\
		If you are the owner of this machine please unlink your account with an ID swipe before proceeding.\
		Still proceed?",
		"Vandalism protection protocol",
		list("Yes", "No")) == "No")
			return ITEM_INTERACT_FAILURE

	return ..()

/obj/machinery/vending/custom/compartmentLoadAccessCheck(mob/user)
	. = FALSE
	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	var/obj/item/card/id/id_card = living_user.get_idcard(FALSE)
	if(id_card?.registered_account && id_card.registered_account == linked_account)
		return TRUE

/obj/machinery/vending/custom/item_interaction(mob/living/user, obj/item/attack_item, list/modifiers)
	if(isliving(user) && istype(attack_item, /obj/item/card/id))
		var/obj/item/card/id/card_used = attack_item
		if(card_used?.registered_account)
			if(!linked_account)
				linked_account = card_used.registered_account
				speak("\The [src] has been linked to [card_used].")
			else if(linked_account == card_used.registered_account)
				linked_account = null
				speak("account unlinked.")
			else
				to_chat(user, "verification failed. unlinking process has been cancelled.")
			return ITEM_INTERACT_SUCCESS

	if(!compartmentLoadAccessCheck(user) || !IS_WRITING_UTENSIL(attack_item))
		return ..()

	. ITEM_INTERACT_FAILURE
	var/new_name = reject_bad_name(tgui_input_text(user, "Set name", "Name", name, max_length = 20), allow_numbers = TRUE, strict = TRUE, cap_after_symbols = FALSE)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if (new_name)
		name = new_name
	var/new_desc = reject_bad_text(tgui_input_text(user, "Set description", "Description", desc, max_length = 60))
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if (new_desc)
		desc = new_desc
	var/new_slogan = reject_bad_text(tgui_input_text(user, "Set slogan", "Slogan", "Epic", max_length = 60))
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if (new_slogan)
		slogan_list += new_slogan
		last_slogan = world.time + rand(0, slogan_delay)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/vending/custom/collect_records_for_static_data(list/records, list/categories, premium)
	. = list()
	if(records != product_records) //no coin or hidden stuff only product records
		return

	categories["Products"] = list("icon" = "cart-shopping")
	for(var/stocked_hash in products)
		var/base64 = ""
		var/obj/item/target = null
		for(var/obj/item/stored_item in contents - component_parts)
			if(ITEM_HASH(stored_item) == stocked_hash)
				base64 = base64_cache[stocked_hash]
				if(!base64) //generate an icon of the item to use in UI
					base64 = icon2base64(getFlatIcon(stored_item, no_anim = TRUE))
					base64_cache[stocked_hash] = base64
				target = stored_item
				break

		. += list(list(
			path = stocked_hash,
			name = target.name,
			price = target.custom_price,
			category = "Products",
			ref = stocked_hash,
			colorable = FALSE,
			image = base64
		))


/obj/machinery/vending/custom/ui_interact(mob/user, datum/tgui/ui)
	if(!linked_account)
		balloon_alert(user, "no registered owner!")
		return FALSE
	return ..()

/obj/machinery/vending/custom/ui_data(mob/user)
	. = ..()

	var/is_owner = compartmentLoadAccessCheck(user)

	.["stock"] = list()
	for(var/stocked_hash in products)
		.["stock"][stocked_hash] = list(
			amount = products[stocked_hash],
			free = is_owner
		)

/obj/machinery/vending/custom/vend(list/params, mob/living/user, list/greyscale_colors)
	. = FALSE
	if(!isliving(user))
		return
	var/obj/item/dispensed_item = params["ref"]
	for(var/obj/item/product in contents - component_parts)
		if(ITEM_HASH(product) == dispensed_item)
			dispensed_item = product
			break
	if(QDELETED(dispensed_item))
		return

	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	if(QDELETED(id_card))
		balloon_alert(user, "no card found!")
		flick(icon_deny, src)
		return

	/// Charges the user if its not the owner
	var/datum/bank_account/payee = id_card.registered_account
	if(!compartmentLoadAccessCheck(user))
		if(!payee.has_money(dispensed_item.custom_price))
			balloon_alert(user, "insufficient funds!")
			return
		/// Make the transaction
		payee.adjust_money(-dispensed_item.custom_price, , "Vending: [dispensed_item]")
		linked_account.adjust_money(dispensed_item.custom_price, "Vending: [dispensed_item] Bought")
		linked_account.bank_card_talk("[payee.account_holder] made a [dispensed_item.custom_price] \
		cr purchase at your custom vendor.")
		/// Log the transaction
		SSblackbox.record_feedback("amount", "vending_spent", dispensed_item.custom_price)
		log_econ("[dispensed_item.custom_price] credits were spent on [src] buying a \
		[dispensed_item] by [payee.account_holder], owned by [linked_account.account_holder].")
		/// Make an alert
		var/ref = REF(user)
		if(last_shopper != ref || purchase_message_cooldown < world.time)
			speak("Thank you for your patronage [user]!")
			purchase_message_cooldown = world.time + 5 SECONDS
			last_shopper = ref

	/// Remove the item
	use_energy(active_power_usage)
	try_put_in_hand(dispensed_item, user)
	return TRUE

/obj/item/vending_refill/custom
	machine_name = "Custom Vendor"
	icon_state = "refill_custom"
	custom_premium_price = PAYCHECK_CREW

/obj/item/vending_refill/custom/get_part_rating()
	. = 0
	for(var/key in products)
		. += products[key]

/obj/machinery/vending/custom/unbreakable
	name = "Indestructible Vendor"
	resistance_flags = INDESTRUCTIBLE
	allow_custom = FALSE

/obj/machinery/vending/custom/greed //name and like decided by the spawn
	icon_state = "greed"
	icon_deny = "greed-deny"
	panel_type = "panel4"
	max_integrity = 700
	max_loaded_items = 40
	light_mask = "greed-light-mask"
	allow_custom = FALSE
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5)

/obj/machinery/vending/custom/greed/Initialize(mapload)
	. = ..()
	//starts in a state where you can move it
	set_anchored(FALSE)
	set_panel_open(TRUE)
	//and references the deity
	name = "[GLOB.deity]'s Consecrated Vendor"
	desc = "A vending machine created by [GLOB.deity]."
	slogan_list = list("[GLOB.deity] says: It's your divine right to buy!")
	add_filter("vending_outline", 9, list("type" = "outline", "color" = COLOR_VERY_SOFT_YELLOW))
	add_filter("vending_rays", 10, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))

#undef ITEM_HASH
