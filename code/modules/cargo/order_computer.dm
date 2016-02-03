/obj/machinery/computer/supplycomp
	name = "supply shuttle console"
	desc = "Used to order supplies."
	icon_screen = "supply"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/supplycomp
	verb_say = "flashes"
	verb_ask = "flashes"
	verb_exclaim = "flashes"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"

/obj/machinery/computer/supplycomp/New()
	..()

	var/obj/item/weapon/circuitboard/supplycomp/board = circuit
	can_order_contraband = board.contraband_enabled

/obj/machinery/computer/supplycomp/attack_hand(mob/user)
	if(!allowed(user))
		user << "<span class='warning'>Access Denied.</span>"
		return

	if(..())
		return
	user.set_machine(src)
	post_signal("supply")
	var/dat
	if (temp)
		dat = temp
	else
		var/atDepot = (SSshuttle.supply.getDockedId() == "supply_away")
		var/inTransit = (SSshuttle.supply.mode != SHUTTLE_IDLE)
		var/canOrder = atDepot && !inTransit

		dat += {"<div class='statusDisplay'><B>Supply shuttle</B><HR>
		Location: [SSshuttle.supply.getStatusText()]<BR>
		<HR>\nSupply Points: [SSshuttle.points]<BR>\n</div><BR>
		[canOrder ? "\n<A href='?src=\ref[src];order=categories'>Order items</A><BR>\n<BR>" : "\n*Must be away to order items*<BR>\n<BR>"]
		[inTransit ? "\n*Shuttle already called*<BR>\n<BR>": atDepot ? "\n<A href='?src=\ref[src];send=1'>Send to station</A><BR>\n<BR>":"\n<A href='?src=\ref[src];send=1'>Send to centcom</A><BR>\n<BR>"]
		[SSshuttle.shuttle_loan ? (SSshuttle.shuttle_loan.dispatched ? "\n*Shuttle loaned to Centcom*<BR>\n<BR>" : "\n<A href='?src=\ref[src];send=1;loan=1'>Loan shuttle to Centcom (5 mins duration)</A><BR>\n<BR>") : "\n*No pending external shuttle requests*<BR>\n<BR>"]
		\n<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>\n<BR>
		\n<A href='?src=\ref[src];vieworders=1'>View orders</A><BR>\n<BR>
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A><BR>
		<HR>\n<B>Central Command messages:</B><BR> [SSshuttle.centcom_message ? SSshuttle.centcom_message : "Remember to stamp and send back the supply manifests."]"}

	var/datum/browser/popup = new(user, "computer", "Supply Shuttle Console", 700, 455)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/supplycomp/emag_act(mob/user)
	if(!hacked)
		user << "<span class='notice'>Special supplies unlocked.</span>"
		hacked = 1

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return

	if(isturf(loc) && ( in_range(src, usr) || istype(usr, /mob/living/silicon) ) )
		usr.set_machine(src)

	//Calling the shuttle
	if(href_list["send"])
		if(SSshuttle.supply.canMove())
			if(SSshuttle.shuttle_loan)
				temp = "The supply shuttle must be docked to send new commands.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
			else
				temp = "For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

		else if(SSshuttle.supply.getDockedId() == "supply_home")
			if(href_list["loan"] && SSshuttle.shuttle_loan)
				if(!SSshuttle.shuttle_loan.dispatched)
					SSshuttle.shuttle_loan.loan_shuttle()
					temp = "The supply shuttle has been loaned to Centcom.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
					post_signal("supply")
				else
					temp = "You can not loan the supply shuttle at this time.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
			else
				temp = "The supply shuttle has departed.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				SSshuttle.toggleShuttle("supply", "supply_home", "supply_away", 1)
				investigate_log("[usr.key] has sent the supply shuttle away. Remaining points: [SSshuttle.points]. Shuttle contents:[SSshuttle.sold_atoms]", "cargo")
		else
			if(href_list["loan"] && SSshuttle.shuttle_loan)
				if(!SSshuttle.shuttle_loan.dispatched && SSshuttle.supply.mode == SHUTTLE_IDLE) // Must either be at centcom, or at the station. No redirecting off course!
					SSshuttle.shuttle_loan.loan_shuttle()
					temp = "The supply shuttle has been loaned to Centcom.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
					post_signal("supply")
				else
					temp = "You can not loan the supply shuttle at this time.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
			else
				if(!SSshuttle.supply.request(SSshuttle.getDock("supply_home")))
					temp = "The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.<BR><BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
					post_signal("supply")

	else if (href_list["order"])
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			return
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<div class='statusDisplay'><b>Supply points: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR></div><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/cat in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[cat]'>[get_supply_group_name(cat)]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			var/cat = text2num(last_viewed_group)
			temp = "<div class='statusDisplay'><b>Supply points: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><BR></div><BR>"
			temp += "<b>Request from: [get_supply_group_name(cat)]</b><BR><BR>"
			for(var/supply_type in SSshuttle.supply_packs )
				var/datum/supply_packs/N = SSshuttle.supply_packs[supply_type]
				if((N.hidden && !hacked) || (N.contraband && !can_order_contraband) || N.group != cat)
					continue		//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_type]'>[N.name]</A> Cost: [N.cost]<BR>"		//the obj because it would get caught by the garbage

		/*temp = "Supply points: [supply_shuttle.points]<BR><HR><BR>Request what?<BR><BR>"

		for(var/supply_name in supply_shuttle.supply_packs )
			var/datum/supply_packs/N = supply_shuttle.supply_packs[supply_name]
			if(N.hidden && !hacked) continue
			if(N.contraband && !can_order_contraband) continue
			temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: [N.cost]<BR>"    //the obj because it would get caught by the garbage
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"*/

	else if (href_list["doorder"])
		if(world.time < reqtime)
			say("[world.time - reqtime] seconds remaining until another requisition form may be printed.")
			return

		//Find the correct supply_pack datum
		if(!SSshuttle.supply_packs[href_list["doorder"]])
			return

		var/timeout = world.time + 600
		var/reason = stripped_input(usr,"Reason:","Why do you require this item?","")
		if(world.time > timeout)
			return
//		if(!reason)
//			return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		var/datum/supply_order/O = SSshuttle.generateSupplyOrder(href_list["doorder"], idname, idrank, reason)
		if(!O)
			return
		O.generateRequisition(loc)

		reqtime = (world.time + 5) % 1e5

		temp = "Order request placed.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> | <A href='?src=\ref[src];mainmenu=1'>Main Menu</A> | <A href='?src=\ref[src];confirmorder=[O.ordernum]'>Authorize Order</A>"

	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		temp = "Invalid Request"
		for(var/i=1, i<=SSshuttle.requestlist.len, i++)
			var/datum/supply_order/SO = SSshuttle.requestlist[i]
			if(SO && SO.ordernum == ordernum)
				O = SO
				P = O.object
				if(SSshuttle.points >= P.cost)
					SSshuttle.requestlist.Cut(i,i+1)
					SSshuttle.points -= P.cost
					SSshuttle.shoppinglist += O
					temp = "Thanks for your order."
					investigate_log("[usr.key] has authorized an order for [P.name]. Remaining points: [SSshuttle.points].", "cargo")
				else
					temp = "Not enough supply points."
				break
		temp += "<BR><BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["vieworders"])
		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR><BR>Current approved orders: <BR><BR>"
		for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
			temp += "#[SO.ordernum] - [SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""]<BR>"// <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
/*
	else if (href_list["cancelorder"])
		var/datum/supply_order/remove_supply = href_list["cancelorder"]
		supply_shuttle_shoppinglist -= remove_supply
		supply_shuttle_points += remove_supply.object.cost
		temp += "Canceled: [remove_supply.object.name]<BR><BR><BR>"

		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			temp += "[SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""] <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
*/
	else if (href_list["viewrequests"])
		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR><BR>Current requests: <BR><BR>"
		for(var/datum/supply_order/SO in SSshuttle.requestlist)
			temp += "#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]  [SSshuttle.supply.getDockedId() == "supply_away" ? "<A href='?src=\ref[src];confirmorder=[SO.ordernum]'>Approve</A> <A href='?src=\ref[src];rreq=[SO.ordernum]'>Remove</A>" : ""]<BR>"

		temp += "<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>"

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Invalid Request.<BR>"
		for(var/i=1, i<=SSshuttle.requestlist.len, i++)
			var/datum/supply_order/SO = SSshuttle.requestlist[i]
			if(SO && SO.ordernum == ordernum)
				SSshuttle.requestlist.Cut(i,i+1)
				temp = "Request removed.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["clearreq"])
		SSshuttle.requestlist.Cut()
		temp = "List cleared.<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

