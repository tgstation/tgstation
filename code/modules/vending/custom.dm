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

	/// where the money is sent
	var/datum/bank_account/linked_account
	/// max number of items that the custom vendor can hold
	var/max_loaded_items = 20
	/// Base64 cache of custom icons.
	var/list/base64_cache = list()

/obj/machinery/vending/custom/compartmentLoadAccessCheck(mob/user)
	. = FALSE
	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	var/obj/item/card/id/id_card = living_user.get_idcard(FALSE)
	if(id_card?.registered_account && id_card.registered_account == linked_account)
		return TRUE

/obj/machinery/vending/custom/canLoadItem(obj/item/loaded_item, mob/user, send_message = TRUE)
	. = FALSE
	if(loaded_item.flags_1 & HOLOGRAM_1)
		if(send_message)
			speak("This vendor cannot accept nonexistent items.")
		return
	if(loaded_items >= max_loaded_items)
		if(send_message)
			speak("There are too many items in stock.")
		return
	if(isstack(loaded_item))
		if(send_message)
			speak("Loose items may cause problems, try to use it inside wrapping paper.")
		return
	if(loaded_item.custom_price)
		return TRUE

/obj/machinery/vending/custom/ui_interact(mob/user, datum/tgui/ui)
	if(!linked_account)
		balloon_alert(user, "no registered owner!")
		return FALSE
	return ..()

/obj/machinery/vending/custom/ui_data(mob/user)
	. = ..()
	.["access"] = compartmentLoadAccessCheck(user)
	.["vending_machine_input"] = list()
	for (var/obj/item/stocked_item as anything in vending_machine_input)
		if(vending_machine_input[stocked_item] > 0)
			var/base64
			var/price = 0
			var/itemname = initial(stocked_item.name)
			for(var/obj/item/stored_item in contents)
				if(stored_item.type == stocked_item)
					price = stored_item.custom_price
					itemname = stored_item.name
					if(!base64) //generate an icon of the item to use in UI
						if(base64_cache[stored_item.type])
							base64 = base64_cache[stored_item.type]
						else
							base64 = icon2base64(getFlatIcon(stored_item, no_anim=TRUE))
							base64_cache[stored_item.type] = base64
					break
			var/list/data = list(
				path = stocked_item,
				name = itemname,
				price = price,
				img = base64,
				amount = vending_machine_input[stocked_item],
				colorable = FALSE
			)
			.["vending_machine_input"] += list(data)

/obj/machinery/vending/custom/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("dispense")
			if(isliving(usr))
				vend_act(usr, params)
				vend_ready = TRUE
			return TRUE

/obj/machinery/vending/custom/item_interaction(mob/living/user, obj/item/attack_item, list/modifiers)
	if(!linked_account && isliving(user))
		var/mob/living/living_user = user
		var/obj/item/card/id/card_used = living_user.get_idcard(TRUE)
		if(card_used?.registered_account)
			linked_account = card_used.registered_account
			speak("\The [src] has been linked to [card_used].")

	if(!compartmentLoadAccessCheck(user) || !IS_WRITING_UTENSIL(attack_item))
		return ..()

	var/new_name = reject_bad_name(tgui_input_text(user, "Set name", "Name", name, max_length = 20), allow_numbers = TRUE, strict = TRUE, cap_after_symbols = FALSE)
	if (new_name)
		name = new_name
	var/new_desc = reject_bad_text(tgui_input_text(user, "Set description", "Description", desc, max_length = 60))
	if (new_desc)
		desc = new_desc
	var/new_slogan = reject_bad_text(tgui_input_text(user, "Set slogan", "Slogan", "Epic", max_length = 60))
	if (new_slogan)
		slogan_list += new_slogan
		last_slogan = world.time + rand(0, slogan_delay)

	return ITEM_INTERACT_SUCCESS

/obj/machinery/vending/custom/crowbar_act(mob/living/user, obj/item/attack_item)
	return FALSE

/obj/machinery/vending/custom/on_deconstruction(disassembled)
	unbuckle_all_mobs(TRUE)
	var/turf/current_turf = get_turf(src)
	if(current_turf)
		for(var/obj/item/stored_item in contents)
			stored_item.forceMove(current_turf)
		explosion(src, devastation_range = -1, light_impact_range = 3)

/**
 * Vends an item to the user. Handles all the logic:
 * Updating stock, account transactions, alerting users.
 * @return -- TRUE if a valid condition was met, FALSE otherwise.
 */
/obj/machinery/vending/custom/proc/vend_act(mob/living/user, list/params)
	if(!vend_ready)
		return
	var/obj/item/choice = text2path(params["item"]) // typepath is a string coming from javascript, we need to convert it back
	var/obj/item/dispensed_item
	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	vend_ready = FALSE
	if(!id_card || !id_card.registered_account || !id_card.registered_account.account_job)
		balloon_alert(usr, "no card found!")
		flick(icon_deny, src)
		return TRUE
	var/datum/bank_account/payee = id_card.registered_account
	for(var/obj/item/stock in contents)
		if(istype(stock, choice))
			dispensed_item = stock
			break
	if(!dispensed_item)
		return FALSE
	/// Charges the user if its not the owner
	if(!compartmentLoadAccessCheck(user))
		if(!payee.has_money(dispensed_item.custom_price))
			balloon_alert(user, "insufficient funds!")
			return TRUE
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
		if(last_shopper != REF(usr) || purchase_message_cooldown < world.time)
			speak("Thank you for your patronage [user]!")
			purchase_message_cooldown = world.time + 5 SECONDS
			last_shopper = REF(usr)
	/// Remove the item
	loaded_items--
	use_energy(active_power_usage)
	vending_machine_input[choice] = max(vending_machine_input[choice] - 1, 0)
	if(user.CanReach(src) && user.put_in_hands(dispensed_item))
		to_chat(user, span_notice("You take [dispensed_item.name] out of the slot."))
	else
		to_chat(user, span_warning("[capitalize(format_text(dispensed_item.name))] falls onto the floor!"))
	return TRUE

/obj/item/vending_refill/custom
	machine_name = "Custom Vendor"
	icon_state = "refill_custom"
	custom_premium_price = PAYCHECK_CREW

/obj/machinery/vending/custom/unbreakable
	name = "Indestructible Vendor"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/vending/custom/greed //name and like decided by the spawn
	icon_state = "greed"
	icon_deny = "greed-deny"
	panel_type = "panel4"
	max_integrity = 700
	max_loaded_items = 40
	light_mask = "greed-light-mask"
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5)

/obj/machinery/vending/custom/greed/Initialize(mapload)
	. = ..()
	//starts in a state where you can move it
	set_panel_open(TRUE)
	set_anchored(FALSE)
	add_overlay(panel_type)
	//and references the deity
	name = "[GLOB.deity]'s Consecrated Vendor"
	desc = "A vending machine created by [GLOB.deity]."
	slogan_list = list("[GLOB.deity] says: It's your divine right to buy!")
	add_filter("vending_outline", 9, list("type" = "outline", "color" = COLOR_VERY_SOFT_YELLOW))
	add_filter("vending_rays", 10, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))
