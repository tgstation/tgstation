var/datum/subsystem/shuttle/SSshuttle

/datum/subsystem/shuttle
	name = "Shuttles"
	wait = 10
	priority = 3

	var/list/mobile = list()
	var/list/stationary = list()
	var/list/transit = list()

		//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/emergencyCallTime = 6000	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = 1800	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = 1200	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/area/emergencyLastCallLoc
	var/emergencyNoEscape

		//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	var/ordernum = 1					//order number given to next order
	var/points = 50						//number of trade-points we have
	var/points_per_decisecond = 0.005	//points gained every decisecond
	var/points_per_slip = 2				//points gained per slip returned
	var/points_per_crate = 5			//points gained per crate returned
	var/points_per_intel = 100			//points gained per intel returned
	var/points_per_plasma = 5			//points gained per plasma returned
	var/centcom_message = ""			//Remarks from Centcom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Unique typepaths for unusual things we've already sent CentComm, associated with their potencies
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
	var/datum/round_event/shuttle_loan/shuttle_loan
	var/sold_atoms = ""


/datum/subsystem/shuttle/New()
	NEW_SS_GLOBAL(SSshuttle)


/datum/subsystem/shuttle/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")

	ordernum = rand(1,9000)

	for(var/typepath in typesof(/datum/supply_packs))
		if(typepath == /datum/supply_packs)
			continue
		var/datum/supply_packs/P = new typepath()
		if(P.name == "HEADER") continue		// To filter out group headers
		supply_packs["[P.type]"] = P

	..()


/datum/subsystem/shuttle/fire()
	points += points_per_decisecond * wait

	var/i=1
	for(var/thing in mobile)
		if(thing)
			var/obj/docking_port/mobile/P = thing
			P.check()
			++i
			continue
		mobile.Cut(i, i+1)

/datum/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.id == id)
			return M
	WARNING("couldn't find shuttle with id: [id]")

/datum/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary)
		if(S.id == id)
			return S
	WARNING("couldn't find dock with id: [id]")

