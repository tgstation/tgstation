/**
 * This is the component that runs the armaments vendor.
 *
 * It's intended to be used with the armament vendor, or other atoms that otherwise aren't vending machines.
 */

/datum/component/armament
	/// The types of armament datums we wish to add to this component.
	var/list/products
	/// What access do we require to use this machine?
	var/list/required_access
	/// Our parent machine.
	var/atom/parent_atom
	/// The points card that is currently inserted into the parent.
	var/obj/item/armament_points_card/inserted_card
	/// Used to keep track of what categories have been used.
	var/list/used_categories = list()
	/// Used to keep track of what items have been purchased.
	var/list/purchased_items = list()

/datum/component/armament/Initialize(list/required_products, list/needed_access)
	if(!required_products)
		stack_trace("No products specified for armament")
		return COMPONENT_INCOMPATIBLE

	parent_atom = parent

	products = required_products

	required_access = needed_access

	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

/datum/component/armament/Destroy(force, silent)
	if(inserted_card)
		inserted_card.forceMove(parent_atom.drop_location())
		inserted_card = null
	return ..()

/datum/component/armament/proc/on_attackby(atom/target, obj/item, mob/user)
	SIGNAL_HANDLER

	if(!user || !item)
		return

	if(!user.can_interact_with(parent_atom))
		return

	if(!istype(item, /obj/item/armament_points_card) || inserted_card)
		return

	item.forceMove(parent_atom)
	inserted_card = item

/datum/component/armament/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(!user)
		return

	if(!user.can_interact_with(parent_atom))
		return

	if(!check_access(user))
		to_chat(user, span_warning("You don't have the required access!"))
		return

	INVOKE_ASYNC(src, .proc/ui_interact, user)

/datum/component/armament/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArmamentStation")
		ui.open()

/datum/component/armament/ui_data(mob/user)
	var/list/data = list()

	data["card_inserted"] = inserted_card ? TRUE : FALSE
	data["card_name"] = "unknown"
	data["card_points"] = 0
	if(inserted_card)
		data["card_points"] = inserted_card.points
		data["card_name"] = inserted_card.name

	data["armaments_list"] = list()
	for(var/armament_category as anything in GLOB.armament_entries)
		var/list/armament_subcategories = list()
		for(var/subcategory as anything in GLOB.armament_entries[armament_category][CATEGORY_ENTRY])
			var/list/subcategory_items = list()
			for(var/datum/armament_entry/armament_entry as anything in GLOB.armament_entries[armament_category][CATEGORY_ENTRY][subcategory])
				if(products && !(armament_entry.type in products))
					continue
				subcategory_items += list(list(
					"ref" = REF(armament_entry),
					"icon" = armament_entry.cached_base64,
					"name" = armament_entry.name,
					"cost" = armament_entry.cost,
					"buyable_ammo" = armament_entry.magazine ? TRUE : FALSE,
					"magazine_cost" = armament_entry.magazine_cost,
					"quantity" = armament_entry.max_purchase,
					"purchased" = purchased_items[armament_entry] ? purchased_items[armament_entry] : 0,
					"description" = armament_entry.description,
					"armament_category" = armament_entry.category,
					"equipment_subcategory" = armament_entry.subcategory,
				))
			if(!LAZYLEN(subcategory_items))
				continue
			armament_subcategories += list(list(
				"subcategory" = subcategory,
				"items" = subcategory_items,
			))
		if(!LAZYLEN(armament_subcategories))
			continue
		data["armaments_list"] += list(list(
			"category" = armament_category,
			"category_limit" = GLOB.armament_entries[armament_category][CATEGORY_LIMIT],
			"category_uses" = used_categories[armament_category],
			"subcategories" = armament_subcategories,
		))

	return data

/datum/component/armament/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("equip_item")
			var/check = check_item(params["armament_ref"])
			if(!check)
				return
			select_armament(usr, check)
		if("buy_ammo")
			var/check = check_item(params["armament_ref"])
			if(!check)
				return
			buy_ammo(usr, check, params["quantity"])
		if("eject_card")
			eject_card(usr)

