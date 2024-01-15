#define MAX_AMMO_AMOUNT 10
#define CARGO_CONSOLE 1
#define IRN_CONSOLE 2

/datum/component/armament/cargo_gun
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

/datum/component/armament/cargo_gun/Initialize(list/required_products, list/needed_access)
	. = ..()
	if(istype(parent, /obj/machinery/computer/cargo))
		console_state = CARGO_CONSOLE
	else if(istype(parent, /obj/item/modular_computer))
		console_state = IRN_CONSOLE

/datum/component/armament/cargo_gun/Destroy(force, silent)
	parent_prog = null
	. = ..()

/datum/component/armament/cargo_gun/on_attack_hand(datum/source, mob/living/user)
	return

/datum/component/armament/cargo_gun/on_attackby(atom/target, obj/item, mob/user)
	return

/datum/component/armament/cargo_gun/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/carbon/human/the_person = user
	var/obj/item/card/id/id_card
	var/datum/bank_account/buyer = SSeconomy.get_dep_account(ACCOUNT_CAR)

	if(console_state == IRN_CONSOLE)
		var/obj/item/computer_hardware/card_slot/card_slot = parent_prog.computer.all_components[MC_CARD]
		id_card = card_slot.GetID()
	else
		if(istype(the_person))
			id_card = the_person.get_idcard(TRUE)

	var/budget_name = "Cargo Budget"

	if(id_card?.registered_account && (console_state == IRN_CONSOLE))
		if((ACCESS_HEADS in id_card.access) || (ACCESS_QM in id_card.access))
			parent_prog.requestonly = FALSE
			buyer = SSeconomy.get_dep_account(id_card.registered_account.account_job.paycheck_department)
			parent_prog.can_approve_requests = TRUE
		else
			parent_prog.requestonly = TRUE
			parent_prog.can_approve_requests = FALSE
	else
		parent_prog?.requestonly = TRUE

	if(id_card)
		budget_name = self_paid ? id_card.name : buyer.account_holder

	data["budget_name"] = budget_name

	data["budget_points"] = self_paid ? id_card?.registered_account?.account_balance : buyer?.account_balance
	data["ammo_amount"] = ammo_purchase_num
	data["self_paid"] = !!self_paid
	data["armaments_list"] = list()

	for(var/armament_category as anything in GLOB.armament_entries)
		var/illegal_failure

		for(var/company as anything in SSgun_companies.companies)
			if(company != armament_category)
				continue

			var/datum/gun_company/selected_company = SSgun_companies.companies[company]

			if(!(console_state == CARGO_CONSOLE) && selected_company.illegal)
				illegal_failure = TRUE
				break

			var/obj/machinery/computer/cargo/cargo_comp = parent
			if(selected_company.illegal && !cargo_comp.contraband)
				illegal_failure = TRUE
				break

		if(illegal_failure)
			continue

		var/list/armament_subcategories = list()

		for(var/subcategory as anything in GLOB.armament_entries[armament_category][CATEGORY_ENTRY])
			var/list/subcategory_items = list()
			for(var/datum/armament_entry/armament_entry as anything in GLOB.armament_entries[armament_category][CATEGORY_ENTRY][subcategory])
				if(products && !(armament_entry.type in products))
					continue

				var/datum/armament_entry/cargo_gun/gun_entry = armament_entry

				if(gun_entry.contraband)
					if(!(console_state == CARGO_CONSOLE))
						continue
					var/obj/machinery/computer/cargo/parent_console = parent
					if(!parent_console.contraband)
						continue

				var/cant_purchase = FALSE

				if(gun_entry.interest_required)
					for(var/company_interested as anything in SSgun_companies.companies)
						if(company_interested != armament_category)
							continue
						var/datum/gun_company/company_datum = SSgun_companies.companies[company_interested]
						if(company_datum.interest < gun_entry.interest_required)
							cant_purchase = TRUE

				subcategory_items += list(list(
					"ref" = REF(armament_entry),
					"icon" = armament_entry.cached_base64,
					"name" = armament_entry.name,
					"cost" = armament_entry.cost,
					"buyable_ammo" = armament_entry.magazine ? TRUE : FALSE,
					"magazine_cost" = armament_entry.magazine_cost,
					"quantity" = gun_entry.stock,
					"purchased" = purchased_items[armament_entry] ? purchased_items[armament_entry] : 0,
					"description" = armament_entry.description,
					"armament_category" = armament_entry.category,
					"equipment_subcategory" = armament_entry.subcategory,
					"cant_purchase" = !!cant_purchase,
				))

			if(!LAZYLEN(subcategory_items))
				continue

			armament_subcategories += list(list(
				"subcategory" = subcategory,
				"items" = subcategory_items,
			))

		if(!LAZYLEN(armament_subcategories))
			continue

		var/purchased_company = FALSE
		var/company_cost = 0
		var/handout_company = FALSE

		for(var/company as anything in SSgun_companies.companies)
			if(company != armament_category)
				continue

			if(company in SSgun_companies.purchased_companies)
				purchased_company = TRUE

			var/datum/gun_company/company_datum = SSgun_companies.companies[company]

			if((company_datum in SSgun_companies.chosen_handouts) && !SSgun_companies.handout_picked)
				handout_company = TRUE

			company_cost = company_datum.cost


		data["armaments_list"] += list(list(
			"category" = armament_category,
			"category_purchased" = !!purchased_company,
			"category_uses" = used_categories[armament_category],
			"subcategories" = armament_subcategories,
			"cost" = company_cost,
			"handout" = !!handout_company,
		))

	return data

