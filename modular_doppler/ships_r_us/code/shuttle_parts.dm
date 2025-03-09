/area/shuttle/personally_bought
	name = "Personal Shuttle Debug Area"
	requires_power = TRUE
	area_limited_icon_smoothing = /area/shuttle/personally_bought
	// Ambience brought to you by the nri shuttle, thanks guys
	ambient_buzz = 'modular_doppler/ships_r_us/sound/amb_ship_01.ogg'
	ambient_buzz_vol = 50
	ambientsounds = list(
		'modular_doppler/ships_r_us/sound/alarm_radio.ogg',
		'modular_doppler/ships_r_us/sound/gear_loop.ogg',
		'modular_doppler/ships_r_us/sound/gear_start.ogg',
		'modular_doppler/ships_r_us/sound/gear_stop.ogg',
		'modular_doppler/ships_r_us/sound/intercom_loop.ogg',
	)
	min_ambience_cooldown = 10 SECONDS
	max_ambience_cooldown = 30 SECONDS

/obj/docking_port/mobile/personally_bought
	name = "personal shuttle"
	shuttle_id = "shuttle_personal"
	callTime = 15 SECONDS
	rechargeTime = 30 SECONDS
	prearrivalTime = 5 SECONDS
	preferred_direction = EAST
	dir = NORTH
	port_direction = EAST
	movement_force = list(
		"KNOCKDOWN" = 2,
		"THROW" = 0,
	)

/obj/docking_port/mobile/personally_bought/canDock(obj/docking_port/stationary/stationary_dock)
	if(!stationary_dock)
		return SHUTTLE_CAN_DOCK

	if(!istype(stationary_dock))
		return SHUTTLE_NOT_A_DOCKING_PORT

	if(stationary_dock.override_can_dock_checks)
		return SHUTTLE_CAN_DOCK

	/*
	if(dwidth > stationary_dock.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE

	if(width-dwidth > stationary_dock.width-stationary_dock.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE

	if(dheight > stationary_dock.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE

	if(height-dheight > stationary_dock.height-stationary_dock.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE
	*/

	//check the dock isn't occupied
	var/currently_docked = stationary_dock.get_docked()
	if(currently_docked)
		// by someone other than us
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
		// This isn't an error, per se, but we can't let the shuttle code
		// attempt to move us where we currently are, it will get weird.
			return SHUTTLE_ALREADY_DOCKED

	return SHUTTLE_CAN_DOCK

/obj/item/circuitboard/computer/personally_bought
	name = "Personal Ship Console"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/computer/shuttle/personally_bought

/obj/machinery/computer/shuttle/personally_bought
	name = "Personal Ship Console"
	desc = "Used to control the ship its currently in, ideally."
	circuit = /obj/item/circuitboard/computer/personally_bought
	shuttleId = "shuttle_personal"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_waystation;whiteship_lavaland;personal_ship_custom;monestary_dock"
	/// What our GPS tag name is
	var/shuttle_gps_tag = "Shuttle Homing Beacon"

/obj/machinery/computer/shuttle/personally_bought/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/gps, shuttle_gps_tag)

/obj/machinery/computer/shuttle/personally_bought/get_valid_destinations()
	var/list/destination_list = params2list(possible_destinations)
	var/obj/docking_port/mobile/mobile_docking_port = SSshuttle.getShuttle(shuttleId)
	var/obj/docking_port/stationary/current_destination = mobile_docking_port.destination
	var/list/valid_destinations = list()
	for(var/obj/docking_port/stationary/stationary_docking_port in SSshuttle.stationary_docking_ports)
		if(!destination_list.Find(stationary_docking_port.port_destinations))
			continue
		if(!mobile_docking_port.check_dock(stationary_docking_port, silent = TRUE))
			continue
		if(stationary_docking_port == current_destination)
			continue
		var/list/location_data = list(
			id = stationary_docking_port.shuttle_id,
			name = stationary_docking_port.name
		)
		valid_destinations += list(location_data)
	var/list/null_location_data = list( // DOPPLER ADDITION START
		id = "infinite_transit_super_hell",
		name = "Infinite Transit",
	)
	valid_destinations += list(null_location_data) // DOPPLER ADDITION END
	return valid_destinations

