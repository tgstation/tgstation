var/global/datum/shuttle/supply/cargo_shuttle = new(starting_area = /area/shuttle/supply)

/datum/shuttle/supply
	name = "supply shuttle"

	var/obj/structure/docking_port/destination/dock_centcom
	var/obj/structure/docking_port/destination/dock_station

	pre_flight_delay = 0

	cooldown = 0

	stable = 1 //Don't stun everyone and don't throw anything when moving

/datum/shuttle/supply/is_special()
	return 1

/datum/shuttle/supply/initialize()
	.=..()
	dock_centcom = add_dock(/obj/structure/docking_port/destination/supply/centcom)
	dock_station = add_dock(/obj/structure/docking_port/destination/supply/station)

/obj/structure/docking_port/destination/supply/centcom
	areaname = "centcom loading bay"

/obj/structure/docking_port/destination/supply/station
	areaname = "cargo bay"
