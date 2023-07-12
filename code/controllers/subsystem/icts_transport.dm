PROCESSING_SUBSYSTEM_DEF(icts_transport)
	name = "ICTS"
	wait = 0.5
	/// only used on maps with trams, so only enabled by such.
	can_fire = FALSE

	///associative list of the form: list(lift_id = list(all lift_master datums attached to lifts of that type))
	var/list/transports_by_type
	var/list/nav_beacons
	///how much time a tram can take per movement before we notify admins and slow down the tram. in milliseconds
	var/max_time = 15
	///how many times the tram can move costing over max_time milliseconds before it gets slowed down
	var/max_exceeding_moves = 5
	///how many times the tram can move costing less than half max_time milliseconds before we speed it back up again.
	///is only used if the tram has been slowed down for exceeding max_time
	var/max_cheap_moves = 5

/datum/controller/subsystem/processing/icts_transport/Initialize()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_REQUEST, PROC_REF(call_request))

/datum/controller/subsystem/processing/icts_transport/Recover()
	_listen_lookup = SSicts_transport._listen_lookup

/datum/controller/subsystem/processing/icts_transport/proc/call_request(source, transport_network, platform)
	debug_admins("ICTS: Call request")
	var/datum/transport_controller/linear/tram/transport_controller
	var/obj/effect/landmark/icts/nav_beacon/tram/destination
	for(var/datum/transport_controller/linear/tram/candidate_controller as anything in transports_by_type[ICTS_TYPE_TRAM])
		if(candidate_controller.specific_transport_id == transport_network)
			transport_controller = candidate_controller
			break

	if(!transport_controller || !transport_controller.controller_operational)
		debug_admins("ICTS: COMSIG_ICTS_RESPONSE, REQUEST_FAIL, NOT_IN_SERVICE")
		SEND_ICTS_SIGNAL(source, COMSIG_ICTS_RESPONSE, REQUEST_FAIL, NOT_IN_SERVICE)
		return

	if(transport_controller.travelling) //in use
		debug_admins("ICTS: COMSIG_ICTS_RESPONSE, REQUEST_FAIL, TRANSPORT_IN_USE")
		SEND_ICTS_SIGNAL(source, COMSIG_ICTS_RESPONSE, REQUEST_FAIL, TRANSPORT_IN_USE)
		return

//	for(var/obj/effect/landmark/icts/nav_beacon/tram/candidate_destination as anything in SSicts_transport.nav_beacons[specific_transport_id])
//		if(candidate_destination.platform_code == params["destination"])
//			destination = candidate_destination
//			break

	if(!destination)
		debug_admins("ICTS: COMSIG_ICTS_RESPONSE, REQUEST_FAIL, INVALID_PLATFORM")
		SEND_ICTS_SIGNAL(src, source, COMSIG_ICTS_RESPONSE, REQUEST_FAIL, INVALID_PLATFORM)
		return

	if(!destination.platform_status != PLATFORM_ACTIVE)
		debug_admins("ICTS: COMSIG_ICTS_RESPONSE, REQUEST_FAIL, NOT_IN_SERVICE")
		SEND_ICTS_SIGNAL(src, source, COMSIG_ICTS_RESPONSE, REQUEST_FAIL, PLATFORM_DISABLED)
		return

	if(transport_controller.idle_platform == destination) //already here
		debug_admins("ICTS: COMSIG_ICTS_RESPONSE, REQUEST_FAIL, NO_CALL_REQUIRED")
		SEND_ICTS_SIGNAL(src, source, COMSIG_ICTS_RESPONSE, REQUEST_FAIL, NO_CALL_REQUIRED)
		return

	if(!transport_controller.calculate_route(destination))
		debug_admins("ICTS: COMSIG_ICTS_RESPONSE, REQUEST_FAIL, INTERNAL_ERROR")
		SEND_ICTS_SIGNAL(src, source, COMSIG_ICTS_RESPONSE, REQUEST_FAIL, INTERNAL_ERROR)
		return

	var/trip_direction = transport_controller.travel_direction
	var/trip_remaining = transport_controller.travel_remaining