/datum/component/armament/proc/buy_ammo(mob/user, datum/armament_entry/armament_entry, quantity = 1)
	if(!armament_entry.magazine)
		return
	if(!inserted_card)
		to_chat(user, span_warning("No card inserted!"))
		return
	var/quantity_cost = armament_entry.magazine_cost * quantity
	if(!inserted_card.use_points(quantity_cost))
		to_chat(user, span_warning("Not enough points!"))
		return
	for(var/i in 1 to quantity)
		new armament_entry.magazine(parent_atom.drop_location())

/datum/component/armament/proc/check_item(reference)
	var/datum/armament_entry/armament_entry
	for(var/category in GLOB.armament_entries)
		for(var/subcategory in GLOB.armament_entries[category][CATEGORY_ENTRY])
			armament_entry = locate(reference) in GLOB.armament_entries[category][CATEGORY_ENTRY][subcategory]
			if(armament_entry)
				break
		if(armament_entry)
			break
	if(!armament_entry)
		return FALSE
	if(products && !(armament_entry.type in products))
		return FALSE
	return armament_entry

/datum/component/armament/proc/eject_card(mob/user)
	if(!inserted_card)
		to_chat(user, span_warning("No card inserted!"))
		return
	inserted_card.forceMove(parent_atom.drop_location())
	user.put_in_hands(inserted_card)
	inserted_card = null
	to_chat(user, span_notice("Card ejected!"))
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 70)

/datum/component/armament/proc/select_armament(mob/user, datum/armament_entry/armament_entry)
	if(!inserted_card)
		to_chat(user, span_warning("No card inserted!"))
		return
	if(used_categories[armament_entry.category] >= GLOB.armament_entries[armament_entry.category][CATEGORY_LIMIT])
		to_chat(user, span_warning("Category limit reached!"))
		return
	if(purchased_items[armament_entry] >= armament_entry.max_purchase)
		to_chat(user, span_warning("Item limit reached!"))
		return
	if(!ishuman(user))
		return
	if(!inserted_card.use_points(armament_entry.cost))
		to_chat(user, span_warning("Not enough points!"))
		return

	var/mob/living/carbon/human/human_to_equip = user

	var/obj/item/new_item = new armament_entry.item_type(parent_atom.drop_location())

	used_categories[armament_entry.category]++
	purchased_items[armament_entry]++

	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)

	if(armament_entry.equip_to_human(human_to_equip, new_item))
		to_chat(user, span_notice("Equipped directly to your person."))
		playsound(src, 'sound/items/equip/toolbelt_equip.ogg', 100)
	armament_entry.after_equip(parent_atom.drop_location(), new_item)

/datum/component/armament/proc/check_access(mob/living/user)
	if(!user)
		return FALSE

	if(!required_access)
		return TRUE

	if(issilicon(user))
		if(ispAI(user))
			return FALSE
		return TRUE //AI can do whatever it wants

	if(isAdminGhostAI(user))
		return TRUE

	//If the mob has the simple_access component with the requried access, the check passes
	else if(SEND_SIGNAL(user, COMSIG_MOB_TRIED_ACCESS, src) & ACCESS_ALLOWED)
		return TRUE

	//If the mob is holding a valid ID, they pass the access check
	else if(check_access_obj(user.get_active_held_item()))
		return TRUE

	//if they are wearing a card that has access and are human, that works
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(check_access_obj(human_user.wear_id))
			return TRUE

	//if they're strange and have a hacky ID card as an animal
	else if(isanimal(user))
		var/mob/living/simple_animal/animal = user
		if(check_access_obj(animal.access_card))
			return TRUE

/datum/component/armament/proc/check_access_obj(obj/item/id)
	return check_access_list(id ? id.GetAccess() : null)

/datum/component/armament/proc/check_access_list(list/access_list)
	if(!islist(required_access)) //something's very wrong
		return TRUE

	if(!length(required_access))
		return TRUE

	if(!length(access_list) || !islist(access_list))
		return FALSE

	for(var/req in required_access)
		if(!(req in access_list)) //doesn't have this access
			return FALSE

	return TRUE

/datum/component/armament/proc/text2access(access_text)
	. = list()
	if(!access_text)
		return
	var/list/split = splittext(access_text,";")
	for(var/split_text in split)
		var/num_text = text2num(split_text)
		if(!num_text)
			continue
		. += num_text
