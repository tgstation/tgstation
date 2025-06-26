#define EXPRESS_EMAG_DISCOUNT 0.72
#define BEACON_PRINT_COOLDOWN 10 SECONDS

/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by Nanotrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = list(ACCESS_CARGO)
	is_express = TRUE
	interface_type = "CargoExpress"

	var/message
	var/list/meme_pack_data
	/// The linked supplypod beacon
	var/obj/item/supplypod_beacon/beacon
	/// Where we droppin boys
	var/area/landingzone = /area/station/cargo/storage
	var/pod_type = /obj/structure/closet/supplypod
	/// If this console is locked and needs to be unlocked with an ID
	var/locked = TRUE
	/// Is the console in beacon mode? Exists to let beacon know when a pod may come in
	var/using_beacon = FALSE
	/// Number of beacons printed. Used to determine beacon names.
	var/static/printed_beacons = 0
	/// Cooldown to prevent beacon spam
	COOLDOWN_DECLARE(beacon_print_cooldown)

/obj/machinery/computer/cargo/express/Initialize(mapload)
	. = ..()
	packin_up()
	landingzone = GLOB.areas_by_type[landingzone]
	if (isnull(landingzone))
		WARNING("[src] couldnt find a Quartermaster/Storage (aka cargobay) area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
		landingzone = get_area(src)

/obj/machinery/computer/cargo/express/on_construction(mob/user, from_flatpack = FALSE)
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/Destroy()
	if(beacon)
		beacon.unlink_console()
	return ..()

/obj/machinery/computer/cargo/express/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (tool.GetID() && allowed(user))
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the interface."))
		return ITEM_INTERACT_SUCCESS

	if (istype(tool, /obj/item/disk/cargo/bluespace_pod))
		if (pod_type == /obj/structure/closet/supplypod/bluespacepod)
			balloon_alert(user, "already upgraded!")
			return ITEM_INTERACT_FAILURE
		if(!user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_FAILURE
		pod_type = /obj/structure/closet/supplypod/bluespacepod // doesnt affect our circuit board, making reversal possible
		to_chat(user, span_notice("You insert the disk into [src], allowing for advanced supply delivery vehicles."))
		tool.forceMove(src)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/supplypod_beacon))
		var/obj/item/supplypod_beacon/beacon = tool
		if (beacon.express_console != src)
			beacon.link_console(src, user)
			return ITEM_INTERACT_SUCCESS

		to_chat(user, span_alert("[src] is already linked to [beacon]."))
		return ITEM_INTERACT_FAILURE

	return NONE

/obj/machinery/computer/cargo/express/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	if(user)
		if (emag_card)
			user.visible_message(span_warning("[user] swipes [emag_card] through [src]!"))
		to_chat(user, span_notice("You change the routing protocols, allowing the Supply Pod to land anywhere on the station."))
	obj_flags |= EMAGGED
	contraband = TRUE
	// This also sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.obj_flags |= EMAGGED
	board.contraband = TRUE
	packin_up()
	return TRUE

/obj/machinery/computer/cargo/express/proc/packin_up(forced = FALSE) // oh shit, I'm sorry
	meme_pack_data = list() // sorry for what?
	if(!forced && !SSshuttle.initialized) // our quartermaster taught us not to be ashamed of our supply packs
		SSshuttle.express_consoles += src // specially since they're such a good price and all
		return // yeah, I see that, your quartermaster gave you good advice
	// it gets cheaper when I return it
	for(var/pack_id in SSshuttle.supply_packs) // mmhm
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_id] // sometimes, I return it so much, I rip the manifest
		if(!meme_pack_data[pack.group]) // see, my quartermaster taught me a few things too
			meme_pack_data[pack.group] = list( // like, how not to rip the manifest
				"name" = pack.group, // by using someone else's crate
				"packs" = get_packs_data(pack.group, express = TRUE), // will you show me?
			) // i'd be right happy to

