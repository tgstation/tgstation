PROCESSING_SUBSYSTEM_DEF(transport)
	name = "Transport"
	wait = 0.5
	/// only used on maps with trams, so only enabled by such.
	can_fire = FALSE

	///associative list of the form: list(lift_id = list(all transport_controller datums attached to lifts of that type))
	var/list/transports_by_type = list()
	var/list/nav_beacons = list()
	var/list/crossing_signals = list()
	var/list/sensors = list()
	var/list/doors = list()
	var/list/displays = list()
	///how much time a tram can take per movement before we notify admins and slow down the tram. in milliseconds
	var/max_time = 15
	///how many times the tram can move costing over max_time milliseconds before it gets slowed down
	var/max_exceeding_moves = 5
	///how many times the tram can move costing less than half max_time milliseconds before we speed it back up again.
	///is only used if the tram has been slowed down for exceeding max_time
	var/max_cheap_moves = 5
	var/static/list/all_radial_directions = list(
		"NORTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"NORTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHEAST),
		"EAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
		"SOUTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHEAST),
		"SOUTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
		"SOUTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHWEST),
		"WEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST),
		"NORTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHWEST)
	)

/datum/controller/subsystem/processing/transport/proc/hello(new_unit)
	RegisterSignal(new_unit, COMSIG_TRANSPORT_REQUEST, PROC_REF(incoming_request))

/datum/controller/subsystem/processing/transport/Recover()
	_listen_lookup = SStransport._listen_lookup

/datum/controller/subsystem/processing/transport/proc/incoming_request(source, obj/effect/landmark/icts/nav_beacon/tram/transport_network, platform, options)
	SIGNAL_HANDLER

	var/relevant
	var/request_flags = options
	var/datum/transport_controller/linear/tram/transport_controller
	var/obj/effect/landmark/icts/nav_beacon/tram/platform/destination
	for(var/datum/transport_controller/linear/tram/candidate_controller as anything in transports_by_type[TRANSPORT_TYPE_TRAM])
		if(candidate_controller.specific_transport_id == transport_network)
			transport_controller = candidate_controller
			break

	LAZYADD(relevant, source)

	if(!transport_controller || !transport_controller.controller_operational || !transport_controller.paired_cabinet)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, NOT_IN_SERVICE)
		return

	if(transport_controller.controller_status & SYSTEM_FAULT || transport_controller.controller_status & EMERGENCY_STOP)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INTERNAL_ERROR)
		return

	if(transport_controller.controller_active) //in use
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, TRANSPORT_IN_USE)
		return

	var/network = LAZYACCESS(nav_beacons, transport_network)
	for(var/obj/effect/landmark/icts/nav_beacon/tram/platform/potential_destination in network)
		if(potential_destination.platform_code == platform)
			destination = potential_destination
			break

	if(!destination)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INVALID_PLATFORM)
		return

	if(!destination.platform_status == PLATFORM_ACTIVE)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, PLATFORM_DISABLED)
		return

	if(transport_controller.idle_platform == destination) //did you even look?
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, NO_CALL_REQUIRED)
		return

	if(!transport_controller.calculate_route(destination))
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INTERNAL_ERROR)
		return

	SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_SUCCESS)

	INVOKE_ASYNC(src, PROC_REF(dispatch_transport), transport_controller, request_flags)

/datum/controller/subsystem/processing/transport/proc/dispatch_transport(datum/transport_controller/linear/tram/transport_controller, destination, request_flags)
	if(transport_controller.idle_platform == transport_controller.destination_platform)
		return

	transport_controller.set_active(TRUE)
	pre_departure(transport_controller, request_flags)

/datum/controller/subsystem/processing/transport/proc/pre_departure(datum/transport_controller/linear/tram/transport_controller, request_flags)
	if(transport_controller.controller_status & COMM_ERROR)
		request_flags |= BYPASS_SENSORS
	transport_controller.set_status_code(PRE_DEPARTURE, TRUE)
	transport_controller.set_status_code(CONTROLS_LOCKED, TRUE)
	transport_controller.set_lights()
	if(request_flags & RAPID_MODE || request_flags & BYPASS_SENSORS) // bypass for unsafe, rapid departure
		for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, close), BYPASS_DOOR_CHECKS)
		if(request_flags & RAPID_MODE)
			transport_controller.dispatch_transport()
			return
	else
		for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, close))

	addtimer(CALLBACK(src, PROC_REF(validate_and_dispatch), transport_controller), 3 SECONDS)

/datum/controller/subsystem/processing/transport/proc/validate_and_dispatch(datum/transport_controller/linear/tram/transport_controller, attempt)
	var/current_attempt
	if(attempt)
		current_attempt = attempt
	else
		current_attempt = 0

	if(current_attempt >= 4)
		halt_and_catch_fire(transport_controller)
		return

	current_attempt++

	transport_controller.update_status()
	if(transport_controller.controller_status & DOORS_OPEN)
		addtimer(CALLBACK(src, PROC_REF(validate_and_dispatch), transport_controller, current_attempt), 3 SECONDS)
		return
	else
		transport_controller.dispatch_transport()

/datum/controller/subsystem/processing/transport/proc/halt_and_catch_fire(datum/transport_controller/linear/tram/transport_controller)
	transport_controller.travel_remaining = 0
	transport_controller.set_active(FALSE)
	transport_controller.set_status_code(SYSTEM_FAULT, TRUE)
	message_admins("TRANSPORT: Transport Controller Failed!")
	for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, open))

/datum/controller/subsystem/processing/transport/proc/detailed_destination_list(specific_transport_id)
	. = list()
	for(var/obj/effect/landmark/icts/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)
