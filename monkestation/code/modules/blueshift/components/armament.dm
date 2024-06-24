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

	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/component/armament/Destroy(force)
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

	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

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
	for(var/armament_category as anything in SSarmaments.entries)
		var/list/armament_subcategories = list()
		for(var/subcategory as anything in SSarmaments.entries[armament_category][CATEGORY_ENTRY])
			var/list/subcategory_items = list()
			for(var/datum/armament_entry/armament_entry as anything in SSarmaments.entries[armament_category][CATEGORY_ENTRY][subcategory])
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
			"category_limit" = SSarmaments.entries[armament_category][CATEGORY_LIMIT],
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
	for(var/category in SSarmaments.entries)
		for(var/subcategory in SSarmaments.entries[category][CATEGORY_ENTRY])
			armament_entry = locate(reference) in SSarmaments.entries[category][CATEGORY_ENTRY][subcategory]
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
	if(used_categories[armament_entry.category] >= SSarmaments.entries[armament_entry.category][CATEGORY_LIMIT])
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

#define MAX_AMMO_AMOUNT 10
#define CARGO_CONSOLE 1
#define IRN_CONSOLE 2

/datum/component/armament/company_imports
	/// Selected amount of ammo to purchase
	var/ammo_purchase_num = 1
	/// Is this set to private order
	var/self_paid = FALSE
	/// Cooldown to announce a requested order
	COOLDOWN_DECLARE(radio_cooldown)
	/// To cut down on redundant istypes(), what this component is attached to
	var/console_state = null
	/// If this is a tablet, the parent budgetordering
	var/datum/computer_file/program/budgetorders/parent_prog

/datum/component/armament/company_imports/Initialize(list/required_products, list/needed_access)
	. = ..()
	if(istype(parent, /obj/machinery/computer/cargo))
		console_state = CARGO_CONSOLE
	else if(istype(parent, /obj/item/modular_computer))
		console_state = IRN_CONSOLE

/datum/component/armament/company_imports/Destroy(force)
	parent_prog = null
	. = ..()

/datum/component/armament/company_imports/on_attack_hand(datum/source, mob/living/user)
	return

/datum/component/armament/company_imports/on_attackby(atom/target, obj/item, mob/user)
	return

/datum/component/armament/company_imports/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/carbon/human/the_person = user
	var/obj/item/card/id/id_card
	var/datum/bank_account/buyer = SSeconomy.get_dep_account(ACCOUNT_CAR)

	if(console_state == IRN_CONSOLE)
		id_card = parent_prog.computer.computer_id_slot?.GetID()
	else
		if(istype(the_person))
			id_card = the_person.get_idcard(TRUE)

	var/budget_name = "Cargo Budget"

	if(id_card?.registered_account && (console_state == IRN_CONSOLE))
		if((ACCESS_COMMAND in id_card.access) || (ACCESS_QM in id_card.access))
			parent_prog.requestonly = FALSE
			buyer = SSeconomy.get_dep_account(id_card.registered_account?.account_job.paycheck_department)
			parent_prog.can_approve_requests = TRUE
		else
			parent_prog.requestonly = TRUE
			parent_prog.can_approve_requests = FALSE
	else
		parent_prog?.requestonly = TRUE

	if(id_card)
		budget_name = self_paid ? id_card.name : buyer.account_holder

	data["budget_name"] = budget_name

	var/cant_buy_restricted = TRUE

	if(console_state == CARGO_CONSOLE)
		var/obj/machinery/computer/cargo/console = parent
		if(!console.requestonly)
			cant_buy_restricted = FALSE

	else if((console_state == IRN_CONSOLE) && id_card?.registered_account)
		if((ACCESS_COMMAND in id_card.access) || (ACCESS_QM in id_card.access))
			if((buyer == SSeconomy.get_dep_account(id_card.registered_account.account_job.paycheck_department)) && !self_paid)
				cant_buy_restricted = FALSE

	data["cant_buy_restricted"] = !!cant_buy_restricted
	data["budget_points"] = self_paid ? id_card?.registered_account?.account_balance : buyer?.account_balance
	data["ammo_amount"] = ammo_purchase_num
	data["self_paid"] = !!self_paid
	data["armaments_list"] = list()

	for(var/armament_category as anything in SSarmaments.entries)

		var/list/armament_subcategories = list()

		for(var/subcategory as anything in SSarmaments.entries[armament_category][CATEGORY_ENTRY])
			var/list/subcategory_items = list()
			for(var/datum/armament_entry/armament_entry as anything in SSarmaments.entries[armament_category][CATEGORY_ENTRY][subcategory])
				if(products && !(armament_entry.type in products))
					continue

				var/datum/armament_entry/company_import/gun_entry = armament_entry

				if(gun_entry.contraband)
					if(!(console_state == CARGO_CONSOLE))
						continue
					var/obj/machinery/computer/cargo/parent_console = parent
					if(!parent_console.contraband)
						continue

				subcategory_items += list(list(
					"ref" = REF(armament_entry),
					"icon" = armament_entry.cached_base64,
					"name" = armament_entry.name,
					"cost" = armament_entry.cost,
					"buyable_ammo" = armament_entry.magazine ? TRUE : FALSE,
					"magazine_cost" = armament_entry.magazine_cost,
					"purchased" = purchased_items[armament_entry] ? purchased_items[armament_entry] : 0,
					"description" = armament_entry.description,
					"armament_category" = armament_entry.category,
					"equipment_subcategory" = armament_entry.subcategory,
					"restricted" = !!armament_entry.restricted,
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
			"category_uses" = used_categories[armament_category],
			"subcategories" = armament_subcategories,
		))

	return data

