var/global/datum/shuttle/escape/escape_shuttle = new(starting_area=/area/shuttle/escape/centcom)

/datum/shuttle/escape
	name = "emergency shuttle"

	cant_leave_zlevel = list()

	cooldown = 0 //It's handled by the emergency shuttle controller and doesn't need a cooldown
	transit_delay = 100 //This has NO effect outside of adminbus
	pre_flight_delay = 30 //This has NO effect outside of adminbus

	stable = 0
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	destroy_everything = 1 //Can't stop us

	var/obj/docking_port/destination/dock_centcom
	var/obj/docking_port/destination/dock_station

/datum/shuttle/escape/is_special()
	return 1

/datum/shuttle/escape/initialize()
	.=..()
	dock_station = add_dock(/obj/docking_port/destination/escape/shuttle/station)
	dock_centcom = add_dock(/obj/docking_port/destination/escape/shuttle/centcom)

	set_transit_dock(/obj/docking_port/destination/escape/shuttle/transit)

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/escape/shuttle/station
	areaname = "escape shuttle docking"

/obj/docking_port/destination/escape/shuttle/centcom
	areaname = "central command"

/obj/docking_port/destination/escape/shuttle/transit
	areaname = "hyperspace (emergency shuttle)"

//pods later
/*
/obj/docking_port/destination/escape/pod1/station
	areaname = "escape shuttle docking"

/obj/docking_port/destination/escape/pod1/centcom
	areaname = "central command"
*/