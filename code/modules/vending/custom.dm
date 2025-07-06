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
	VAR_PROTECTED/max_loaded_items = 20
	/// where the money is sent
	VAR_PRIVATE/datum/bank_account/linked_account
	/// Base64 cache of custom icons.
	VAR_PRIVATE/static/list/base64_cache = list()
	///Items that the players have loaded into the vendor
	VAR_FINAL/list/vending_machine_input = list()

/obj/machinery/vending/custom/add_context(atom/source, list/context, obj/item/held_item, mob/user)

	if(!isnull(held_item))
		if(held_item.tool_behaviour == TOOL_CROWBAR) //cannot deconstruct
			return NONE

		if(vending_machine_input[held_item.type] || canLoadItem(held_item, user, send_message = FALSE))
			context[SCREENTIP_CONTEXT_LMB] = "Load item"
			return CONTEXTUAL_SCREENTIP_SET

	return ..()

/obj/machinery/vending/custom/examine(mob/user)
	. = ..()
	if(panel_open) //you cant
		. -= span_notice("The machine may be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/vending/custom/Exited(obj/item/gone, direction)
	. = ..()
	if(istype(gone))
		var/hash_key = ITEM_HASH(gone)
		if(vending_machine_input[hash_key])
			var/new_amount = vending_machine_input[hash_key] - 1
			if(!new_amount)
				vending_machine_input -= hash_key
				update_static_data_for_all_viewers()
			else
				vending_machine_input[hash_key] = new_amount

/obj/machinery/vending/custom/canLoadItem(obj/item/loaded_item, mob/user, send_message = TRUE)
	. = TRUE
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

/obj/machinery/vending/custom/loadingAttempt(obj/item/inserted_item, mob/user)
	. = TRUE
	if(!canLoadItem(inserted_item, user))
		return FALSE

	var/loaded_items = 0
	for(var/input in vending_machine_input)
		loaded_items += vending_machine_input[input]
	if(loaded_items == max_loaded_items)
		speak("There are too many items in stock.")
		return FALSE

	if(!user.transferItemToLoc(inserted_item, src))
		to_chat(user, span_warning("[inserted_item] is stuck in your hand!"))
		return FALSE

	//the hash key decides how items stack in the UI. We diffrentiate them based on name & price
	var/hash_key = ITEM_HASH(inserted_item)
	if(vending_machine_input[hash_key])
		vending_machine_input[hash_key]++
	else
		vending_machine_input[hash_key] = 1
		update_static_data_for_all_viewers()

/obj/machinery/vending/custom/ui_interact(mob/user, datum/tgui/ui)
	if(!linked_account)
		balloon_alert(user, "no registered owner!")
		return FALSE
	return ..()

/obj/machinery/vending/custom/collect_records_for_static_data(list/records, list/categories, premium)
	. = list()
	if(records != product_records) //no coin or hidden stuff only product records
		return

	categories["Products"] = list("icon" = "cart-shopping")
	for(var/stocked_hash in vending_machine_input)
		var/base64 = ""
		var/obj/item/target = null
		for(var/obj/item/stored_item in contents)
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
			ref = REF(target),
			colorable = FALSE,
			image = base64
		))

/obj/machinery/vending/custom/ui_data(mob/user)
	. = ..()

	var/is_owner = compartmentLoadAccessCheck(user)

	.["stock"] = list()
	for(var/stocked_hash in vending_machine_input)
		.["stock"][stocked_hash] = list(
			amount = vending_machine_input[stocked_hash],
			free = is_owner
		)

/obj/machinery/vending/custom/compartmentLoadAccessCheck(mob/user)
	. = FALSE
	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	var/obj/item/card/id/id_card = living_user.get_idcard(FALSE)
	if(id_card?.registered_account && id_card.registered_account == linked_account)
		return TRUE

/obj/machinery/vending/custom/item_interaction(mob/living/user, obj/item/attack_item, list/modifiers)
	if(!linked_account && isliving(user))
		var/mob/living/living_user = user
		var/obj/item/card/id/card_used = living_user.get_idcard(TRUE)
		if(card_used?.registered_account)
			linked_account = card_used.registered_account
			speak("\The [src] has been linked to [card_used].")
			return ITEM_INTERACT_SUCCESS

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
	balloon_alert(user, "cannot deconstruct!")
	return ITEM_INTERACT_FAILURE

/obj/machinery/vending/custom/on_deconstruction(disassembled)
	unbuckle_all_mobs(TRUE)
	var/turf/current_turf = get_turf(src)
	if(current_turf)
		for(var/obj/item/stored_item in contents)
			stored_item.forceMove(current_turf)
		explosion(src, devastation_range = -1, light_impact_range = 3)

/obj/machinery/vending/custom/vend(list/params, mob/living/user, list/greyscale_colors)
	. = FALSE
	if(!isliving(user))
		return
	var/obj/item/dispensed_item = locate(params["ref"])
	if(!dispensed_item)
		return

	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	if(!id_card || !id_card.registered_account || !id_card.registered_account.account_job)
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
		if(last_shopper != REF(user) || purchase_message_cooldown < world.time)
			speak("Thank you for your patronage [user]!")
			purchase_message_cooldown = world.time + 5 SECONDS
			last_shopper = REF(user)

	/// Remove the item
	use_energy(active_power_usage)
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

#undef ITEM_HASH
