//Other shuttles which are less-used or not used at all go here

//ARRIVALS SHUTTLE
var/global/datum/shuttle/arrival/arrival_shuttle = new(starting_area = /area/shuttle/arrival/station)

/datum/shuttle/arrival
	name = "arrival shuttle"

	cant_leave_zlevel = list() //It's only adminbusable anyways

	cooldown = 0

	stable = 1

/datum/shuttle/arrival/initialize()
	.=..()
	add_dock(/obj/structure/docking_port/destination/arrival/station)

//code/game/objects/structures/docking_port.dm

/obj/structure/docking_port/destination/arrival/station
	areaname = "station arrivals"


//TRANSPORT SHUTTLE
var/global/datum/shuttle/transport/transport_shuttle = new(starting_area = /area/shuttle/transport1/centcom)

/datum/shuttle/transport
	name = "centcom ferry"

	cant_leave_zlevel = list() //Bus

	cooldown = 0
	pre_flight_delay = 0
	transit_delay = 0

	stable = 1

	req_access = list(access_cent_captain)

/datum/shuttle/transport/initialize()
	.=..()
	add_dock(/obj/structure/docking_port/destination/transport/station)
	add_dock(/obj/structure/docking_port/destination/transport/centcom)

/obj/machinery/computer/shuttle_control/transport
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0

/obj/machinery/computer/shuttle_control/transport/New()
	link_to(transport_shuttle)
	.=..()

/obj/machinery/computer/shuttle_control/transport/emag() //Can't be emagged to hijack the centcom ferry
	return

//code/game/objects/structures/docking_port.dm

/obj/structure/docking_port/destination/transport/station
	areaname = "station arrivals (docking port 1)"

/obj/structure/docking_port/destination/transport/centcom
	areaname = "central command"


//ADMIN SHUTTLE
var/global/datum/shuttle/admin/admin_shuttle = new(starting_area = /area/shuttle/administration/centcom)
/datum/shuttle/admin
	name = "admin shuttle"

	cant_leave_zlevel = list() //Bus

	cooldown = 0
	pre_flight_delay = 0
	transit_delay = 0

	stable = 1

	req_access = list(access_cent_captain)

/datum/shuttle/admin/initialize()
	.=..()
	add_dock(/obj/structure/docking_port/destination/admin/centcom)
	add_dock(/obj/structure/docking_port/destination/salvage/arrivals) //We share a docking port with the salvage shuttle - this should turn out fine

/obj/structure/docking_port/destination/admin/centcom
	areaname = "centcom hangar bay"

/obj/machinery/computer/shuttle_control/admin_shuttle
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0

/obj/machinery/computer/shuttle_control/admin_shuttle/New()
	link_to(admin_shuttle)
	.=..()

/obj/machinery/computer/shuttle_control/admin_shuttle/emag() //Can't be emagged to hijack the centcom ferry
	return
