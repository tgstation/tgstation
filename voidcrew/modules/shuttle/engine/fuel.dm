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

	///The specific gas to burn out of the engine heater. If none, burns any gas.
	var/datum/gas/fuel_type
	///How much fuel (in mols) of the specified gas should be used in a full burn.
	var/fuel_use = 0

/obj/machinery/power/shuttle_engine/ship/fueled/burn_engine(percentage = 100)
	. = ..()
	var/to_use = fuel_use * (percentage / 100)
	return consume_fuel(to_use) / to_use * engine_power //This proc returns how much was actually burned, so let's use that and multiply it by the thrust (engine_power) to get all the thrust we CAN give.

///Returns how much fuel we have left
/obj/machinery/power/shuttle_engine/ship/fueled/return_fuel()
	. = ..()
	var/datum/gas_mixture/air_contents = loc.return_air()
	if(!air_contents)
		return
	return air_contents.return_volume(fuel_type)

///Returns how much fuel we can hold
/obj/machinery/power/shuttle_engine/ship/fueled/return_fuel_cap()
	. = ..()
	var/datum/gas_mixture/air_contents = loc.return_air()
	if(!air_contents)
		return
	return air_contents.return_volume()

///Consumes the needed fuel
/obj/machinery/power/shuttle_engine/ship/fueled/proc/consume_fuel(amount)
	var/datum/gas_mixture/air_contents = loc.return_air()
	if(!air_contents)
		return

	var/starting_amt = air_contents.return_volume(fuel_type)
	air_contents.remove_specific(fuel_type, amount)
	return min(starting_amt, amount)


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
