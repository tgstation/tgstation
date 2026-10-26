/datum/unit_test/atmos_pressure_tanks
	abstract_type = /datum/unit_test/atmos_pressure_tanks

/// Returns the test room turf offset from the bottom left corner
/datum/unit_test/atmos_pressure_tanks/proc/room_turf(dx, dy)
	return locate(run_loc_floor_bottom_left.x + dx, run_loc_floor_bottom_left.y + dy, run_loc_floor_bottom_left.z)

/// Total moles of gas on the floor of the test room
/datum/unit_test/atmos_pressure_tanks/proc/room_moles()
	. = 0
	for(var/turf/open/floor in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		. += floor.return_air().total_moles()

/// Total moles of gas held by pressure tanks in the test room, counting shared mixes once
/datum/unit_test/atmos_pressure_tanks/proc/tank_moles()
	var/list/mixes = list()
	for(var/turf/floor in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		for(var/obj/machinery/atmospherics/components/tank/tank in floor)
			mixes |= tank.return_analyzable_air()
	. = 0
	for(var/datum/gas_mixture/mix as anything in mixes)
		. += mix.total_moles()

/// Cutting open one tank of a merged group should release only that tank's share, not create gas
/datum/unit_test/atmos_pressure_tanks/tank_deconstruct_conserves_gas

/datum/unit_test/atmos_pressure_tanks/tank_deconstruct_conserves_gas/Run()
	var/list/tanks = list()
	for(var/i in 0 to 2)
		tanks += allocate(/obj/machinery/atmospherics/components/tank/oxygen, room_turf(i, 0))

	var/moles_before = room_moles() + tank_moles()
	var/obj/machinery/atmospherics/components/tank/cut_tank = tanks[3]
	cut_tank.deconstruct(TRUE)
	var/moles_after = room_moles() + tank_moles()

	TEST_ASSERT(abs(moles_after - moles_before) < 1, "Cutting open one of three merged tanks changed the total gas from [moles_before] to [moles_after] moles")

/// Bridging two tank groups with a new empty tank should not create gas
/datum/unit_test/atmos_pressure_tanks/tank_bridge_conserves_gas

/datum/unit_test/atmos_pressure_tanks/tank_bridge_conserves_gas/Run()
	allocate(/obj/machinery/atmospherics/components/tank/oxygen, room_turf(0, 0))
	allocate(/obj/machinery/atmospherics/components/tank/oxygen, room_turf(1, 0))
	allocate(/obj/machinery/atmospherics/components/tank/oxygen, room_turf(3, 0))
	allocate(/obj/machinery/atmospherics/components/tank/oxygen, room_turf(4, 0))

	var/moles_before = tank_moles()
	allocate(/obj/machinery/atmospherics/components/tank, room_turf(2, 0))
	var/moles_after = tank_moles()

	TEST_ASSERT(abs(moles_after - moles_before) < 1, "Joining two tank groups with an empty tank changed the total gas from [moles_before] to [moles_after] moles")