/datum/component/armament/company_imports/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoImportConsole")
		ui.open()

/datum/component/armament/company_imports/select_armament(mob/user, datum/armament_entry/company_import/armament_entry)
	var/datum/bank_account/buyer = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/obj/item/modular_computer/possible_downloader
	var/obj/machinery/computer/cargo/possible_console

	if(console_state == CARGO_CONSOLE)
		possible_console = parent

	else if(console_state == IRN_CONSOLE)
		possible_downloader = parent

	if(!istype(armament_entry))
		return

	var/mob/living/carbon/human/the_person = user

	if(istype(the_person))

		var/obj/item/card/id/id_card

		if(console_state == IRN_CONSOLE)
			id_card = parent_prog.computer.computer_id_slot?.GetID()
		else
			id_card = the_person.get_idcard(TRUE)

		if(id_card?.registered_account && (console_state == IRN_CONSOLE))
			if((ACCESS_COMMAND in id_card.access) || (ACCESS_QM in id_card.access))
				parent_prog.requestonly = FALSE
				buyer = SSeconomy.get_dep_account(id_card.registered_account.account_job.paycheck_department)
				parent_prog.can_approve_requests = TRUE
			else
				parent_prog.requestonly = TRUE
				parent_prog.can_approve_requests = FALSE
		else
			parent_prog?.requestonly = TRUE

		if(self_paid)
			if(!istype(id_card))
				to_chat(user, span_warning("No ID card detected."))
				return

			if(istype(id_card, /obj/item/card/id/departmental_budget))
				to_chat(user, span_warning("[id_card] cannot be used to make purchases."))
				return

			var/datum/bank_account/account = id_card.registered_account

			if(!istype(account))
				to_chat(user, span_warning("Invalid bank account."))
				return

			buyer = account

	if(issilicon(user) && (console_state == IRN_CONSOLE))
		parent_prog.can_approve_requests = TRUE
		parent_prog.requestonly = FALSE

	if(!buyer)
		to_chat(user, span_warning("No budget found!"))
		return

	if(!ishuman(user) && !issilicon(user))
		return

	if(!buyer.has_money(armament_entry.cost))
		to_chat(user, span_warning("Not enough money!"))
		return

	var/name

	if(issilicon(user))
		name = user.real_name
	else
		the_person.get_authentification_name()

	var/reason = ""

	if(possible_console)
		if(possible_console.requestonly && !self_paid)
			reason = tgui_input_text(user, "Reason", name)
			if(isnull(reason))
				return

	else if(possible_downloader)
		var/datum/computer_file/program/budgetorders/parent_file = parent_prog
		if((parent_file.requestonly && !self_paid) || !(possible_downloader.computer_id_slot?.GetID()))
			reason = tgui_input_text(user, "Reason", name)
			if(isnull(reason))
				return

	used_categories[armament_entry.category]++

	purchased_items[armament_entry]++

	var/datum/supply_pack/armament/created_pack = new
	created_pack.name = initial(armament_entry.item_type.name)
	created_pack.cost = cost_calculate(armament_entry.cost) //Paid for seperately
	created_pack.contains = list(armament_entry.item_type)

	var/rank

	if(issilicon(user))
		rank = "Silicon"
	else
		rank = the_person.get_assignment(hand_first = TRUE)

	var/ckey = user.ckey

	var/datum/supply_order/company_import/created_order
	if(buyer != SSeconomy.get_dep_account(ACCOUNT_CAR))
		created_order = new(created_pack, name, rank, ckey, paying_account = buyer, reason = reason, can_be_cancelled = TRUE)
	else
		created_pack.goody = FALSE // Cargo ordered stuff should just show up in a box I think
		created_order = new(created_pack, name, rank, ckey, reason = reason, can_be_cancelled = TRUE)
	created_order.selected_entry = armament_entry
	created_order.used_component = src
	if(console_state == CARGO_CONSOLE)
		created_order.generateRequisition(get_turf(parent))
		if(possible_console.requestonly && !self_paid)
			SSshuttle.request_list += created_order
		else
			SSshuttle.shopping_list += created_order
	else if(console_state == IRN_CONSOLE)
		var/datum/computer_file/program/budgetorders/comp_file = parent_prog
		created_order.generateRequisition(get_turf(parent))
		if(comp_file.requestonly && !self_paid)
			SSshuttle.request_list += created_order
		else
			SSshuttle.shopping_list += created_order

/datum/component/armament/company_imports/proc/cost_calculate(cost)
	. = cost
	. *= SSeconomy.pack_price_modifier

/datum/component/armament/company_imports/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggleprivate")
			var/obj/item/card/id/id_card
			var/mob/living/carbon/human/the_person = usr

			if(!istype(the_person))
				if(issilicon(the_person))
					self_paid = FALSE
				return

			if(console_state == IRN_CONSOLE)
				id_card = parent_prog.computer.computer_id_slot?.GetID()
			else
				id_card = the_person.get_idcard(TRUE)

			if(!id_card)
				return

			self_paid = !self_paid

#undef MAX_AMMO_AMOUNT
#undef CARGO_CONSOLE
#undef IRN_CONSOLE
