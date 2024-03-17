PROCESSING_SUBSYSTEM_DEF(transport)
	name = "Transport"
	wait = 0.05 SECONDS
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

/**
 * Registers the subsystem to listen for incoming requests from paired devices
 *
 * When a new device (such as a button, tram, signal etc) comes online
 * it calls this proc with the subsystem enabling two-way communication using
 * signals.
 *
 * Arguments: new_unit: the starting point to find a beacon
 *            unit_name: the friendly name of this device
 *            id_tag: a unique identifier for this device, set on init
 */
/datum/controller/subsystem/processing/transport/proc/hello(atom/new_unit, unit_name, id_tag)
	RegisterSignal(new_unit, COMSIG_TRANSPORT_REQUEST, PROC_REF(incoming_request))
	log_transport("Sub: Registered new transport component [unit_name] [id_tag].")

/datum/controller/subsystem/processing/transport/Recover()
	_listen_lookup = SStransport._listen_lookup

/**
 * Performs the request received from a registered transport device
 *
 * Currently the only supported request type is tram dispatch
 * so there's no var for what type of request it is
 *
 * The subsystem will validate and process, then send a success
 * or fail response to the device that made the request,
 * with info relevant to the request such as destination
 * or error details (if the request is rejected/fails)
 *
 * Arguments: source: the device sending the request
 *            transport_id: the transport this request is for, such as tram line 1 or 2
 *            platform: the requested destination to dispatch the tram
 *            options: additional flags for the request (ie: bypass doors, emagged request)
 */
/datum/controller/subsystem/processing/transport/proc/incoming_request(obj/source, transport_id, platform, options)
	SIGNAL_HANDLER

	log_transport("Sub: Received request from [source.name] [source.id_tag]. Contents: [transport_id] [platform] [options]")
	var/relevant
	var/request_flags = options
	var/datum/transport_controller/linear/tram/transport_controller
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination
	for(var/datum/transport_controller/linear/tram/candidate_controller as anything in transports_by_type[TRANSPORT_TYPE_TRAM])
		if(candidate_controller.specific_transport_id == transport_id)
			transport_controller = candidate_controller
			break

	// We make a list of relevant devices (that should act/respond to this request) for when we send the signal at the end
	LAZYADD(relevant, source)

	// Check for various failure states
	// The transport controller datum is qdel'd
	if(isnull(transport_controller))
		log_transport("Sub: Transport [transport_id] has no controller datum! Someone deleted it or something catastrophic happened.")
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, BROKEN_BEYOND_REPAIR)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [INTERNAL_ERROR]. Info: [SUB_TS_STATUS].")
		return

	// Non operational (such as power loss) or the controls cabinet is missing/destroyed
	if(!transport_controller.controller_operational || !transport_controller.paired_cabinet)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, NOT_IN_SERVICE)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [NOT_IN_SERVICE]. Info: TC-[!transport_controller][!transport_controller.controller_operational][!transport_controller.paired_cabinet].")
		return

	// Someone emergency stopped the tram, or something went wrong and it needs to reset its landmarks.
	if(transport_controller.controller_status & SYSTEM_FAULT || transport_controller.controller_status & EMERGENCY_STOP)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INTERNAL_ERROR)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [INTERNAL_ERROR]. Info: [SUB_TS_STATUS].")
		return

	// Controller is 'active' (not accepting requests right now) someone already pushed button, hit by a rod, etc.
	if(transport_controller.controller_active)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, TRANSPORT_IN_USE)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [TRANSPORT_IN_USE]. Info: [TC_TA_INFO].")
		return

	// We've made it this far, tram is physically fine so let's trip plan
	// This is based on the destination nav beacon, the logical location
	// If Something Happens and the location the controller thinks it's at
	// gets out of sync with it's actual physical location, it can be reset

	// Since players can set the platform ID themselves, make sure it's a valid platform we're aware of
	var/network = LAZYACCESS(nav_beacons, transport_id)
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/potential_destination in network)
		if(potential_destination.platform_code == platform)
			destination = potential_destination
			break

	// The platform in the request doesn't exist (ie: Can't send a tram to East Wing when the map is Birdshot)
	if(!destination)
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INVALID_PLATFORM)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [INVALID_PLATFORM]. Info: RD0.")
		return

	// The controller thinks the tram is already there
	if(transport_controller.idle_platform == destination) //did you even look?
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, NO_CALL_REQUIRED)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [NO_CALL_REQUIRED]. Info: RD1.")
		return

	// Calculate the trip data, which will be stored on the controller datum, passed to the transport modules making up the tram
	// If for some reason the controller can't determine the distance/direction it needs to go, send a failure message
	if(!transport_controller.calculate_route(destination))
		SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_FAIL, INTERNAL_ERROR)
		log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_FAIL] [INTERNAL_ERROR]. Info: NV0.")
		return

	// At this point we're sending the tram somewhere, so send a success response to the devices
	SEND_TRANSPORT_SIGNAL(COMSIG_TRANSPORT_RESPONSE, relevant, REQUEST_SUCCESS, destination.name)
	log_transport("Sub: Sending response to [source.id_tag]. Contents: [REQUEST_SUCCESS] [destination.name].")

	// Since this is a signal and we're done with the request, do the rest async
	INVOKE_ASYNC(src, PROC_REF(dispatch_transport), transport_controller, request_flags)

