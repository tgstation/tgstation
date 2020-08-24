/obj/machinery/computer/shuttle/shipstation
	name = "NTSS 'Companionship' Shuttle Console"
	desc = "Used to control the NTSS 'Companionship'."
	shuttleId = "station"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;station_custom"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/computer/camera_advanced/shuttle_docker/shipstation
	name = "NTSS 'Companionship' Navigation Computer"
	desc = "Used to designate a precise transit location for the NTSS 'Companionship'."
	shuttleId = "station"
	lock_override = NONE
	shuttlePortId = "station_custom"
	jumpto_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "whiteship_lavaland" = 1)
	whitelist_turfs = list(/turf/open/space, /turf/open/floor/plating, /turf/open/lava, /turf/closed/mineral)
	view_range = 12
	designate_time = 50
	x_offset = 9
	y_offset = 9
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
