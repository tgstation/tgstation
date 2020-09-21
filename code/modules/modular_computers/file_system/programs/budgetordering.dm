/datum/computer_file/program/budgetorders
	filename = "orderapp"
	filedesc = "GrandArk Department Orders"
	program_icon_state = "request"
	extended_desc = "A request network that utilizes the Nanotrasen Ordering network to purchase supplies using a department budget account."
	requires_ntnet = TRUE
	transfer_access = ACCESS_HEADS
	usage_flags = PROGRAM_LAPTOP | PROGRAM_TABLET
	size = 20
	tgui_id = "NtosCargo"
	var/requestonly = TRUE
	var/contraband = FALSE
	var/self_paid = FALSE
	var/safety_warning = "For safety reasons, the automated supply shuttle \
		cannot transport live organisms, human remains, classified nuclear weaponry, \
		homing beacons or machinery housing any form of artificial intelligence."
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	/// radio used by the console to send messages on supply channel
	var/obj/item/radio/headset/radio
	/// var that tracks message cooldown
	var/message_cooldown
	var/list/loaded_coupons

/datum/computer_file/program/budgetorders/proc/get_export_categories()
	. = EXPORT_CARGO

/datum/computer_file/program/budgetorders/proc/is_visible_pack(mob/user, paccess_to_check, var/list/access)
	if(issilicon(user)) //Borgs can't buy things.
		return FALSE
	if(computer.obj_flags & EMAGGED)
		return TRUE
	if(!paccess_to_check) // No required_access, allow it.
		return TRUE
	if(isAdminGhostAI(user))
		return TRUE

	//Aquire access from the inserted ID card.
	if(!length(access))
		var/obj/item/card/id/D
		var/obj/item/computer_hardware/card_slot/card_slot
		if(computer)
			card_slot = computer.all_components[MC_CARD]
			D = card_slot?.GetID()
		if(!D)
			return FALSE
		access = D.GetAccess()

	if(paccess_to_check in access)
		return TRUE

	return FALSE

/datum/computer_file/program/budgetorders/ui_data()
	var/list/data = get_header_data()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/buyer = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/id_card = card_slot?.GetID()
	if(id_card?.registered_account)
		if(ACCESS_HEADS in id_card.access)
			requestonly = FALSE
			buyer = SSeconomy.get_dep_account(id_card.registered_account.account_job.paycheck_department)
	if(buyer)
		data["points"] = buyer.account_balance
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	data["cart"] = list()
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		data["cart"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account) //paid by requester
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id
		))

	return data

/datum/computer_file/program/budgetorders/ui_static_data(mob/user)
	var/list/data = list()
	data["requestonly"] = requestonly
	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!is_visible_pack(user, P.access_view) || P.hidden)
			continue
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.DropPodOnly))
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"goody" = P.goody,
			"access" = P.access
		))
	return data

/datum/computer_file/program/budgetorders/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				computer.say(safety_warning)
				return
			if(SSshuttle.supplyBlocked)
				computer.say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.export_categories = get_export_categories()
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				computer.say("The supply shuttle is departing.")
				computer.investigate_log("[key_name(usr)] sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				computer.investigate_log("[key_name(usr)] called the supply shuttle.", INVESTIGATE_CARGO)
				computer.say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supplyBlocked)
				computer.say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				computer.say("The supply shuttle has been loaned to CentCom.")
				computer.investigate_log("[key_name(usr)] accepted a shuttle loan event.", INVESTIGATE_CARGO)
				log_game("[key_name(usr)] accepted a shuttle loan event.")
				. = TRUE
		if("add")
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.hidden && (pack.contraband && !contraband) || pack.DropPodOnly))
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
			if(self_paid && ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(!istype(id_card))
					computer.say("No ID card detected.")
					return
				if(istype(id_card, /obj/item/card/id/departmental_budget))
					computer.say("The [src] rejects [id_card].")
					return
				account = id_card.registered_account
				if(!istype(account))
					computer.say("Invalid bank account.")
					return

			var/reason = ""
			if(requestonly && !self_paid)
				reason = stripped_input("Reason:", name, "")
				if(isnull(reason) || ..())
					return

			if(pack.goody && !self_paid)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				computer.say("ERROR: Small crates may only be purchased by private accounts.")
				return

			var/obj/item/coupon/applied_coupon
			for(var/i in loaded_coupons)
				var/obj/item/coupon/coupon_check = i
				if(pack.type == coupon_check.discounted_pack)
					computer.say("Coupon found! [round(coupon_check.discount_pct_off * 100)]% off applied!")
					coupon_check.moveToNullspace()
					applied_coupon = coupon_check
					break

			var/turf/T = get_turf(src)
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason, account, applied_coupon)
			SO.generateRequisition(T)
			if(requestonly && !self_paid)
				SSshuttle.requestlist += SO
			else
				SSshuttle.shoppinglist += SO
				if(self_paid)
					computer.say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			if(requestonly && message_cooldown < world.time)
				radio.talk_into(src, "A new order has been requested.", RADIO_CHANNEL_SUPPLY)
				message_cooldown = world.time + 30 SECONDS
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
				if(SO.id == id)
					if(SO.applied_coupon)
						computer.say("Coupon refunded.")
						SO.applied_coupon.forceMove(get_turf(src))
					SSshuttle.shoppinglist -= SO
					. = TRUE
					break
		if("clear")
			SSshuttle.shoppinglist.Cut()
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					SSshuttle.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.requestlist.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
	if(.)
		post_signal("supply")

/datum/computer_file/program/budgetorders/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)
