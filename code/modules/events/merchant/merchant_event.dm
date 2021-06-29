/datum/round_event_control/merchant
	name = "Merchant"
	typepath = /datum/round_event/merchant
	max_occurrences = 1

/datum/round_event_control/merchant/canSpawnEvent(players)
	if(!SSeconomy.get_dep_account(ACCOUNT_CAR))
		return FALSE //They can't pay?
	if(!EMERGENCY_IDLE_OR_RECALLED)
		return FALSE //merchant docks where escape is
	return ..()

/datum/round_event/merchant
	var/ship_name = "\"In the Unlikely Event\""
	var/datum/comm_message/merchant_message
	var/datum/merchant/visiting_merchant

/datum/round_event/merchant/announce(fake)
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", SSstation.announcer.get_rand_report_sound())

/datum/round_event/merchant/setup()
	var/merchant_path = pick(subtypesof(/datum/merchant))
	visiting_merchant = new merchant_path

/datum/round_event/merchant/start()
	merchant_message = new(visiting_merchant, visiting_merchant.message_greet, list("Send [INITIAL_VISIT_COST] Credits.","Reject Offer."))
	merchant_message.answer_callback = CALLBACK(src,.proc/answered)
	SScommunications.send_message(merchant_message, unique = TRUE)

/datum/round_event/merchant/proc/answered()
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		priority_announce(visiting_merchant.message_too_late, sender_override = visiting_merchant)
		return
	if(merchant_message?.answered == RESPONSE_MERCHANT_LEAVE)
		return

	var/datum/bank_account/station_balance = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(!station_balance?.has_money(-INITIAL_VISIT_COST))
		priority_announce(visiting_merchant.message_too_poor, sender_override = visiting_merchant)
		return
	priority_announce(visiting_merchant.message_docking, sender_override = visiting_merchant)
	spawn_shuttle()

/datum/round_event/merchant/proc/spawn_shuttle()

	var/datum/map_template/shuttle/merchant/ship = new visiting_merchant.map_template_path
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("merchant event found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading merchant ship failed!")

	for(var/obj/docking_port/mobile/merchant/port in ship.get_affected_turfs(T))
		port.visiting_merchant = visiting_merchant
		port.dock_id("emergency_home")
		break

/obj/docking_port/mobile/merchant
	name = "merchant shuttle"
	id = "merchant"
	///timer for when the merchant shuttle needs to fly into the sunset.
	var/take_off_timer_id
	///reference to the datum merchant
	var/datum/merchant/visiting_merchant

/obj/docking_port/mobile/merchant/Initialize(mapload)
	. = ..()
	RegisterSignal(SSshuttle, COMSIG_EMERGENCY_SHUTTLE_CALLED, .proc/on_emergency_shuttle_call)
	RegisterSignal(SSshuttle, COMSIG_EMERGENCY_SHUTTLE_RECALLED, .proc/on_emergency_shuttle_recall)


/obj/docking_port/mobile/merchant/Destroy(force)
	. = ..()
	UnregisterSignal(SSshuttle, list(COMSIG_EMERGENCY_SHUTTLE_CALLED))
	QDEL_NULL(visiting_merchant)

/obj/docking_port/mobile/merchant/proc/on_emergency_shuttle_call(datum/subsystem, call_time)
	SIGNAL_HANDLER

	take_off_timer_id = addtimer(CALLBACK(src, .proc/fly_away), call_time / 2)

/obj/docking_port/mobile/merchant/proc/on_emergency_shuttle_recall(datum/subsystem)
	deltimer(take_off_timer_id)

/obj/docking_port/mobile/merchant/proc/fly_away()
	priority_announce(visiting_merchant.message_leaving, sender_override = visiting_merchant)
	jumpToNullSpace()
