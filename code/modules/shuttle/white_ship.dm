/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/circuitboard/computer/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;whiteship_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship
	name = "White Ship Navigation Computer"
	desc = "Used to designate a precise transit location for the White Ship."
	shuttleId = "whiteship"
	lock_override = NONE
	shuttlePortId = "whiteship_custom"
	shuttlePortName = "Custom Location"
	jumpto_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1)
	view_range = 18
	x_offset = -6
	y_offset = -10
	designate_time = 100

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/Initialize()
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()
