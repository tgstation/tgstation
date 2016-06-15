#define SYNDICATE_SHUTTLE_TRANSIT_DELAY 240
#define SYNDICATE_SHUTTLE_COOLDOWN 200

var/global/datum/shuttle/syndicate/syndicate_shuttle = new(starting_area = /area/syndicate_station/start)

/datum/shuttle/syndicate
	name = "syndicate shuttle"

	cant_leave_zlevel = list() //Nuke disk is allowed

	cooldown = SYNDICATE_SHUTTLE_COOLDOWN

	transit_delay = SYNDICATE_SHUTTLE_TRANSIT_DELAY - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	cooldown = 200

	stable = 1 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	req_access = list(access_syndicate)

/datum/shuttle/syndicate/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/syndicate/start)
	add_dock(/obj/docking_port/destination/syndicate/northwest)
	add_dock(/obj/docking_port/destination/syndicate/northeast)
	add_dock(/obj/docking_port/destination/syndicate/southwest)
	add_dock(/obj/docking_port/destination/syndicate/south)
	add_dock(/obj/docking_port/destination/syndicate/southeast)
	add_dock(/obj/docking_port/destination/syndicate/commssat)
	add_dock(/obj/docking_port/destination/syndicate/mining)

	set_transit_dock(/obj/docking_port/destination/syndicate/transit)

/obj/machinery/computer/shuttle_control/syndicate
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED
	machine_flags = EMAGGABLE //No screwtoggle because this computer can't be built

/obj/machinery/computer/shuttle_control/syndicate/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(syndicate_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/syndicate/start
	areaname = "syndicate outpost"

/obj/docking_port/destination/syndicate/northwest
	areaname = "north west of the station"

/obj/docking_port/destination/syndicate/north
	areaname = "north of the station"

/obj/docking_port/destination/syndicate/northeast
	areaname = "north east of the station"

/obj/docking_port/destination/syndicate/southwest
	areaname = "south west of the station"

/obj/docking_port/destination/syndicate/south
	areaname = "south of the station"

/obj/docking_port/destination/syndicate/southeast
	areaname = "south east of the station"

/obj/docking_port/destination/syndicate/commssat
	areaname = "south of the Communications Satellite"

/obj/docking_port/destination/syndicate/mining
	areaname = "north east of the mining asteroid"

/obj/docking_port/destination/syndicate/transit
	areaname = "hyperspace (syndicate shuttle)"
