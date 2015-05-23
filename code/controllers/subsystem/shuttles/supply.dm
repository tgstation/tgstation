/obj/item/weapon/paper/manifest
	name = "supply manifest"
	var/erroneous = 0
	var/points = 0
	var/ordernumber = 0

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 1200

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7

/obj/docking_port/mobile/supply/New()
	..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(z == ZLEVEL_STATION)
		return forbidden_atoms_check(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	. = ..()
	if(.)	return .

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(z != ZLEVEL_STATION)		//we only buy when we are -at- the station
		return 1

	if(!SSshuttle.shoppinglist.len)
		return 2

	var/list/emptyTurfs = list()
	for(var/turf/simulated/shuttle/T in areaInstance)
		if(T.density || T.contents.len)	continue
		emptyTurfs += T

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!SO.object) continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			SSshuttle.shoppinglist.Cut(1, SSshuttle.shoppinglist.Find(SO))
			return

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM
		SO.createObject(T, errors)

	SSshuttle.shoppinglist.Cut()


/obj/docking_port/mobile/supply/proc/sell()
	if(z != ZLEVEL_CENTCOM)		//we only sell when we are -at- centcomm
		return 1

	var/plasma_count = 0
	var/intel_count = 0
	var/crate_count = 0

	var/msg = ""
	var/pointsEarned

	for(var/atom/movable/MA in areaInstance)
		if(MA.anchored)	continue
		SSshuttle.sold_atoms += " [MA.name]"

		// Must be in a crate (or a critter crate)!
		if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/critter))
			SSshuttle.sold_atoms += ":"
			if(!MA.contents.len)
				SSshuttle.sold_atoms += " (empty)"
			++crate_count

			var/find_slip = 1
			for(var/thing in MA)
				// Sell manifests
				SSshuttle.sold_atoms += " [thing:name]"
				if(find_slip && istype(thing,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/manifest/slip = thing
					// TODO: Check for a signature, too.
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						// Did they mark it as erroneous?
						var/denied = 0
						for(var/i=1,i<=slip.stamped.len,i++)
							if(slip.stamped[i] == /obj/item/weapon/stamp/denied)
								denied = 1
						if(slip.erroneous && denied) // Caught a mistake by Centcom (IDEA: maybe Centcom rarely gets offended by this)
							pointsEarned = slip.points - SSshuttle.points_per_crate
							SSshuttle.points += pointsEarned // For now, give a full refund for paying attention (minus the crate cost)
							msg += "<font color=green>+[pointsEarned]</font>: Station correctly denied package [slip.ordernumber]: "
							if(slip.erroneous & MANIFEST_ERROR_NAME)
								msg += "Destination station incorrect. "
							else if(slip.erroneous & MANIFEST_ERROR_COUNT)
								msg += "Packages incorrectly counted. "
							else if(slip.erroneous & MANIFEST_ERROR_ITEM)
								msg += "Package incomplete. "
							msg += "Points refunded.<BR>"
						else if(!slip.erroneous && !denied) // Approving a proper order awards the relatively tiny points_per_slip
							SSshuttle.points += SSshuttle.points_per_slip
							msg += "<font color=green>+[SSshuttle.points_per_slip]</font>: Package [slip.ordernumber] accorded.<BR>"
						else // You done goofed.
							if(slip.erroneous)
								msg += "<font color=red>+0</font>: Station approved package [slip.ordernumber] despite error: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect."
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted."
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "We found unshipped items on our dock."
								msg += "  Be more vigilant.<BR>"
							else
								pointsEarned = round(SSshuttle.points_per_crate - slip.points)
								SSshuttle.points += pointsEarned
								msg += "<font color=red>[pointsEarned]</font>: Station denied package [slip.ordernumber].  Our records show no fault on our part.<BR>"
						find_slip = 0
					continue

				// Sell plasma
				if(istype(thing, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = thing
					plasma_count += P.amount

				// Sell syndicate intel
				if(istype(thing, /obj/item/documents/syndicate))
					++intel_count

				if(istype(thing, /obj/item/seeds))
					var/obj/item/seeds/S = thing
					if(S.rarity == 0) // Mundane species
						msg += "<font color=red>+0</font>: We don't need samples of mundane species \"[capitalize(S.species)]\".<BR>"
					else if(SSshuttle.discoveredPlants[S.type]) // This species has already been sent to CentComm
						var/potDiff = S.potency - SSshuttle.discoveredPlants[S.type] // Compare it to the previous best
						if(potDiff > 0) // This sample is better
							SSshuttle.discoveredPlants[S.type] = S.potency
							msg += "<font color=green>+[potDiff]</font>: New sample of \"[capitalize(S.species)]\" is superior.  Good work.<BR>"
							SSshuttle.points += potDiff
						else // This sample is worthless
							msg += "<font color=red>+0</font>: New sample of \"[capitalize(S.species)]\" is not more potent than existing sample ([SSshuttle.discoveredPlants[S.type]] potency).<BR>"
					else // This is a new discovery!
						SSshuttle.discoveredPlants[S.type] = S.potency
						msg += "<font color=green>+[S.rarity]</font>: New species discovered: \"[capitalize(S.species)]\".  Excellent work.<BR>"
						SSshuttle.points += S.rarity // That's right, no bonus for potency.  Send a crappy sample first to "show improvement" later
		qdel(MA)
		SSshuttle.sold_atoms += "."

	if(plasma_count > 0)
		pointsEarned = round(plasma_count * SSshuttle.points_per_plasma)
		msg += "<font color=green>+[pointsEarned]</font>: Received [plasma_count] unit(s) of exotic material.<BR>"
		SSshuttle.points += pointsEarned

	if(intel_count > 0)
		pointsEarned = round(intel_count * SSshuttle.points_per_intel)
		msg += "<font color=green>+[pointsEarned]</font>: Received [intel_count] article(s) of enemy intelligence.<BR>"
		SSshuttle.points += pointsEarned

	if(crate_count > 0)
		pointsEarned = round(crate_count * SSshuttle.points_per_crate)
		msg += "<font color=green>+[pointsEarned]</font>: Received [crate_count] crate(s).<BR>"
		SSshuttle.points += pointsEarned

	SSshuttle.centcom_message = msg


/proc/forbidden_atoms_check(atom/A)
	var/list/blacklist = list(
		/mob/living,
		/obj/effect/blob,
		/obj/effect/spider/spiderling,
		/obj/item/weapon/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/device/radio/beacon,
		/obj/machinery/the_singularitygen,
		/obj/singularity,
	)
	if(A)
		if(is_type_in_list(A, blacklist))
			return 1
		for(var/thing in A)
			if(.(thing))
				return 1

	return 0


/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat += {"<div class='statusDisplay'>Shuttle Location: [SSshuttle.supply.name]<BR>
		<HR>Supply Points: [SSshuttle.points]<BR></div>

		<BR>\n<A href='?src=\ref[src];order=categories'>Request items</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	// Removing the old window method but leaving it here for reference
	//user << browse(dat, "window=computer;size=575x450")
	//onclose(user, "computer")

	// Added the new browser window method
	var/datum/browser/popup = new(user, "computer", "Supply Ordering Console", 575, 450)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if( isturf(loc) && (in_range(src, usr) || istype(usr, /mob/living/silicon)) )
		usr.set_machine(src)

	if(href_list["order"])
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
				if(N.hidden || N.contraband || N.group != cat) continue												//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_type]'>[N.name]</A> Cost: [N.cost]<BR>"		//the obj because it would get caught by the garbage
	else if (href_list["doorder"])
		if(world.time < reqtime)
			say("[world.time - reqtime] seconds remaining until another requisition form may be printed.")
			return

		//Find the correct supply_pack datum
		if(!SSshuttle.supply_packs["[href_list["doorder"]]"])	return

		var/timeout = world.time + 600
		var/reason = stripped_input(usr,"Reason:","Why do you require this item?","")
		if(world.time > timeout)	return
		if(!reason)	return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		var/datum/supply_order/O = SSshuttle.generateSupplyOrder(href_list["doorder"], idname, idrank, reason)
		if(!O) return
		O.generateRequisition(loc)

		reqtime = (world.time + 5) % 1e5

		temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["vieworders"])
		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR><BR>Current approved orders: <BR><BR>"
		for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
			temp += "[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]<BR>"

	else if (href_list["viewrequests"])
		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><BR><BR>Current requests: <BR><BR>"
		for(var/datum/supply_order/SO in SSshuttle.requestlist)
			temp += "#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]<BR>"

	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
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
		if(SSshuttle.supply.mode != SHUTTLE_IDLE) return
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
		if(world.time > timeout)	return
//		if(!reason)	return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		var/datum/supply_order/O = SSshuttle.generateSupplyOrder(href_list["doorder"], idname, idrank, reason)
		if(!O)	return
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

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)