/**
 * Dispatches the transport on a validated trip
 *
 * The subsystem at this point has confirmed a valid trip
 * Start the transport, wake up machinery running on
 * the subsystem (signals, etc.)
 *
 * Make tram go, basically.
 *
 * Arguments: transport_controller: the transport controller datum we're giving orders to
 *            destination: destination we're sending it to
 *            request_flags: additional flags for the request (ie: bypass doors, emagged request)
 */
/datum/controller/subsystem/processing/transport/proc/dispatch_transport(datum/transport_controller/linear/tram/transport_controller, destination, request_flags)
	log_transport("Sub: Sending dispatch request to [transport_controller.specific_transport_id]. [request_flags ? "Contents: [request_flags]." : "No request flags."]")

	// This will generally be caught in the request validation, however an admin may try to force move the tram, or other actions bypassing the request process.
	if(transport_controller.idle_platform == transport_controller.destination_platform)
		log_transport("Sub: [transport_controller.specific_transport_id] dispatch failed. Info: DE-1 Transport Controller idle and destination are the same.")
		return

	// Set active, so no more requests will be accepted until we're in a safe state to change destination.
	transport_controller.set_active(TRUE)
	pre_departure(transport_controller, request_flags)

/**
 * Pre-departure checks for the tram
 *
 * We do things slighly different based on the request_flags such as
 * door crushing, emag related things
 *
 * Arguments: transport_controller: the transport controller datum we're giving orders to
 *            request_flags: additional flags for the request (ie: bypass doors, emagged request)
 */
/datum/controller/subsystem/processing/transport/proc/pre_departure(datum/transport_controller/linear/tram/transport_controller, request_flags)
	log_transport("Sub: [transport_controller.specific_transport_id] start pre-departure. Info: [SUB_TS_STATUS]")

	// Tram Malfunction event
	if(transport_controller.controller_status & COMM_ERROR)
		request_flags |= BYPASS_SENSORS

	// Lock the physical controls of the tram
	transport_controller.set_status_code(PRE_DEPARTURE, TRUE)
	transport_controller.set_status_code(CONTROLS_LOCKED, TRUE)

	// Tram door actions
	log_transport("Sub: [transport_controller.specific_transport_id] requested door close. Info: [SUB_TS_STATUS].")
	if(request_flags & RAPID_MODE || request_flags & BYPASS_SENSORS || transport_controller.controller_status & BYPASS_SENSORS) // bypass for unsafe, rapid departure
		transport_controller.cycle_doors(CYCLE_CLOSED, BYPASS_DOOR_CHECKS)
		if(request_flags & RAPID_MODE)
			log_transport("Sub: [transport_controller.specific_transport_id] rapid mode enabled, bypassing validation.")
			transport_controller.dispatch_transport()
			return
	else
		transport_controller.set_status_code(DOORS_READY, FALSE)
		transport_controller.cycle_doors(CYCLE_CLOSED)

	addtimer(CALLBACK(src, PROC_REF(validate_and_dispatch), transport_controller), 3 SECONDS)

/**
 * Operational checks, then start moving
 *
 * Some check failures aren't worth halting the tram for, like no blocking the doors forever
 * Crush them instead!
 *
 * Arguments: transport_controller: the transport controller datum we're giving orders to
 *            attempt: how many attempts to start moving we've made
 */
/datum/controller/subsystem/processing/transport/proc/validate_and_dispatch(datum/transport_controller/linear/tram/transport_controller, attempt)
	log_transport("Sub: [transport_controller.specific_transport_id] start pre-departure validation. Attempts: [attempt ? attempt : 0].")
	var/current_attempt
	if(attempt)
		current_attempt = attempt
	else
		current_attempt = 0

	if(current_attempt >= 4)
		log_transport("Sub: [transport_controller.specific_transport_id] pre-departure validation failed, but dispatching tram anyways. Info: [SUB_TS_STATUS].")
		transport_controller.dispatch_transport()
		return

	current_attempt++

	transport_controller.update_status()
	if(!(transport_controller.controller_status & DOORS_READY))
		addtimer(CALLBACK(src, PROC_REF(validate_and_dispatch), transport_controller, current_attempt), 3 SECONDS)
		return
	else

		transport_controller.dispatch_transport()
		log_transport("Sub: [transport_controller.specific_transport_id] pre-departure passed.")

/// Give a list of destinations to the tram controls
/datum/controller/subsystem/processing/transport/proc/detailed_destination_list(specific_transport_id)
	. = list()
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)