/datum/subsystem/shuttle/proc/requestEvac(mob/user, call_reason)
	if(!emergency)
		ERROR("There is no emergency shuttle! The game will be unresolvable. This is likely due to a mapping error")
		return

	if(world.time - round_start_time < config.shuttle_refuel_delay)
		user << "The emergency shuttle is refueling. Please wait another [abs(round(((world.time - round_start_time) - config.shuttle_refuel_delay)/600))] minutes before trying again."
		return

	switch(emergency.mode)
		if(SHUTTLE_RECALL)
			user << "The emergency shuttle may not be called while returning to Centcom."
			return
		if(SHUTTLE_CALL)
			user << "The emergency shuttle is already on its way."
			return
		if(SHUTTLE_DOCKED)
			user << "The emergency shuttle is already here."
			return
		if(SHUTTLE_ESCAPE)
			user << "The emergency shuttle is moving away to a safe distance."
			return
		if(SHUTTLE_STRANDED)
			user << "The emergency shuttle has been disabled by Centcom."
			return

	call_reason = strip_html_properly(trim(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH)
		user << "You must provide a reason."
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	if(seclevel2num(get_security_level()) == SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		emergency.request(null, 0.5, signal_origin, emergency_reason, 1)
	else
		emergency.request(null, 1, signal_origin, emergency_reason, 0)

	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.")

	return

/datum/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(emergency.mode != SHUTTLE_CALL)
		return

	if(ticker.mode.name == "meteor")
		return

	if((seclevel2num(get_security_level()) == SEC_LEVEL_RED))
		if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
			return
	else if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
		return

	emergency.cancel(get_area(user))
	log_game("[key_name(user)] has recalled the shuttle.")
	message_admins("[key_name_admin(user)] has recalled the shuttle.")
	return 1

/datum/subsystem/shuttle/proc/autoEvac()
	var/callShuttle = 1

	for(var/thing in shuttle_caller_list)
		if(istype(thing, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = thing
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.stat & BROKEN)
				continue

		var/turf/T = get_turf(thing)
		if(T && T.z == ZLEVEL_STATION)
			callShuttle = 0
			break

	if(callShuttle)
		if(emergency.mode < SHUTTLE_CALL)
			emergency.request(null, 2.5)
			log_game("There is no means of calling the shuttle anymore. Shuttle automatically called.")
			message_admins("All the communications consoles were destroyed and all AIs are inactive. Shuttle called.")

//try to move/request to dockHome if possible, otherwise dockAway. Mainly used for admin buttons
/datum/subsystem/shuttle/proc/toggleShuttle(shuttleId, dockHome, dockAway, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	var/obj/docking_port/stationary/dockedAt = M.get_docked()
	var/destination = dockHome
	if(dockedAt && dockedAt.id == dockHome)
		destination = dockAway
	if(timed)
		if(M.request(getDock(destination)))
			return 2
	else
		if(M.dock(getDock(destination)))
			return 2
	return 0	//dock successful


/datum/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	if(timed)
		if(M.request(getDock(dockId)))
			return 2
	else
		if(M.dock(getDock(dockId)))
			return 2
	return 0	//dock successful


/*
/proc/push_mob_back(var/mob/living/L, var/dir)
	if(iscarbon(L) && isturf(L.loc))
		if(prob(88))
			var/turf/T = get_step(L, dir)
			if(T)
				for(var/obj/O in T) // For doors and such (kinda ugly but we can't have people opening doors)
					if(!O.CanPass(L, L.loc, 1))
						return
				L.Move(get_step(L, dir), dir)
*/

/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/orderedbyRank
	var/comment = null

/datum/supply_order/proc/generateRequisition(atom/_loc)
	if(!object)
		return

	var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(_loc)
	reqform.name = "requisition form - [object.name]"
	reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
	reqform.info += "INDEX: #[ordernum]<br>"
	reqform.info += "REQUESTED BY: [orderedby]<br>"
	reqform.info += "RANK: [orderedbyRank]<br>"
	reqform.info += "REASON: [comment]<br>"
	reqform.info += "SUPPLY CRATE TYPE: [object.name]<br>"
	reqform.info += "ACCESS RESTRICTION: [replacetext(get_access_desc(object.access))]<br>"
	reqform.info += "CONTENTS:<br>"
	reqform.info += object.manifest
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.update_icon()	//Fix for appearing blank when printed.

	return reqform

/datum/supply_order/proc/createObject(atom/_loc, errors=0)
	if(!object)
		return

		//create the crate
	var/atom/Crate = new object.containertype(_loc)
	Crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	if(object.access)
		Crate:req_access = list(text2num(object.access))

		//create the manifest slip
	var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = (errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packagesAmt = SSshuttle.shoppinglist.len + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
	slip.info +="Order #[ordernum]<br>"
	slip.info +="Destination: [stationName]<br>"
	slip.info +="[packagesAmt] PACKAGES IN THIS SHIPMENT<br>"
	slip.info +="CONTENTS:<br><ul>"

		//we now create the actual contents
	var/list/contains
	if(istype(object, /datum/supply_packs/misc/randomised))
		var/datum/supply_packs/misc/randomised/SO = object
		contains = list()
		if(object.contains.len)
			for(var/j=1, j<=SO.num_contained, j++)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(Crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if((errors & MANIFEST_ERROR_ITEM))
		//secure and large crates cannot lose items
		if(findtext("[object.containertype]", "/secure/") || findtext("[object.containertype]","/largecrate/"))
			errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lostAmt = max(round(Crate.contents.len/10), 1)
			//lose some of the items
			while(--lostAmt >= 0)
				qdel(pick(Crate.contents))

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.loc = Crate
	if(istype(Crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = Crate
		CR.manifest = slip
		CR.update_icon()
	if(istype(Crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = Crate
		LC.manifest = slip
		LC.update_icon()
	
	return Crate

/datum/subsystem/shuttle/proc/generateSupplyOrder(packId, _orderedby, _orderedbyRank, _comment)
	if(!packId)
		return
	var/datum/supply_packs/P = supply_packs["[packId]"]
	if(!P)
		return

	var/datum/supply_order/O = new()
	O.ordernum = ordernum++
	O.object = P
	O.orderedby = _orderedby
	O.orderedbyRank = _orderedbyRank
	O.comment = _comment

	requestlist += O

	return O

/*
/datum/subsystem/shuttle/proc/getShuttleFromArea(area/A)
	if(!A)
		return
	for(var/obj/docking_port/mobile/M in SSshuttle.mobile)
		if(M.areaInstance == A)
			return M
*/