/datum/component/armament/cargo_gun/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoGunConsole")
		ui.open()

/datum/component/armament/cargo_gun/select_armament(mob/user, datum/armament_entry/cargo_gun/armament_entry)
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

	if(!istype(the_person))
		return

	var/obj/item/card/id/id_card

	if(console_state == IRN_CONSOLE)
		var/obj/item/computer_hardware/card_slot/card_slot = parent_prog.computer.all_components[MC_CARD]
		id_card = card_slot.GetID()
	else
		id_card = the_person.get_idcard(TRUE)

	if(id_card?.registered_account && (console_state == IRN_CONSOLE))
		if((ACCESS_HEADS in id_card.access) || (ACCESS_QM in id_card.access))
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

	if(!buyer)
		to_chat(user, span_warning("No budget found!"))
		return

	if(!armament_entry.stock)
		to_chat(user, span_warning("No stock of this item left!"))
		return

	if(!ishuman(user))
		return

	if(!buyer.has_money(armament_entry.cost)) //so you can't "stash" guns for later merchant cycles
		to_chat(user, span_warning("Not enough money!"))
		return

	var/name = the_person.get_authentification_name()
	var/reason = ""

	if(possible_console)
		if(possible_console.requestonly && !self_paid)
			reason = tgui_input_text(user, "Reason", name)
			if(isnull(reason))
				return

	else if(possible_downloader)
		var/datum/computer_file/program/budgetorders/parent_file = parent_prog
		var/obj/item/computer_hardware/card_slot/card_slot = possible_downloader.all_components[MC_CARD]
		if((parent_file.requestonly && !self_paid) || !(card_slot?.GetID()))
			reason = tgui_input_text(user, "Reason", name)
			if(isnull(reason))
				return

	used_categories[armament_entry.category]++

	purchased_items[armament_entry]++
	armament_entry.stock--

	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)

	var/datum/supply_pack/armament/created_pack = new
	created_pack.name = initial(armament_entry.item_type.name)
	created_pack.cost = cost_calculate(armament_entry.cost) //Paid for seperately
	created_pack.contains = list(armament_entry.item_type)
	var/rank = the_person.get_assignment(hand_first = TRUE)
	var/ckey = the_person.ckey
	var/datum/supply_order/armament/created_order
	if(buyer != SSeconomy.get_dep_account(ACCOUNT_CAR))
		created_order = new(created_pack, name, rank, ckey, paying_account = buyer, reason = reason)
	else
		created_order = new(created_pack, name, rank, ckey, reason = reason)
	created_order.interest_addition = armament_entry.interest_addition
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

