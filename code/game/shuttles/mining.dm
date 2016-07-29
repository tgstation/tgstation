var/global/datum/shuttle/mining/mining_shuttle = new(starting_area = /area/shuttle/mining/station)

/datum/shuttle/mining
	name = "mining shuttle"
	can_link_to_computer = LINK_FREE
	req_access = list(access_mining)

/datum/shuttle/mining/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/mining/station)
	add_dock(/obj/docking_port/destination/mining/outpost)

/obj/machinery/computer/shuttle_control/mining/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(mining_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/mining/station
	areaname = "mining dock"

/obj/docking_port/destination/mining/outpost
	areaname = "mining outpost"
