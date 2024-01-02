/**
 * Computer
 */
/obj/machinery/computer/voidcrew_cargo
	name = "cargo console"
	desc = "Used to call and send freight from a ship."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/voidcrew_cargo
	light_color = COLOR_BRIGHT_ORANGE

	///The linked supplypod beacon that will drop/send the cargo container.
	var/obj/item/supply_beacon/beacon
	///The machine we're connected to that holds our bank account.
	var/obj/machinery/computer/bank_machine/bank_account_holder

	///List of everything we're attempting to purchase.
	var/list/datum/supply_order/checkout_list = list()

	/// Cooldown between calling so you don't repeatedly spawn and delete crates.
	COOLDOWN_DECLARE(calling_cooldown)

/obj/machinery/computer/voidcrew_cargo/Destroy()
	if(bank_account_holder)
		on_bank_deletion(bank_account_holder)
	if(beacon)
		QDEL_NULL(beacon)
	QDEL_LIST(checkout_list)
	return ..()

/obj/machinery/computer/voidcrew_cargo/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/supply_beacon))
		beacon = weapon
		balloon_alert_to_viewers("beacon updated")

/obj/machinery/computer/voidcrew_cargo/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(QDELETED(tool.buffer) || !istype(tool.buffer, /obj/machinery/computer/bank_machine))
		return
	bank_account_holder = tool.buffer
	RegisterSignal(tool.buffer, COMSIG_PARENT_QDELETING, PROC_REF(on_bank_deletion))
	playsound(user, 'sound/machines/ding.ogg', 40, TRUE)
	balloon_alert_to_viewers("new account synced")
	return TRUE

/obj/machinery/computer/voidcrew_cargo/proc/on_bank_deletion(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	bank_account_holder = null

/obj/machinery/computer/voidcrew_cargo/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VoidcrewCargo", name)
		ui.open()

/obj/machinery/computer/voidcrew_cargo/ui_static_data(mob/user)
	var/list/data = list()
	data["beacon_cost_message"] = "Print a beacon for [BEACON_COST] credits"
	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !(obj_flags & EMAGGED)) || (P.special && !P.special_enabled) || P.drop_pod_only)
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"goody" = P.goody,
			"access" = P.access
		))
	return data

/obj/machinery/computer/voidcrew_cargo/ui_data(mob/user)
	var/list/data = list()

	data["has_bank_account"] = !!bank_account_holder
	if(!bank_account_holder.synced_bank_account)
		data["beacon_error_message"] += "Potential Errors: NO BANK ACCOUNT CONNECTED"//beacon was destroyed
		return data

	data["on_cargo_cooldown"] = !COOLDOWN_FINISHED(src, calling_cooldown)
	data["cargo_ordered"] = !!bank_account_holder.synced_bank_account.shipping_containers.len
	data["points"] = bank_account_holder.synced_bank_account.account_balance

	data["has_beacon"] = !!beacon
	data["can_buy_beacon"] = !beacon && bank_account_holder.synced_bank_account.account_balance >= BEACON_COST
	if(!beacon)
		data["beacon_error_message"] = "Potential Errors: BEACON MISSING"//beacon was destroyed
	else if(!isturf(beacon.loc))
		data["beacon_error_message"] = "Potential Errors: BEACON MUST BE EXPOSED"//beacon's loc/user's loc must be a turf
	else
		data["beacon_error_message"] = null

	data["beaconzone"] = beacon ? get_area(beacon) : "No beacon"
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"

	var/cart_list = list()
	for(var/datum/supply_order/order as anything in checkout_list)
		if(cart_list[order.pack.name])
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

	return data

