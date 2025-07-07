/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/circuitboard/computer/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_waystation;whiteship_lavaland;whiteship_custom"
	may_be_remote_controlled = TRUE

/// Console used on the whiteship bridge. Comes with GPS pre-baked.
/obj/machinery/computer/shuttle/white_ship/bridge
	name = "White Ship Bridge Console"
	desc = "Used to control the White Ship from the bridge. Emits a faint GPS signal."
	circuit = /obj/item/circuitboard/computer/white_ship/bridge

/obj/machinery/computer/shuttle/white_ship/bridge/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/gps, SPACE_SIGNAL_GPSTAG)

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship
	name = "White Ship Navigation Computer"
	desc = "Used to designate a precise transit location for the White Ship."
	shuttleId = "whiteship"
	lock_override = NONE
	shuttlePortId = "whiteship_custom"
	jump_to_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "whiteship_waystation" = 1)
	view_range = 10
	x_offset = -6
	y_offset = -10
	designate_time = 100

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/Initialize(mapload)
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()