/obj/machinery/computer/cargo/express/ui_data(mob/user)
	var/canBeacon = beacon && (isturf(beacon.loc) || ismob(beacon.loc))//is the beacon in a valid location?
	var/list/data = list()
	var/datum/bank_account/account = SSeconomy.get_dep_account(cargo_account)
	if(account)
		data["points"] = account.account_balance
	data["locked"] = locked//swipe an ID to unlock
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["beaconzone"] = beacon ? get_area(beacon) : ""//where is the beacon located? outputs in the tgui
	data["using_beacon"] = using_beacon //is the mode set to deliver to the beacon or the cargobay?
	data["canBeacon"] = !using_beacon || canBeacon //is the mode set to beacon delivery, and is the beacon in a valid location?
	data["canBuyBeacon"] = COOLDOWN_FINISHED(src, beacon_print_cooldown) && account.account_balance >= BEACON_COST
	data["beaconError"] = using_beacon && !canBeacon ? "(BEACON ERROR)" : ""//changes button text to include an error alert if necessary
	data["hasBeacon"] = beacon != null//is there a linked beacon?
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"
	data["printMsg"] = COOLDOWN_FINISHED(src, beacon_print_cooldown) ? "Print Beacon for [BEACON_COST] credits" : "Print Beacon for [BEACON_COST] credits ([COOLDOWN_TIMELEFT(src, beacon_print_cooldown)])" //buttontext for printing beacons
	data["supplies"] = list()
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supply_blocked)
		message = blockade_warning
	if(using_beacon && !beacon)
		message = "BEACON ERROR: BEACON MISSING"//beacon was destroyed
	else if (using_beacon && !canBeacon)
		message = "BEACON ERROR: MUST BE EXPOSED"//beacon's loc/user's loc must be a turf
	if(obj_flags & EMAGGED)
		message = "(&!#@ERROR: R0UTING_#PRO7O&OL MALF(*CT#ON. $UG%ESTE@ ACT#0N: !^/PULS3-%E)ET CIR*)ITB%ARD."
	data["message"] = message
	if(!meme_pack_data)
		packin_up()
		stack_trace("There was no pack data for [src]")
	data["supplies"] = meme_pack_data
	return data

/obj/machinery/computer/cargo/express/get_discount()
	return (obj_flags & EMAGGED) ? EXPRESS_EMAG_DISCOUNT : 1

/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("LZCargo")
			using_beacon = FALSE
			if (beacon)
				beacon.update_status(SP_UNREADY) //ready light on beacon will turn off
		if("LZBeacon")
			using_beacon = TRUE
			if (beacon)
				beacon.update_status(SP_READY) //turns on the beacon's ready light
		if("printBeacon")
			var/datum/bank_account/account = SSeconomy.get_dep_account(cargo_account)
			if(isnull(account) || !account.adjust_money(-BEACON_COST))
				return

			// a ~ten second cooldown for printing beacons to prevent spam
			COOLDOWN_START(src, beacon_print_cooldown, BEACON_PRINT_COOLDOWN)
			var/obj/item/supplypod_beacon/new_beacon = new /obj/item/supplypod_beacon(drop_location())
			new_beacon.link_console(src, user) //rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc)
			printed_beacons++ //printed_beacons starts at 0, so the first one out will be called beacon # 1
			beacon.name = "Supply Pod Beacon #[printed_beacons]"

		if("add")//Generate Supply Order first
			if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_EXPRESSPOD_CONSOLE))
				say("Railgun recalibrating. Stand by.")
				return
			var/id = params["id"]
			id = text2path(id) || id
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				CRASH("Unknown supply pack id given by express order console ui. ID: [params["id"]]")
			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = user.ckey
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(HAS_SILICON_ACCESS(user))
				name = user.real_name
				rank = "Silicon"
			var/reason = ""
			var/datum/supply_order/order = new(pack, name, rank, ckey, reason)
			var/datum/bank_account/account = SSeconomy.get_dep_account(cargo_account)
			if (isnull(account) && order.pack.get_cost() > 0)
				return

			if (obj_flags & EMAGGED)
				landingzone = GLOB.areas_by_type[pick(GLOB.the_station_areas)]

			var/list/empty_turfs
			if (!istype(beacon) || !using_beacon || (obj_flags & EMAGGED))
				empty_turfs = list()
				for(var/turf/open/floor/open_turf in landingzone.get_turfs_from_all_zlevels())
					if(!open_turf.is_blocked_turf())
						empty_turfs += open_turf

				if (!length(empty_turfs))
					return

			if (obj_flags & EMAGGED)
				if (account.account_balance < order.pack.get_cost() * -get_discount())
					return

				TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 10 SECONDS)
				order.generateRequisition(get_turf(src))
				for(var/i in 1 to MAX_EMAG_ROCKETS)
					if (!account.adjust_money(order.pack.get_cost() * -get_discount()))
						break

					var/turf/landing_turf = pick(empty_turfs)
					empty_turfs -= landing_turf
					if(pack.special_pod)
						new /obj/effect/pod_landingzone(landing_turf, pack.special_pod, order)
					else
						new /obj/effect/pod_landingzone(landing_turf, pod_type, order)

				update_appearance()
				return TRUE

			var/turf/landing_turf
			if (istype(beacon) && using_beacon)
				landing_turf = get_turf(beacon)
				beacon.update_status(SP_LAUNCH)
			else
				landing_turf = pick(empty_turfs)

			if (!account.adjust_money(-order.pack.get_cost() * get_discount()))
				return

			TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)
			if(pack.special_pod)
				new /obj/effect/pod_landingzone(landing_turf, pack.special_pod, order)
			else
				new /obj/effect/pod_landingzone(landing_turf, pod_type, order)

			update_appearance()
			return TRUE

#undef EXPRESS_EMAG_DISCOUNT
#undef BEACON_PRINT_COOLDOWN
