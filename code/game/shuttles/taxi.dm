#define TAXI_SHUTTLE_MOVE_TIME 0
#define TAXI_SHUTTLE_COOLDOWN 100

#define TAXI_A_NAME "taxi A"
#define TAXI_B_NAME "taxi B"

#define TAXI_A_STARTING_AREA /area/shuttle/taxi_a/engineering_cargo_station
#define TAXI_B_STARTING_AREA /area/shuttle/taxi_b/engineering_cargo_station

var/global/datum/shuttle/taxi/a/taxi_a = new(starting_area = TAXI_A_STARTING_AREA)

var/global/datum/shuttle/taxi/b/taxi_b = new(starting_area = TAXI_B_STARTING_AREA)

/datum/shuttle/taxi
	var/move_time_access = 20
	var/move_time_no_access = 60

	var/obj/docking_port/destination/dock_medical_silicon
	var/obj/docking_port/destination/dock_engineering_cargo
	var/obj/docking_port/destination/dock_security_science
	var/obj/docking_port/destination/dock_abandoned

	collision_type = COLLISION_DISPLACE

	pre_flight_delay = TAXI_SHUTTLE_MOVE_TIME

	transit_delay = 60

	cooldown = TAXI_SHUTTLE_COOLDOWN

	stable = 1 //Don't stun everyone and don't throw anything when moving

/datum/shuttle/taxi/is_special()
	return 1

//TAXI A

/datum/shuttle/taxi/a
	name = TAXI_A_NAME

/datum/shuttle/taxi/a/initialize()
	.=..()
	dock_medical_silicon = add_dock(/obj/docking_port/destination/taxi/a/medbay_silicon)
	dock_engineering_cargo = add_dock(/obj/docking_port/destination/taxi/a/engi_cargo)
	dock_security_science = add_dock(/obj/docking_port/destination/taxi/a/sec_sci)
	dock_abandoned = add_dock(/obj/docking_port/destination/taxi/a/derelict)

	set_transit_dock(/obj/docking_port/destination/taxi/a/transit)

//TAXI B

/datum/shuttle/taxi/b
	name = TAXI_B_NAME

/datum/shuttle/taxi/b/initialize()
	.=..()
	dock_medical_silicon = add_dock(/obj/docking_port/destination/taxi/b/medbay_silicon)
	dock_engineering_cargo = add_dock(/obj/docking_port/destination/taxi/b/engi_cargo)
	dock_security_science = add_dock(/obj/docking_port/destination/taxi/b/sec_sci)
	dock_abandoned = add_dock(/obj/docking_port/destination/taxi/b/derelict)

	set_transit_dock(/obj/docking_port/destination/taxi/b/transit)

//Taxi computers are located in code\game\machinery\computer\taxi_shuttle.dm

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/taxi
	areaname = "taxi"

/obj/docking_port/destination/taxi/a/medbay_silicon
	areaname = "Medical and Silicon Station"

/obj/docking_port/destination/taxi/a/engi_cargo
	areaname = "Engineering and Cargo Station"

/obj/docking_port/destination/taxi/a/sec_sci
	areaname = "Security and Science Station"

/obj/docking_port/destination/taxi/a/derelict
	areaname = "Abandoned Station"

/obj/docking_port/destination/taxi/a/transit
	areaname = "Hyperspace (taxi A)"

/obj/docking_port/destination/taxi/b/medbay_silicon
	areaname = "Medical and Silicon Station"

/obj/docking_port/destination/taxi/b/engi_cargo
	areaname = "Engineering and Cargo Station"

/obj/docking_port/destination/taxi/b/sec_sci
	areaname = "Security and Science Station"

/obj/docking_port/destination/taxi/b/derelict
	areaname = "Abandoned Station"

/obj/docking_port/destination/taxi/b/transit
	areaname = "Hyperspace (taxi B)"

#undef TAXI_A_NAME
#undef TAXI_B_NAME

#undef TAXI_SHUTTLE_MOVE_TIME
#undef TAXI_SHUTTLE_COOLDOWN