/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/weapon/circuitboard/computer/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland"

/obj/docking_port/mobile/white_ship
	name = "NT Miscellaneous White Ship"
	id = "whiteship"
	roundstart_move = null
	launch_status = UNLAUNCHED

/obj/docking_port/mobile/white_ship/initialize()
	. = ..()
	random_dock()

/obj/docking_port/mobile/white_ship/proc/random_dock()
	var/list/possible_docks = SSshuttle.getPrefixDocks(id)
	for(var/d in possible_docks)
		var/obj/docking_port/stationary/S = d
		var/status = canDock(S)
		if(!(status == SHUTTLE_CAN_DOCK || status == SHUTTLE_ALREADY_DOCKED))
			possible_docks -= S

	if(possible_docks.len)
		dock(pick(possible_docks))
