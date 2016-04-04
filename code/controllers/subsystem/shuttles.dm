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
	var/points = 5000						//number of trade-points we have
	var/points_per_manifest = 200			//points gained per manifest returned
	var/points_per_crate = 500			//points gained per crate returned
	var/points_per_intel = 25000			//points gained per intel returned
	var/points_per_plasma = 500			//points gained per plasma returned
	var/points_per_design = 2500			//points gained per max reliability research design returned (only for initilally unreliable designs)
	var/centcom_message = ""			//Remarks from Centcom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent CentComm, associated with their potencies
	var/list/techLevels = list()
	var/list/researchDesigns = list()

	var/list/supply_packs = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/orderhistory = list()

	var/datum/round_event/shuttle_loan/shuttle_loan

/datum/subsystem/shuttle/New()
	NEW_SS_GLOBAL(SSshuttle)

/datum/subsystem/shuttle/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")

	ordernum = rand(1, 9000)

	for(var/pack in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new pack()
		if(!P.contains)
			continue
		supply_packs[P.type] = P

	initial_move()
	..()


/datum/subsystem/shuttle/fire()
	for(var/thing in mobile)
		if(thing)
			var/obj/docking_port/mobile/P = thing
			P.check()
			continue
		mobile.Remove(thing)

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
		throw EXCEPTION("requestEvac(): There is no emergency shuttle! The game will be unresolvable. This is likely due to a mapping error")
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

	call_reason = trim(html_encode(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH)
		user << "You must provide a reason."
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	if(seclevel2num(get_security_level()) == SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		emergency.request(null, 0.5, signal_origin, html_decode(emergency_reason), 1)
	else
		emergency.request(null, 1, signal_origin, html_decode(emergency_reason), 0)

	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.")

	return

/datum/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(canRecall())
		emergency.cancel(get_area(user))
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.")
		return 1

/datum/subsystem/shuttle/proc/canRecall()
	if(emergency.mode != SHUTTLE_CALL)
		return
	if(ticker.mode.name == "meteor")
		return
	if(seclevel2num(get_security_level()) == SEC_LEVEL_RED)
		if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
			return
	else
		if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
			return
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

/datum/subsystem/shuttle/proc/initial_move()
	for(var/obj/docking_port/mobile/M in mobile)
		if(!M.roundstart_move)
			continue
		for(var/obj/docking_port/stationary/S in stationary)
			if(S.z != ZLEVEL_STATION && findtext(S.id, M.id))
				S.width = M.width
				S.height = M.height
				S.dwidth = M.dwidth
				S.dheight = M.dheight
		moveShuttle(M.id, "[M.roundstart_move]", 0)
		CHECK_TICK
