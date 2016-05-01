var/global/datum/shuttle/voxresearch/voxresearch_shuttle = new(starting_area = /area/shuttle/voxresearch/station)

/datum/shuttle/voxresearch
	name = "Research Shuttle"
	can_link_to_computer = LINK_FREE
	req_access = 0

/datum/shuttle/voxresearch/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/voxresearch/station)
	add_dock(/obj/docking_port/destination/voxresearch/outpost)

/obj/machinery/computer/shuttle_control/voxresearch/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(voxresearch_shuttle)
	.=..()

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/voxresearch/station
	areaname = "Genetic Research Station"

/obj/docking_port/destination/voxresearch/outpost
	areaname = "Asteroid"