/datum/component/armament/cargo_gun/buy_ammo(mob/user, datum/armament_entry/cargo_gun/armament_entry)
	var/datum/bank_account/buyer = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/obj/machinery/computer/cargo/possible_console
	var/obj/item/modular_computer/possible_downloader

	if(console_state == CARGO_CONSOLE)
		possible_console = parent

	else if(console_state == IRN_CONSOLE)
		possible_downloader = parent

	var/mob/living/carbon/human/the_person = user

	if(!istype(the_person))
		return

	var/obj/item/card/id/id_card

	if(console_state == IRN_CONSOLE)
		var/obj/item/computer_hardware/card_slot/card_slot = parent_prog.computer.all_components[MC_CARD]
		id_card = card_slot.GetID()
	else
		id_card = the_person.get_idcard(TRUE)

	if(id_card?.registered_account && (console_state == IRN_CONSOLE))
		if((ACCESS_HEADS in id_card.access) || (ACCESS_QM in id_card.access))
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

	if(!armament_entry.magazine)
		return

	if(!buyer)
		to_chat(user, span_warning("No budget found!"))
		return

	var/quantity_cost = armament_entry.magazine_cost * ammo_purchase_num

	if(!buyer.has_money(quantity_cost))
		to_chat(user, span_warning("Not enough money!"))
		return

	var/name = the_person.get_authentification_name()
	var/reason = ""

	if(possible_console)
		if(possible_console.requestonly && !self_paid)
			reason = tgui_input_text(user, "Reason", name)
			if(isnull(reason))
				return

	else if(possible_downloader)
		var/datum/computer_file/program/budgetorders/parent_file = parent_prog
		var/obj/item/computer_hardware/card_slot/card_slot = possible_downloader.all_components[MC_CARD]
		if((parent_file.requestonly && !self_paid) || !(card_slot?.GetID()))
			reason = tgui_input_text(user, "Reason", name)
			if(isnull(reason))
				return


	var/datum/supply_pack/created_pack = new
	var/assembled_name = "[initial(armament_entry.item_type.name)] Ammunition (x[ammo_purchase_num])"
	created_pack.name = assembled_name
	created_pack.cost = cost_calculate(quantity_cost)
	created_pack.contains = list()
	for(var/i in 1 to ammo_purchase_num)
		created_pack.contains += armament_entry.magazine
	var/rank = the_person.get_assignment(hand_first = TRUE)
	var/ckey = the_person.ckey
	var/datum/supply_order/armament/created_order
	if(buyer != SSeconomy.get_dep_account(ACCOUNT_CAR))
		created_order = new(created_pack, name, rank, ckey, paying_account = buyer, reason = reason)
	else
		created_order = new(created_pack, name, rank, ckey, reason = reason)
	created_order.interest_addition = 1 * ammo_purchase_num
	var/datum/computer_file/program/budgetorders/file_p = parent_prog
	if(console_state == CARGO_CONSOLE)
		created_order.generateRequisition(get_turf(parent))
		if(possible_console.requestonly && !self_paid)
			SSshuttle.request_list += created_order
		else
			SSshuttle.shopping_list += created_order
	else if(console_state == IRN_CONSOLE)
		if(file_p.requestonly && !self_paid)
			SSshuttle.request_list += created_order
		else
			SSshuttle.shopping_list += created_order

/datum/component/armament/cargo_gun/proc/cost_calculate(cost)
	. = cost
	. *= SSeconomy.pack_price_modifier

/datum/component/armament/cargo_gun/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_ammo_amount")
			var/target = text2num(params["chosen_amount"])
			ammo_purchase_num = clamp(target, 1, MAX_AMMO_AMOUNT)

		if("buy_company")
			var/target = params["selected_company"]
			var/obj/machinery/computer/cargo/possible_console

			if(console_state == CARGO_CONSOLE)
				possible_console = parent
				if(possible_console.requestonly && !self_paid)
					return
			else if(console_state == IRN_CONSOLE)
				if(parent_prog.requestonly && !self_paid)
					return

			for(var/find_company in SSgun_companies.unpurchased_companies)
				if(find_company != target)
					continue

				var/datum/gun_company/found_company = SSgun_companies.unpurchased_companies[target]
				var/datum/bank_account/buyer = SSeconomy.get_dep_account(ACCOUNT_CAR)

				var/mob/living/carbon/human/user = usr

				if(!istype(user))
					return

				var/obj/item/card/id/id_card = user.get_idcard(TRUE)

				if(id_card?.registered_account && (console_state == IRN_CONSOLE))
					if((ACCESS_HEADS in id_card.access) || (ACCESS_QM in id_card.access))
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

				var/assigned_cost = -found_company.cost
				var/do_payment = TRUE
				if(!SSgun_companies.handout_picked && (found_company in SSgun_companies.chosen_handouts))
					do_payment = FALSE
					SSgun_companies.handout_picked = TRUE
				if(do_payment)
					if(!buyer.adjust_money(assigned_cost))
						return

				SSgun_companies.purchased_companies[find_company] = found_company
				SSgun_companies.unpurchased_companies.Remove(find_company)
				break

		if("toggleprivate")
			var/obj/item/card/id/id_card
			var/mob/living/carbon/human/the_person = usr

			if(!istype(the_person))
				return

			if(console_state == IRN_CONSOLE)
				var/obj/item/computer_hardware/card_slot/card_slot = parent_prog.computer.all_components[MC_CARD]
				id_card = card_slot.GetID()
			else
				id_card = the_person.get_idcard(TRUE)

			if(!id_card)
				return

			self_paid = !self_paid

#undef MAX_AMMO_AMOUNT
#undef CARGO_CONSOLE
#undef IRN_CONSOLE