/obj/machinery/computer/shuttle/personally_bought/mothership
	name = "Mothership Control Console"
	desc = "Used to control the ship its currently in, ideally."
	circuit = /obj/item/circuitboard/computer/personally_bought
	shuttleId = "shuttle_personal"
	possible_destinations = "whiteship_away;mothership_home;whiteship_z4;whiteship_waystation;whiteship_lavaland;personal_ship_custom"
	shuttle_gps_tag = "Mothership Homing Beacon"

/obj/machinery/computer/camera_advanced/shuttle_docker/personally_bought
	name = "Personal Ship Navigation Computer"
	desc = "Used to designate a precise transit location for the ship its currently in, ideally."
	shuttleId = "shuttle_personal"
	lock_override = NONE
	shuttlePortId = "personal_ship_custom"
	jump_to_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "whiteship_waystation" = 1, "monestary_dock" = 1)
	designate_time = 5 SECONDS

/obj/machinery/computer/camera_advanced/shuttle_docker/personally_bought/mothership
	name = "Mothership Navigation Computer"
	desc = "Used to designate a precise transit location for the ship its currently in, ideally."
	shuttleId = "shuttle_personal"
	lock_override = NONE
	shuttlePortId = "personal_ship_custom"
	jump_to_ports = list("whiteship_away" = 1, "mothership_home" = 1, "whiteship_z4" = 1, "whiteship_waystation" = 1)
	designate_time = 10 SECONDS

// Decorative parts for the ships

/obj/structure/railing/eva_handhold
	name = "EVA handrail"
	desc = "Basic handrailing meant to keep idiots like you from floating off into space."
	icon = 'modular_doppler/ships_r_us/icons/ship_items.dmi'
	icon_state = "eva_rail"
	max_integrity = 50

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/railing/eva_handhold, 17)

// Buttons and blast doors galore

// Exterior windows

/obj/machinery/button/door/personal_shuttle_windows
	name = "Exterior Window Shutter Control"
	id = "personal_shuttle_ext_window"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/door/personal_shuttle_windows, 28)

/obj/machinery/door/poddoor/preopen/personal_shuttle_windows
	id = "personal_shuttle_ext_window"

// Cargo bays/hangars, one through four

// Bay one

/obj/machinery/button/door/personal_shuttle_bay_one
	name = "Bay 1 External Shutter Control"
	id = "personal_shuttle_bay_one"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/door/personal_shuttle_bay_one, 28)

/obj/machinery/door/poddoor/preopen/personal_bay_one
	id = "personal_shuttle_bay_one"

// Bay two

/obj/machinery/button/door/personal_shuttle_bay_two
	name = "Bay 2 External Shutter Control"
	id = "personal_shuttle_bay_two"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/door/personal_shuttle_bay_two, 28)

/obj/machinery/door/poddoor/preopen/personal_bay_two
	id = "personal_shuttle_bay_two"

// Bay three

/obj/machinery/button/door/personal_shuttle_bay_three
	name = "Bay 3 External Shutter Control"
	id = "personal_shuttle_bay_three"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/door/personal_shuttle_bay_three, 28)

/obj/machinery/door/poddoor/preopen/personal_bay_three
	id = "personal_shuttle_bay_three"

// Bay four

/obj/machinery/button/door/personal_shuttle_bay_four
	name = "Bay 4 External Shutter Control"
	id = "personal_shuttle_bay_four"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/door/personal_shuttle_bay_four, 28)

/obj/machinery/door/poddoor/preopen/personal_bay_four
	id = "personal_shuttle_bay_four"

// Suit storage unit for a free emergency eva suit

/obj/machinery/suit_storage_unit/industrial/personal_shuttle
	mask_type = /obj/item/clothing/mask/gas/atmos/frontier_colonist
	mod_type = /obj/item/mod/control/pre_equipped/frontier_colonist
	storage_type = /obj/item/tank/internals/oxygen/yellow
