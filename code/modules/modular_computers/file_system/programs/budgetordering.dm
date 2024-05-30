/datum/computer_file/program/budgetorders
	filename = "orderapp"
	filedesc = "NT IRN"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Nanotrasen Internal Requisition Network interface for supply purchasing using a department budget account."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_LAPTOP | PROGRAM_PDA
	size = 10
	tgui_id = "NtosCargo"
	program_icon = FA_ICON_CART_FLATBED
	///Are you actually placing orders with it?
	var/requestonly = TRUE
	///Can the tablet see or buy illegal stuff?
	var/contraband = FALSE
	///Is it being bought from a personal account, or is it being done via a budget/cargo?
	var/self_paid = FALSE
	///Can this console approve purchase requests?
	var/can_approve_requests = FALSE
	///What do we say when the shuttle moves with living beings on it.
	var/safety_warning = "For safety and ethical reasons, the automated supply shuttle cannot transport live organisms, \
		human remains, classified nuclear weaponry, mail, undelivered departmental order crates, syndicate bombs, \
		homing beacons, unstable eigenstates, or machinery housing any form of artificial intelligence."
	///If you're being raided by pirates, what do you tell the crew?
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	///The name of the shuttle template being used as the cargo shuttle. 'cargo' is default and contains critical code. Don't change this unless you know what you're doing.
	var/cargo_shuttle = "cargo"
	///The docking port called when returning to the station.
	var/docking_home = "cargo_home"
	///The docking port called when leaving the station.
	var/docking_away = "cargo_away"
	///If this console can loan the cargo shuttle. Set to false to disable.
	var/stationcargo = TRUE
	///The account this console processes and displays. Independent from the account the shuttle processes.
	var/cargo_account = ACCOUNT_CAR

/datum/computer_file/program/budgetorders/proc/is_visible_pack(mob/user, paccess_to_check, list/access, contraband)
	if(HAS_SILICON_ACCESS(user)) //Borgs can't buy things.
		return FALSE
	if(computer.obj_flags & EMAGGED)
		return TRUE
	else if(contraband) //Hide contrband when non-emagged.
		return FALSE
	if(!paccess_to_check) // No required_access, allow it.
		return TRUE
	if(isAdminGhostAI(user))
		return TRUE

	//Aquire access from the inserted ID card.
	if(!length(access))
		var/obj/item/card/id/D = computer?.computer_id_slot?.GetID()
		if(!D)
			return FALSE
		access = D.GetAccess()

	if(paccess_to_check in access)
		return TRUE

	return FALSE

/datum/computer_file/program/budgetorders/ui_data(mob/user)
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	data["department"] = "Cargo"
	var/datum/bank_account/buyer = SSeconomy.get_dep_account(cargo_account)
	var/obj/item/card/id/id_card = computer.computer_id_slot?.GetID()
	if(id_card?.registered_account)
		if((ACCESS_COMMAND in id_card.access))
			requestonly = FALSE
			buyer = SSeconomy.get_dep_account(id_card.registered_account.account_job.paycheck_department)
			can_approve_requests = TRUE
		else
			requestonly = TRUE
			can_approve_requests = FALSE
		if(ACCESS_COMMAND in id_card.access)
			// If buyer is a departmental budget, replaces "Cargo" with that budget - we're not using the cargo budget here
			data["department"] = addtext(buyer.account_holder, " Requisitions")
	else
		requestonly = TRUE
	if(buyer)
		data["points"] = buyer.account_balance

	//Otherwise static data, that is being applied in ui_data as the crates visible and buyable are not static, and are determined by inserted ID.
	data["requestonly"] = requestonly
	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!is_visible_pack(user, P.access_view , null, P.contraband) || P.hidden)
			continue
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.drop_pod_only))
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"goody" = P.goody,
			"access" = P.access
		))

	//Data regarding the User's capability to buy things.
	data["has_id"] = id_card
	data["away"] = SSshuttle.supply.getDockedId() == docking_away
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["can_send"] = FALSE //There is no situation where I want the app to be able to send the shuttle AWAY from the station, but conversely is fine.
	data["can_approve_requests"] = can_approve_requests
	data["app_cost"] = TRUE
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supply_blocked)
		message = blockade_warning
	data["message"] = message
	var/list/amount_by_name = list()
	var/cart_list = list()
	for(var/datum/supply_order/order in SSshuttle.shopping_list)
		if(cart_list[order.pack.name])
			amount_by_name[order.pack.name] += 1
			cart_list[order.pack.name][1]["amount"]++
			cart_list[order.pack.name][1]["cost"] += order.get_final_cost()
			if(order.department_destination)
				cart_list[order.pack.name][1]["dep_order"]++
			if(!isnull(order.paying_account))
				cart_list[order.pack.name][1]["paid"]++
			continue

		cart_list[order.pack.name] = list(list(
			"cost_type" = order.cost_type,
			"object" = order.pack.name,
			"cost" = order.get_final_cost(),
			"id" = order.id,
			"amount" = 1,
			"orderer" = order.orderer,
			"paid" = !isnull(order.paying_account) ? 1 : 0, //number of orders purchased privatly
			"dep_order" = order.department_destination ? 1 : 0, //number of orders purchased by a department
			"can_be_cancelled" = order.can_be_cancelled,
		))
	data["cart"] = list()
	for(var/item_id in cart_list)
		data["cart"] += cart_list[item_id]

	data["requests"] = list()
	for(var/datum/supply_order/order in SSshuttle.request_list)
		var/datum/supply_pack/pack = order.pack
		amount_by_name[pack.name] += 1
		data["requests"] += list(list(
			"object" = pack.name,
			"cost" = pack.get_cost(),
			"orderer" = order.orderer,
			"reason" = order.reason,
			"id" = order.id
		))
	data["amount_by_name"] = amount_by_name

	return data

