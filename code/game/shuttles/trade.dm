#define TRADE_SHUTTLE_TRANSIT_DELAY 240
#define TRADE_SHUTTLE_COOLDOWN 200

var/global/datum/shuttle/trade/trade_shuttle = new(starting_area = /area/shuttle/trade/start)

/datum/shuttle/trade
	name = "trade shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_trade)
	cooldown = TRADE_SHUTTLE_COOLDOWN
	transit_delay = TRADE_SHUTTLE_TRANSIT_DELAY - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30
	cooldown = 200
	stable = 0 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	

/datum/shuttle/trade/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/trade/start)
	add_dock(/obj/docking_port/destination/trade/station)

	set_transit_dock(/obj/docking_port/destination/trade/transit)

/obj/machinery/computer/shuttle_control/trade
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED
	machine_flags = EMAGGABLE //No screwtoggle because this computer can't be built

/obj/machinery/computer/shuttle_control/trade/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(trade_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/trade/start
	areaname = "Trade Outpost"

/obj/docking_port/destination/trade/station
	areaname = "NanoTrasen Station"

/obj/docking_port/destination/trade/transit
	areaname = "hyperspace (trade shuttle)"
