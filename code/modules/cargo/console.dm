/obj/machinery/computer/cargo
	name = "supply console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/weapon/circuitboard/cargo
	var/requestonly = FALSE
	var/contraband = FALSE

/obj/machinery/computer/cargo/request
	name = "supply request console"
	desc = "Used to request supplies from cargo."
	icon_screen = "request"
	circuit = /obj/item/weapon/circuitboard/cargo/request
	requestonly = TRUE

/obj/machinery/computer/cargo/New()
	..()
	var/obj/item/weapon/circuitboard/cargo/board = circuit
	contraband = board.contraband

/obj/machinery/computer/cargo/emag_act(mob/user)
	if(!emagged)
		user << "<span class='notice'>Special supplies unlocked.</span>"
		emagged = TRUE

/obj/machinery/computer/cargo/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
											datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo", name, 1000, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/cargo/ui_data()
	var/list/data = list()
	data["requestonly"] = requestonly
	data["location"] = SSshuttle.supply.getStatusText()
	data["points"] = SSshuttle.points
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["message"] = SSshuttle.centcom_message || "Remember to stamp and send back the supply manifests."

	var/list/supplies = list()
	supplies.len = all_supply_groups.len
	for(var/group in all_supply_groups)
		supplies[group] = list(
			"name" = get_supply_group_name(group),
			"packs" = list()
		)
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_packs/P = SSshuttle.supply_packs[pack]
		if((P.hidden && !emagged) || (P.contraband && !contraband))
			continue
		supplies[P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack
		))
	data["supplies"] = supplies

	data["cart"] = list()
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		data["cart"] += list(list(
			"object" = SO.object.name,
			"cost" = SO.object.cost,
			"id" = SO.ordernum
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.object.name,
			"cost" = SO.object.cost,
			"orderedby" = SO.orderedby,
			"comment" = SO.comment,
			"id" = SO.ordernum
		))

	return data

/obj/machinery/computer/cargo/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(action != "add" && requestonly)
		return
	switch(action)
		if("send")
			if(SSshuttle.supply.canMove())
				say("For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.")
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				say("The supply shuttle has departed.")
				investigate_log("[key_name(usr)] has sent the supply shuttle away. Points: [SSshuttle.points]. Contents: [SSshuttle.sold_atoms].", "cargo")
			else
				investigate_log("[key_name(usr)] has called the supply shuttle. Points: [SSshuttle.points].", "cargo") // TODO: more robust logging here
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			else if(SSshuttle.supply.mode == SHUTTLE_IDLE)
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to Centcom.")
				. = TRUE
		if("add")
			var/id = params["id"]
			if(!SSshuttle.supply_packs[id])
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment()
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/reason = ""
			if(requestonly)
				reason = input("Reason:", name, "") as text|null
				if(isnull(reason) || ..())
					return

			var/turf/T = get_turf(src)
			var/datum/supply_order/SO = SSshuttle.generateSupplyOrder(id, name, rank, reason)
			SO.generateRequisition(T)
			if(requestonly)
				SSshuttle.requestlist += SO
			else
				SSshuttle.shoppinglist += SO
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
				if(SO.ordernum == id)
					SSshuttle.shoppinglist -= SO
					. = TRUE
					break
		if("clear")
			SSshuttle.shoppinglist.Cut()
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.ordernum == id)
					SSshuttle.requestlist -= SO
					SSshuttle.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.ordernum == id)
					SSshuttle.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.requestlist.Cut()
			. = TRUE
	if(.)
		post_signal("supply")

/obj/machinery/computer/cargo/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

