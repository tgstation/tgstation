/**
  * ### Fueled engines
  * Shuttle engines that require a gas or gases to burn.
  */
/obj/machinery/power/shuttle_engine/ship/fueled
	name = "fueled thruster"
	desc = "A thruster that burns a specific gas that is stored in an adjacent heater."
	icon_state = "burst_plasma"
	idle_power_usage = NONE

	icon_state_off = "burst_plasma_off"

	///The specific gas to burn out of the engine heater.
	var/datum/gas/fuel_type
	///How much fuel (in mols) of the specified gas should be used in a full burn.
	var/fuel_use = 0

	var/obj/machinery/atmospherics/fueled_engine_heater/connected_heater

/obj/machinery/power/shuttle_engine/ship/fueled/proc/try_link_heater()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(connected_heater)
		return

	var/turf/candidate_turf = get_step(src, dir)
	var/obj/machinery/atmospherics/fueled_engine_heater/candidate_heater = locate() in candidate_turf
	if(!candidate_heater || candidate_heater.dir != turn(dir, 180))
		return
	on_heater_link(candidate_heater)

/// Called when the engine is linked to a heater; must call parent first.
/obj/machinery/power/shuttle_engine/ship/fueled/proc/on_heater_link(obj/machinery/atmospherics/fueled_engine_heater/connecting)
	SHOULD_CALL_PARENT(TRUE)
	if(connected_heater == connecting)
		return
	if(connected_heater)
		on_heater_unlink()

	connected_heater = connecting
	connected_heater.connected_engine = src

/// Called when the engine is unlinked from a heater; must call parent first.
/obj/machinery/power/shuttle_engine/ship/fueled/proc/on_heater_unlink()
	SHOULD_CALL_PARENT(TRUE)
	if(!connected_heater)
		return

	connected_heater.connected_engine = null
	connected_heater = null

/obj/machinery/power/shuttle_engine/ship/fueled/LateInitialize()
	. = ..()
	try_link_heater()

/obj/machinery/power/shuttle_engine/ship/fueled/Destroy()
	if(connected_heater)
		on_heater_unlink()
	return ..()

/obj/machinery/power/shuttle_engine/ship/fueled/burn_engine(percentage = 100)
	. = ..()
	var/to_use = fuel_use * (percentage / 100)
	return consume_fuel(to_use) / to_use * engine_power //This proc returns how much was actually burned, so let's use that and multiply it by the thrust (engine_power) to get all the thrust we CAN give.

///Returns how much fuel we have left
/obj/machinery/power/shuttle_engine/ship/fueled/return_fuel()
	if(fuel_type)
		connected_heater.air_contents.assert_gas(fuel_type)
		return connected_heater?.air_contents.gases[fuel_type][MOLES] || 0
	return connected_heater?.air_contents.total_moles() || 0

///Returns how much fuel we can hold
/obj/machinery/power/shuttle_engine/ship/fueled/return_fuel_cap()
	return connected_heater.maximum_moles

///Consumes the needed fuel
/obj/machinery/power/shuttle_engine/ship/fueled/proc/consume_fuel(amount)
	if(!connected_heater?.air_contents)
		return 0

	if(fuel_type)
		connected_heater.air_contents.assert_gas(fuel_type)
		var/avail_moles = connected_heater.air_contents.gases[fuel_type][MOLES]
		. = min(amount, avail_moles)
		connected_heater.air_contents.remove_specific(fuel_type, .)
	else
		var/avail_moles = connected_heater.air_contents.total_moles()
		. = min(amount, avail_moles)
		connected_heater.air_contents.remove(.)

///Plasma
/obj/machinery/power/shuttle_engine/ship/fueled/plasma
	name = "plasma thruster"
	desc = "A thruster that burns plasma from an adjacent heater to create thrust."
	circuit = /obj/item/circuitboard/machine/engine/plasma
	fuel_type = /datum/gas/plasma
	fuel_use = 20
	engine_power = 25

///CO2
/obj/machinery/power/shuttle_engine/ship/fueled/expulsion
	name = "expulsion thruster"
	desc = "A thruster that expels carbon dioxide inefficiently to create thrust."
	circuit = /obj/item/circuitboard/machine/engine/expulsion
	fuel_type = /datum/gas/carbon_dioxide
	fuel_use = 80
	engine_power = 15
