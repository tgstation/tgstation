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

/datum/controller/subsystem/processing/transport/proc/hello(atom/new_unit, ref_name, ref_info)
	RegisterSignal(new_unit, COMSIG_TRANSPORT_REQUEST, PROC_REF(incoming_request))
	log_transport("Sub: Registered new transport component [ref_name] [ref_info].")

/datum/controller/subsystem/processing/transport/Recover()
	_listen_lookup = SStransport._listen_lookup

/datum/controller/subsystem/processing/transport/proc/incoming_request(atom/source, obj/effect/landmark/transport/nav_beacon/tram/transport_network, platform, options)
	SIGNAL_HANDLER

	log_transport("Sub: Received request from [source.name] [source.cached_ref]. Contents: [transport_network] [platform] [options]")
	var/relevant
	var/request_flags = options
	var/datum/transport_controller/linear/tram/transport_controller
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination
	for(var/datum/transport_controller/linear/tram/candidate_controller as anything in transports_by_type[TRANSPORT_TYPE_TRAM])
		if(candidate_controller.specific_transport_id == transport_network)
			transport_controller = candidate_controller
			break

	LAZYADD(relevant, source)

	if(isnull(transport_controller))
		log_transport("Sub: Transport [transport_network] has no controller datum! Someone deleted it or something catastrophic happened.")
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, BROKEN_BEYOND_REPAIR)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [INTERNAL_ERROR]. Info: [SUB_TS_STATUS].")
		return

	if(!transport_controller || !transport_controller.controller_operational || !transport_controller.paired_cabinet)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, NOT_IN_SERVICE)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [NOT_IN_SERVICE]. Info: TC-[!transport_controller][!transport_controller.controller_operational][!transport_controller.paired_cabinet].")
		return

	if(transport_controller.controller_status & SYSTEM_FAULT || transport_controller.controller_status & EMERGENCY_STOP)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INTERNAL_ERROR)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [INTERNAL_ERROR]. Info: [SUB_TS_STATUS].")
		return

	if(transport_controller.controller_status & MANUAL_MODE && options != MANUAL_MODE)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, PLATFORM_DISABLED)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [PLATFORM_DISABLED]. Info: [SUB_TS_STATUS].")
		return

	if(transport_controller.controller_active) //in use
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, TRANSPORT_IN_USE)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [PLATFORM_DISABLED]. Info: [TC_TA_INFO].")
		return

	var/network = LAZYACCESS(nav_beacons, transport_network)
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/potential_destination in network)
		if(potential_destination.platform_code == platform)
			destination = potential_destination
			break

	if(!destination)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INVALID_PLATFORM)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [INVALID_PLATFORM]. Info: RD0.")
		return

	if(transport_controller.idle_platform == destination) //did you even look?
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, NO_CALL_REQUIRED)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [NO_CALL_REQUIRED]. Info: RD1.")
		return

	if(!transport_controller.calculate_route(destination))
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INTERNAL_ERROR)
		log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_FAIL] [INTERNAL_ERROR]. Info: NV0.")
		return

	SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_SUCCESS, destination.name)
	log_transport("Sub: Sending response to [source.cached_ref]. Contents: [REQUEST_SUCCESS] [destination.name].")

	INVOKE_ASYNC(src, PROC_REF(dispatch_transport), transport_controller, request_flags)

/datum/controller/subsystem/processing/transport/proc/dispatch_transport(datum/transport_controller/linear/tram/transport_controller, destination, request_flags)
	log_transport("Sub: Sending dispatch request to [transport_controller.specific_transport_id]. [request_flags ? "Contents: [request_flags]." : "No request flags."]")
	if(transport_controller.idle_platform == transport_controller.destination_platform)
		log_transport("Sub: [transport_controller.specific_transport_id] dispatch failed. Info: DE-1 Transport Controller idle and destination are the same.")
		return

	transport_controller.set_active(TRUE)
	pre_departure(transport_controller, request_flags)

/datum/controller/subsystem/processing/transport/proc/pre_departure(datum/transport_controller/linear/tram/transport_controller, request_flags)
	log_transport("Sub: [transport_controller.specific_transport_id] start pre-departure. Info: [SUB_TS_STATUS]")
	if(transport_controller.controller_status & COMM_ERROR)
		request_flags |= BYPASS_SENSORS
	transport_controller.set_status_code(PRE_DEPARTURE, TRUE)
	transport_controller.set_status_code(CONTROLS_LOCKED, TRUE)
	transport_controller.set_lights()
	log_transport("Sub: [transport_controller.specific_transport_id] requested door close. Info: [SUB_TS_STATUS].")
	if(request_flags & RAPID_MODE || request_flags & BYPASS_SENSORS || transport_controller.controller_status & BYPASS_SENSORS) // bypass for unsafe, rapid departure
		for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, close), BYPASS_DOOR_CHECKS)
		if(request_flags & RAPID_MODE)
			log_transport("Sub: [transport_controller.specific_transport_id] rapid mode enabled, bypassing validation.")
			transport_controller.dispatch_transport()
			return
	else
		for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, close))

	addtimer(CALLBACK(src, PROC_REF(validate_and_dispatch), transport_controller), 3 SECONDS)

/datum/controller/subsystem/processing/transport/proc/validate_and_dispatch(datum/transport_controller/linear/tram/transport_controller, attempt)
	log_transport("Sub: [transport_controller.specific_transport_id] start pre-departure validation. Attempts: [attempt ? attempt : 0].")
	var/current_attempt
	if(attempt)
		current_attempt = attempt
	else
		current_attempt = 0

	if(current_attempt >= 4)
		log_transport("Sub: [transport_controller.specific_transport_id] pre-departure validation failed! Info: [SUB_TS_STATUS].")
		transport_controller.halt_and_catch_fire()
		return

	current_attempt++

	transport_controller.update_status()
	if(transport_controller.controller_status & DOORS_OPEN)
		addtimer(CALLBACK(src, PROC_REF(validate_and_dispatch), transport_controller, current_attempt), 4 SECONDS)
		return
	else

		transport_controller.dispatch_transport()
		log_transport("Sub: [transport_controller.specific_transport_id] pre-departure passed.")

/datum/controller/subsystem/processing/transport/proc/detailed_destination_list(specific_transport_id)
	. = list()
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)