/datum/computer_file/program/budgetorders/ui_static_data(mob/user)
	var/list/data = list()
	data["max_order"] = CARGO_MAX_ORDER
	return data

/datum/computer_file/program/budgetorders/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				computer.say(safety_warning)
				return
			if(SSshuttle.supply_blocked)
				computer.say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == docking_home)
				SSshuttle.moveShuttle(cargo_shuttle, docking_away, TRUE)
				computer.say("The supply shuttle is departing.")
				usr.investigate_log("sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				usr.investigate_log("called the supply shuttle.", INVESTIGATE_CARGO)
				computer.say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle(cargo_shuttle, docking_home, TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supply_blocked)
				computer.say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != docking_away)
				return
			else if(stationcargo != TRUE)
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				computer.say("The supply shuttle has been loaned to CentCom.")
				usr.investigate_log("accepted a shuttle loan event.", INVESTIGATE_CARGO)
				usr.log_message("accepted a shuttle loan event.", LOG_GAME)
				. = TRUE
		if("add")
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			if(pack.hidden || pack.contraband || pack.drop_pod_only || (pack.special && !pack.special_enabled))
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/datum/bank_account/account
			if(self_paid)
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(!istype(id_card))
					computer.say("No ID card detected.")
					return
				if(IS_DEPARTMENTAL_CARD(id_card))
					computer.say("[id_card] cannot be used to make purchases.")
					return
				account = id_card.registered_account
				if(!istype(account))
					computer.say("Invalid bank account.")
					return

			var/reason = ""
			if((requestonly && !self_paid) || !(computer.computer_id_slot?.GetID()))
				reason = tgui_input_text(usr, "Reason", name)
				if(isnull(reason) || ..())
					return

			if(pack.goody && !self_paid)
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				computer.say("ERROR: Small crates may only be purchased by private accounts.")
				return

			if(SSshuttle.supply.get_order_count(pack) == OVER_ORDER_LIMIT)
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				computer.say("ERROR: No more then [CARGO_MAX_ORDER] of any pack may be ordered at once")
				return

			if(!requestonly && !self_paid && ishuman(usr) && !account)
				var/obj/item/card/id/id_card = computer.computer_id_slot?.GetID()
				account = SSeconomy.get_dep_account(id_card?.registered_account?.account_job.paycheck_department)

			var/turf/T = get_turf(computer)
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason, account)
			SO.generateRequisition(T)
			if((requestonly && !self_paid) || !(computer.computer_id_slot?.GetID()))
				SSshuttle.request_list += SO
			else
				SSshuttle.shopping_list += SO
				if(self_paid)
					computer.say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.shopping_list)
				if(SO.id == id)
					SSshuttle.shopping_list -= SO
					. = TRUE
					break
		if("clear")
			for(var/datum/supply_order/cancelled_order in SSshuttle.shopping_list)
				if(cancelled_order.department_destination || cancelled_order.can_be_cancelled)
					continue //don't cancel other department's orders or orders that can't be cancelled
				SSshuttle.shopping_list -= cancelled_order
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.request_list)
				if(SO.id == id)
					var/obj/item/card/id/id_card = computer.computer_id_slot?.GetID()
					if(id_card && id_card?.registered_account)
						SO.paying_account = SSeconomy.get_dep_account(id_card?.registered_account?.account_job.paycheck_department)
					SSshuttle.request_list -= SO
					SSshuttle.shopping_list += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.request_list)
				if(SO.id == id)
					SSshuttle.request_list -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.request_list.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
	if(.)
		post_signal(cargo_shuttle)

/datum/computer_file/program/budgetorders/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)