/obj/machinery/computer/voidcrew_cargo/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!bank_account_holder.synced_bank_account)
		balloon_alert(usr, "no bank account connected.")
		usr.playsound_local(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
		return

	switch(action)
		/**
		 * BECAON STUFF
		 */
		if("print_beacon")
			if(beacon)
				return TRUE
			if(!bank_account_holder.synced_bank_account)
				return FALSE
			if(bank_account_holder.synced_bank_account.adjust_money(-BEACON_COST))
				var/obj/item/supply_beacon/new_beacon = new /obj/item/supply_beacon(drop_location())
				new_beacon.cargo_console = src
				new_beacon.name = "Supply Pod Beacon ([bank_account_holder.synced_bank_account.account_holder])"
				beacon = new_beacon
			return TRUE

		/**
		 * CARGO ORDERING
		 */
		if("add")
			return add_item(params)
		if("add_by_name")
			var/supply_pack_id = name_to_id(params["order_name"])
			if(!supply_pack_id)
				return
			return add_item(list("id" = supply_pack_id, "amount" = 1))
		if("remove")
			var/order_name = params["order_name"]
			for(var/datum/supply_order/order as anything in checkout_list)
				if(order.pack.name != order_name)
					continue
				if(remove_item(list("id" = order.id)))
					return TRUE

			return TRUE
		if("modify")
			var/order_name = params["order_name"]
			//clear out all orders with the above mentioned order_name name to make space for the new amount
			for(var/datum/supply_order/order as anything in checkout_list) //find corresponding order id for the order name
				if(order.pack.name == order_name)
					remove_item(list("id" = "[order.id]"))

			//now add the new amount stuff
			var/amount = text2num(params["amount"])
			if(!amount)
				return TRUE
			var/supply_pack_id = name_to_id(order_name) //map order name to supply pack id for adding
			if(!supply_pack_id)
				return FALSE
			return add_item(list("id" = supply_pack_id, "amount" = amount))
		if("clear")
			//create copy of list else we will get runtimes when iterating & removing items on the same list checkout_list
			for(var/datum/supply_order/cancelled_order as anything in checkout_list)
				if(!cancelled_order.can_be_cancelled)
					continue //don't cancel other department's orders or orders that can't be cancelled
				if(remove_item(list("id" = "[cancelled_order.id]")))
					return TRUE
			return TRUE


		/**
		 * DROP POD HANDLING
		 */
		if("send")
			COOLDOWN_START(src, calling_cooldown, 30 SECONDS)
			//make an copy of the cart before its cleared by the shuttle
			var/list/cart_list = list()
			for(var/datum/supply_order/order as anything in checkout_list)
				if(cart_list[order.pack.name])
					cart_list[order.pack.name]["amount"]++
					continue
				cart_list[order.pack.name] = list(
					"order" = order,
					"amount" = 1,
				)

			if(bank_account_holder.synced_bank_account.shipping_containers.len)
				say("The freight container is departing.")
				usr.investigate_log("sent the [bank_account_holder.synced_bank_account.account_holder] cargo pod away.", INVESTIGATE_CARGO)
				sell()
			else
				say("The freight container has been called and will arrive soon.")
				usr.investigate_log("called the [bank_account_holder.synced_bank_account.account_holder] cargo pod.", INVESTIGATE_CARGO)
				buy()
			if(!length(cart_list))
				return TRUE

			//create the paper from the cart list
			var/obj/item/paper/requisition_paper = new(get_turf(src))
			requisition_paper.name = "requisition form"
			var/requisition_text = "<h2>[station_name()] Supply Requisition</h2>"
			requisition_text += "<hr/>"
			requisition_text += "Time of Order: [station_time_timestamp()]<br/>"
			for(var/order_name in cart_list)
				var/datum/supply_order/order = cart_list[order_name]["order"]
				requisition_text += "[cart_list[order_name]["amount"]] [order.pack.name]("
				requisition_text += "Access Restrictions: [SSid_access.get_access_desc(order.pack.access)])</br>"
			requisition_paper.add_raw_text(requisition_text)
			requisition_paper.update_appearance()
			return TRUE

/**
 * Adds an item to the grocery list
 */
/obj/machinery/computer/voidcrew_cargo/proc/add_item(params)
	var/id = params["id"]
	id = text2path(id) || id
	var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
	if(!istype(pack))
		CRASH("Unknown supply pack id given by order console ui. ID: [params["id"]]")

	var/name = "*None Provided*"
	var/rank = "*None Provided*"
	if(ishuman(usr))
		var/mob/living/carbon/human/human = usr
		name = human.get_authentification_name()
		rank = human.get_assignment(hand_first = TRUE)
	else if(issilicon(usr))
		name = usr.real_name
		rank = "Silicon"
	else
		name = usr.real_name
		rank = "Unknown"

	var/amount = params["amount"]
	for(var/count in 1 to amount)

		var/datum/supply_order/new_order = new(
			pack = pack,
			orderer = name,
			orderer_rank = rank,
			orderer_ckey = usr.ckey,
			paying_account = bank_account_holder.synced_bank_account,
		)
		checkout_list += new_order

	return TRUE

/**
 * Removes an item from the grocery list
 */
/obj/machinery/computer/voidcrew_cargo/proc/remove_item(params)
	var/id = text2num(params["id"])
	for(var/datum/supply_order/order as anything in checkout_list)
		if(order.id != id)
			continue
		checkout_list -= order
		. = TRUE
		break

/**
 * Finds an item in the grocery list using their name
 */
/obj/machinery/computer/voidcrew_cargo/proc/name_to_id(order_name)
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/supply = SSshuttle.supply_packs[pack]
		if(order_name == supply.name)
			return pack
	return null

/**
 * Circuit board
 */
/obj/item/circuitboard/computer/voidcrew_cargo
	name = "Supply Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/voidcrew_cargo
