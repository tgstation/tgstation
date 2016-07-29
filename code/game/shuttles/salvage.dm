#define SALVAGE_SHIP_MOVE_TIME 300
#define SALVAGE_SHIP_COOLDOWN 800

var/global/datum/shuttle/salvage/salvage_shuttle = new(starting_area=/area/shuttle/salvage/start)

/datum/shuttle/salvage
	name = "salvage shuttle"

	cooldown = SALVAGE_SHIP_COOLDOWN

	transit_delay = SALVAGE_SHIP_MOVE_TIME - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	can_link_to_computer = LINK_PASSWORD_ONLY

	stable = 1 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	req_access = list(access_salvage_captain)

/datum/shuttle/salvage/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/salvage/start)
	add_dock(/obj/docking_port/destination/salvage/arrivals)
	add_dock(/obj/docking_port/destination/salvage/north)
	add_dock(/obj/docking_port/destination/salvage/east)
	add_dock(/obj/docking_port/destination/salvage/south)
	add_dock(/obj/docking_port/destination/salvage/mining)
	add_dock(/obj/docking_port/destination/salvage/trading_post)
	add_dock(/obj/docking_port/destination/salvage/clown)
	add_dock(/obj/docking_port/destination/salvage/derelict)
	add_dock(/obj/docking_port/destination/salvage/dj)
	add_dock(/obj/docking_port/destination/salvage/commssat)
	add_dock(/obj/docking_port/destination/salvage/abandoned_ship)

	set_transit_dock(/obj/docking_port/destination/salvage/transit)

/obj/machinery/computer/shuttle_control/salvage
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/shuttle_control/salvage/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(salvage_shuttle)
	var/obj/item/weapon/paper/manual = new(get_turf(src))

	manual.name = "Salvage Shuttle manual"
	manual.info = "Thank you for purchasing the ShuttleTec Salvage Shuttle!<hr>This shuttle's password is: \"<b>[salvage_shuttle.password]</b>\"."
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/salvage/start
	areaname = "deep space"

/obj/docking_port/destination/salvage/arrivals
	areaname = "station auxillary docking"

/obj/docking_port/destination/salvage/north
	areaname = "north of the station"

/obj/docking_port/destination/salvage/east
	areaname = "east of the station"

/obj/docking_port/destination/salvage/south
	areaname = "south of the station"

/obj/docking_port/destination/salvage/mining
	areaname = "south-west of the mining asteroid"

/obj/docking_port/destination/salvage/trading_post
	areaname = "trading post"

/obj/docking_port/destination/salvage/clown
	areaname = "clown asteroid"

/obj/docking_port/destination/salvage/derelict
	areaname = "derelict station"

/obj/docking_port/destination/salvage/dj
	areaname = "ruskie DJ station"

/obj/docking_port/destination/salvage/commssat
	areaname = "communications satellite"

/obj/docking_port/destination/salvage/abandoned_ship
	areaname = "abandoned ship"

/obj/docking_port/destination/salvage/transit
	areaname = "hyperspace (salvage shuttle)"

#undef SALVAGE_SHIP_MOVE_TIME
#undef SALVAGE_SHIP_COOLDOWN