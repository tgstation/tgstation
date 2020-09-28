#define SOURCE_TO_TARGET 0
#define TARGET_TO_SOURCE 1
#define PUMP_EFFICIENCY 0.6
#define TANK_FAILURE_PRESSURE (ONE_ATMOSPHERE*25)
#define PUMP_MAX_PRESSURE (ONE_ATMOSPHERE*24)
#define PUMP_MAX_VOLUME 100


/obj/item/integrated_circuit/atmospherics
	category_text = "Atmospherics"
	cooldown_per_use = 2 SECONDS
	complexity = 10
	size = 7
	outputs = list(
		"self reference" = IC_PINTYPE_SELFREF,
		"pressure" = IC_PINTYPE_NUMBER
			)
	var/datum/gas_mixture/air_contents
	var/volume = 2 //Pretty small, I know

/obj/item/integrated_circuit/atmospherics/Initialize()
	air_contents = new(volume)
	..()

/obj/item/integrated_circuit/atmospherics/return_air()
	return air_contents

//Check if the gas container is adjacent and of the right type
/obj/item/integrated_circuit/atmospherics/proc/check_gassource(atom/gasholder)
	if(!gasholder)
		return FALSE
	if(!gasholder.Adjacent(get_object()))
		return FALSE
	if(!istype(gasholder, /obj/item/tank) && !istype(gasholder, /obj/machinery/portable_atmospherics) && !istype(gasholder, /obj/item/integrated_circuit/atmospherics))
		return FALSE
	return TRUE

//Needed in circuits where source and target types differ
/obj/item/integrated_circuit/atmospherics/proc/check_gastarget(atom/gasholder)
	return check_gassource(gasholder)


// - gas pump - // **works**
/obj/item/integrated_circuit/atmospherics/pump
	name = "gas pump"
	desc = "Somehow moves gases between two tanks, canisters, and other gas containers."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"target" = IC_PINTYPE_REF,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"transfer" = IC_PINTYPE_PULSE_IN,
			"on transfer" = IC_PINTYPE_PULSE_OUT
			)
	var/direction = SOURCE_TO_TARGET
	var/target_pressure = PUMP_MAX_PRESSURE
	power_draw_per_use = 20

/obj/item/integrated_circuit/atmospherics/pump/Initialize()
	air_contents = new(volume)
	extended_desc += " Use negative pressure to move air from target to source. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure. \
					The pressure limit for circuit pumps is [round(PUMP_MAX_PRESSURE)] kPa."
	. = ..()

// This proc gets the direction of the gas flow depending on its value, by calling update target
/obj/item/integrated_circuit/atmospherics/pump/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 3)
	update_target(amt)

/obj/item/integrated_circuit/atmospherics/pump/proc/update_target(new_amount)
	if(!isnum(new_amount))
		new_amount = 0
	// See in which direction the gas moves
	if(new_amount < 0)
		direction = TARGET_TO_SOURCE
	else
		direction = SOURCE_TO_TARGET
	target_pressure = min(round(PUMP_MAX_PRESSURE),abs(new_amount))

/obj/item/integrated_circuit/atmospherics/pump/do_work()
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 2, /obj)
	perform_magic(source, target)
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/proc/perform_magic(atom/source, atom/target)
	//Check if both atoms are of the right type: atmos circuits/gas tanks/canisters. If one is the same, use the circuit var
	if(!check_gassource(source))
		source = src

	if(!check_gastarget(target))
		target = src

	// If both are the same, this whole proc would do nothing and just waste performance
	if(source == target)
		return

	var/datum/gas_mixture/source_air = source.return_air()
	var/datum/gas_mixture/target_air = target.return_air()

	if(!source_air || !target_air)
		return

	// Swapping both source and target
	if(direction == TARGET_TO_SOURCE)
		var/temp = source_air
		source_air = target_air
		target_air = temp

	// If what you are pumping is empty, use the circuit's storage
	if(source_air.total_moles() <= 0)
		source_air = air_contents

	// Move gas from one place to another
	move_gas(source_air, target_air)
	air_update_turf()

/obj/item/integrated_circuit/atmospherics/pump/proc/move_gas(datum/gas_mixture/source_air, datum/gas_mixture/target_air)

	// No moles = nothing to pump
	if(source_air.total_moles() <= 0  || target_air.return_pressure() >= PUMP_MAX_PRESSURE)
		return

	// Negative Kelvin temperatures should never happen and if they do, normalize them
	if(source_air.temperature < TCMB)
		source_air.temperature = TCMB

	var/pressure_delta = target_pressure - target_air.return_pressure()
	if(pressure_delta > 0.1)
		var/transfer_moles = (pressure_delta*target_air.volume/(source_air.temperature * R_IDEAL_GAS_EQUATION))*PUMP_EFFICIENCY
		var/datum/gas_mixture/removed = source_air.remove(transfer_moles)
		target_air.merge(removed)


// - volume pump - // **Works**
/obj/item/integrated_circuit/atmospherics/pump/volume
	name = "volume pump"
	desc = "Moves gases between two tanks, canisters, and other gas containers by using their volume, up to 200 L/s."
	extended_desc = " Use negative volume to move air from target to source. Note that only part of the gas is moved on each transfer. Its maximum pumping volume is capped at 1000kPa."

	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"target" = IC_PINTYPE_REF,
			"transfer volume" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"transfer" = IC_PINTYPE_PULSE_IN,
			"on transfer" = IC_PINTYPE_PULSE_OUT
			)
	direction = SOURCE_TO_TARGET
	var/transfer_rate = PUMP_MAX_VOLUME
	power_draw_per_use = 20

/obj/item/integrated_circuit/atmospherics/pump/volume/update_target(new_amount)
	if(!isnum(new_amount))
		new_amount = 0
	// See in which direction the gas moves
	if(new_amount < 0)
		direction = TARGET_TO_SOURCE
	else
		direction = SOURCE_TO_TARGET
	target_pressure = min(PUMP_MAX_VOLUME,abs(new_amount))

/obj/item/integrated_circuit/atmospherics/pump/volume/move_gas(datum/gas_mixture/source_air, datum/gas_mixture/target_air)
	// No moles = nothing to pump
	if(source_air.total_moles() <= 0)
		return

	// Negative Kelvin temperatures should never happen and if they do, normalize them
	if(source_air.temperature < TCMB)
		source_air.temperature = TCMB

	if((source_air.return_pressure() < 0.01) || (target_air.return_pressure() >= PUMP_MAX_PRESSURE))
		return

	//The second part of the min caps the pressure built by the volume pumps to the max pump pressure
	var/transfer_ratio = min(transfer_rate,target_air.volume*PUMP_MAX_PRESSURE/source_air.return_pressure())/source_air.volume

	var/datum/gas_mixture/removed = source_air.remove_ratio(transfer_ratio * PUMP_EFFICIENCY)

	target_air.merge(removed)


// - gas vent - // **works**
/obj/item/integrated_circuit/atmospherics/pump/vent
	name = "gas vent"
	extended_desc = "Use negative volume to move air from target to environment. Note that only part of the gas is moved on each transfer. Unlike the gas pump, this one keeps pumping even further to pressures of 9000 pKa and it is not advised to use it on tank circuits."
	desc = "Moves gases between the environment and adjacent gas containers."
	inputs = list(
			"container" = IC_PINTYPE_REF,
			"target pressure" = IC_PINTYPE_NUMBER
			)

/obj/item/integrated_circuit/atmospherics/pump/vent/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 2)
	update_target(amt)

/obj/item/integrated_circuit/atmospherics/pump/vent/do_work()
	var/turf/source = get_turf(src)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 1, /obj)
	perform_magic(source, target)
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/vent/check_gastarget(atom/gasholder)
	if(!gasholder)
		return FALSE
	if(!gasholder.Adjacent(get_object()))
		return FALSE
	if(!istype(gasholder, /obj/item/tank) && !istype(gasholder, /obj/machinery/portable_atmospherics) && !istype(gasholder, /obj/item/integrated_circuit/atmospherics))
		return FALSE
	return TRUE


/obj/item/integrated_circuit/atmospherics/pump/vent/check_gassource(atom/target)
	if(!target)
		return FALSE
	if(!istype(target, /turf))
		return FALSE
	return TRUE


// - integrated connector - // Can connect and disconnect properly
/obj/item/integrated_circuit/atmospherics/connector
	name = "integrated connector"
	desc = "Creates an airtight seal with standard connectors found on the floor, \
		 	allowing the assembly to exchange gases with a pipe network."
	extended_desc = "This circuit will automatically attempt to locate and connect to ports on the floor beneath it when activated. \
					You <b>must</b> set a target before connecting."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"target" = IC_PINTYPE_REF
			)
	activators = list(
			"toggle connection" = IC_PINTYPE_PULSE_IN,
			"on connected" = IC_PINTYPE_PULSE_OUT,
			"on connection failed" = IC_PINTYPE_PULSE_OUT,
			"on disconnected" = IC_PINTYPE_PULSE_OUT
			)

	var/obj/machinery/atmospherics/components/unary/portables_connector/connector

/obj/item/integrated_circuit/atmospherics/connector/Initialize()
	air_contents = new(volume)
	START_PROCESSING(SSobj, src)
	. = ..()

//Sucks up the gas from the connector
/obj/item/integrated_circuit/atmospherics/connector/process()
	set_pin_data(IC_OUTPUT, 2, air_contents.return_pressure())

/obj/item/integrated_circuit/atmospherics/connector/check_gassource(atom/gasholder)
	if(!gasholder)
		return FALSE
	if(!istype(gasholder,/obj/machinery/atmospherics/components/unary/portables_connector))
		return FALSE
	return TRUE

//If the assembly containing this is moved from the tile the connector pipe is in, the connection breaks
/obj/item/integrated_circuit/atmospherics/connector/ext_moved()
	if(connector)
		if(get_dist(get_object(), connector) > 0)
			// The assembly is set as connected device and the connector handles the rest
			connector.connected_device = null
			connector = null
			activate_pin(4)

/obj/item/integrated_circuit/atmospherics/connector/do_work()
	// If there is a connection, disconnect
	if(connector)
		connector.connected_device = null
		connector = null
		activate_pin(4)
		return

	var/obj/machinery/atmospherics/components/unary/portables_connector/PC = locate() in get_turf(src)
	// If no connector can't connect
	if(!PC)
		activate_pin(3)
		return
	connector = PC
	connector.connected_device = src
	activate_pin(2)

// Required for making the connector port script work
obj/item/integrated_circuit/atmospherics/connector/portableConnectorReturnAir()
	return air_contents


// - gas filter - // **works**
/obj/item/integrated_circuit/atmospherics/pump/filter
	name = "gas filter"
	desc = "Filters one gas out of a mixture."
	complexity = 20
	size = 8
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"filtered output" = IC_PINTYPE_REF,
			"contaminants output" = IC_PINTYPE_REF,
			"wanted gases" = IC_PINTYPE_LIST,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	power_draw_per_use = 30

/obj/item/integrated_circuit/atmospherics/pump/filter/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 5)
	target_pressure = CLAMP(amt, 0, PUMP_MAX_PRESSURE)

/obj/item/integrated_circuit/atmospherics/pump/filter/do_work()
	activate_pin(2)
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/filtered = get_pin_data_as_type(IC_INPUT, 2, /obj)
	var/obj/contaminants = get_pin_data_as_type(IC_INPUT, 3, /obj)

	var/wanted = get_pin_data(IC_INPUT, 4)

	// If there is no filtered output, this whole thing makes no sense
	if(!check_gassource(filtered))
		return

	var/datum/gas_mixture/filtered_air = filtered.return_air()
	if(!filtered_air)
		return

	// If no source is set, the source is possibly this circuit's content
	if(!check_gassource(source))
		source = src
	var/datum/gas_mixture/source_air = source.return_air()

	//No source air: source is this circuit
	if(!source_air)
		source_air = air_contents

	// If no filtering tank is set, filter through itself
	if(!check_gassource(contaminants))
		contaminants = src
	var/datum/gas_mixture/contaminated_air = contaminants.return_air()

	//If there is no gas mixture datum for unfiltered, pump the contaminants back into the circuit
	if(!contaminated_air)
		contaminated_air = air_contents

	if(contaminated_air.return_pressure() >= PUMP_MAX_PRESSURE || filtered_air.return_pressure() >= PUMP_MAX_PRESSURE)
		return

	var/pressure_delta = target_pressure - contaminated_air.return_pressure()
	var/transfer_moles

	//Negative Kelvins are an anomaly and should be normalized if encountered
	if(source_air.temperature < TCMB)
		source_air.temperature = TCMB

	transfer_moles = (pressure_delta*contaminated_air.volume/(source_air.temperature * R_IDEAL_GAS_EQUATION))*PUMP_EFFICIENCY

	//If there is nothing to transfer, just return
	if(transfer_moles <= 0)
		return

	//This is the var that holds the currently filtered part of the gas
	var/datum/gas_mixture/removed = source_air.remove(transfer_moles)
	if(!removed)
		return

	//This is the gas that will be moved from source to filtered
	var/datum/gas_mixture/filtered_out = new

	for(var/filtered_gas in removed.gases)
		//Get the name of the gas and see if it is in the list
		if(removed.gases[filtered_gas][GAS_META][META_GAS_NAME] in wanted)
			//The gas that is put in all the filtered out gases
			filtered_out.temperature = removed.temperature
			filtered_out.add_gas(filtered_gas)
			filtered_out.gases[filtered_gas][MOLES] = removed.gases[filtered_gas][MOLES]

			//The filtered out gas is entirely removed from the currently filtered gases
			removed.gases[filtered_gas][MOLES] = 0
			removed.garbage_collect()

	//Check if the pressure is high enough to put stuff in filtered, or else just put it back in the source
	var/datum/gas_mixture/target = (filtered_air.return_pressure() < target_pressure ? filtered_air : source_air)
	target.merge(filtered_out)
	contaminated_air.merge(removed)


/obj/item/integrated_circuit/atmospherics/pump/filter/Initialize()
	air_contents = new(volume)
	. = ..()
	extended_desc = "Remember to properly spell and capitalize the filtered gas name. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure. \
					The pressure limit for circuit pumps is [round(PUMP_MAX_PRESSURE)] kPa."


// - gas mixer - // **works**
/obj/item/integrated_circuit/atmospherics/pump/mixer
	name = "gas mixer"
	desc = "Mixes 2 different types of gases."
	complexity = 20
	size = 8
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
			"first source" = IC_PINTYPE_REF,
			"second source" = IC_PINTYPE_REF,
			"output" = IC_PINTYPE_REF,
			"first source percentage" = IC_PINTYPE_NUMBER,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	power_draw_per_use = 30

/obj/item/integrated_circuit/atmospherics/pump/mixer/do_work()
	activate_pin(2)
	var/obj/source_1 = get_pin_data(IC_INPUT, 1)
	var/obj/source_2 = get_pin_data(IC_INPUT, 2)
	var/obj/gas_output = get_pin_data(IC_INPUT, 3)
	if(!check_gassource(source_1))
		source_1 = src

	if(!check_gassource(source_2))
		source_2 = src

	if(!check_gassource(gas_output))
		gas_output = src

	if(source_1 == gas_output || source_2 == gas_output)
		return

	var/datum/gas_mixture/source_1_gases = source_1.return_air()
	var/datum/gas_mixture/source_2_gases = source_2.return_air()
	var/datum/gas_mixture/output_gases = gas_output.return_air()

	if(!source_1_gases || !source_2_gases || !output_gases)
		return

	if(output_gases.return_pressure() >= PUMP_MAX_PRESSURE)
		return

	if(source_1_gases.return_pressure() <= 0 || source_2_gases.return_pressure() <= 0)
		return

	//This calculates how much should be sent
	var/gas_percentage = round(max(min(get_pin_data(IC_INPUT, 4),100),0) / 100)

	//Basically: number of moles = percentage of pressure filled up * efficiency coefficient * (pressure from both gases * volume of output) / (R * Temperature)
	var/transfer_moles = (get_pin_data(IC_INPUT, 5) / max(1,output_gases.return_pressure())) * PUMP_EFFICIENCY * (source_1_gases.return_pressure() * gas_percentage +  source_2_gases.return_pressure() * (1 - gas_percentage)) * output_gases.volume/ (R_IDEAL_GAS_EQUATION * max(output_gases.temperature,TCMB))


	if(transfer_moles <= 0)
		return

	var/datum/gas_mixture/mix = source_1_gases.remove(transfer_moles * gas_percentage)
	output_gases.merge(mix)
	mix = source_2_gases.remove(transfer_moles * (1-gas_percentage))
	output_gases.merge(mix)


// - integrated tank - // **works**
/obj/item/integrated_circuit/atmospherics/tank
	name = "integrated tank"
	desc = "A small tank for the storage of gases."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	size = 4
	activators = list(
			"push ref" = IC_PINTYPE_PULSE_IN
			)
	volume = 3 //emergency tank sized
	var/broken = FALSE

/obj/item/integrated_circuit/atmospherics/tank/Initialize()
	air_contents = new(volume)
	START_PROCESSING(SSobj, src)
	extended_desc = "Take care not to pressurize it above [round(TANK_FAILURE_PRESSURE)] kPa, or else it will break."
	. = ..()

/obj/item/integrated_circuit/atmospherics/tank/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/atmospherics/tank/do_work()
	set_pin_data(IC_OUTPUT, 1, WEAKREF(src))
	push_data()

/obj/item/integrated_circuit/atmospherics/tank/process()
	var/tank_pressure = air_contents.return_pressure()
	set_pin_data(IC_OUTPUT, 2, tank_pressure)
	push_data()

	//Check if tank broken
	if(!broken && tank_pressure > TANK_FAILURE_PRESSURE)
		broken = TRUE
		to_chat(view(2),"<span class='notice'>The [name] ruptures, releasing its gases!</span>")
	if(broken)
		release()

/obj/item/integrated_circuit/atmospherics/tank/proc/release()
	if(air_contents.total_moles() > 0)
		playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
		var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
		var/turf/current_turf = get_turf(src)
		var/datum/gas_mixture/exterior_gas
		if(!current_turf)
			return

		exterior_gas = current_turf.return_air()
		exterior_gas.merge(expelled_gas)


// - large integrated tank - // **works**
/obj/item/integrated_circuit/atmospherics/tank/large
	name = "large integrated tank"
	desc = "A less small tank for the storage of gases."
	volume = 9
	size = 12
	spawn_flags = IC_SPAWN_RESEARCH


// - freezer tank - // **works**
/obj/item/integrated_circuit/atmospherics/tank/freezer
	name = "freezer tank"
	desc = "Cools the gas it contains to a preset temperature."
	volume = 6
	size = 8
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	inputs_default = list("1" = 300)
	spawn_flags = IC_SPAWN_RESEARCH
	var/temperature = 293.15
	var/heater_coefficient = 0.1

/obj/item/integrated_circuit/atmospherics/tank/freezer/on_data_written()
	temperature = max(73.15,min(293.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/tank/freezer/process()
	var/tank_pressure = air_contents.return_pressure()
	set_pin_data(IC_OUTPUT, 2, tank_pressure)
	push_data()

	//Cool the tank if the power is on and the temp is above
	if(!power_draw_idle || air_contents.temperature < temperature)
		return

	air_contents.temperature = max(73.15,air_contents.temperature - (air_contents.temperature - temperature) * heater_coefficient)


// - heater tank - // **works**
/obj/item/integrated_circuit/atmospherics/tank/freezer/heater
	name = "heater tank"
	desc = "Heats the gas it contains to a preset temperature."
	volume = 6
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/atmospherics/tank/freezer/heater/on_data_written()
	temperature = max(293.15,min(573.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/tank/freezer/heater/process()
	var/tank_pressure = air_contents.return_pressure()
	set_pin_data(IC_OUTPUT, 2, tank_pressure)
	push_data()

	//Heat the tank if the power is on or its temperature is below what is set
	if(!power_draw_idle || air_contents.temperature > temperature)
		return

	air_contents.temperature = min(573.15,air_contents.temperature + (temperature - air_contents.temperature) * heater_coefficient)


// - atmospheric cooler - // **works**
/obj/item/integrated_circuit/atmospherics/cooler
	name = "atmospheric cooler circuit"
	desc = "Cools the air around it."
	volume = 6
	size = 13
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	var/temperature = 293.15
	var/heater_coefficient = 0.1

/obj/item/integrated_circuit/atmospherics/cooler/Initialize()
	air_contents = new(volume)
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/atmospherics/cooler/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/atmospherics/cooler/on_data_written()
	temperature = max(243.15,min(293.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/cooler/process()
	set_pin_data(IC_OUTPUT, 2, air_contents.return_pressure())
	push_data()


	//Get the turf you're on and its gas mixture
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	var/datum/gas_mixture/turf_air = current_turf.return_air()
	if(!power_draw_idle || turf_air.temperature < temperature)
		return

	//Cool the gas
	turf_air.temperature = max(243.15,turf_air.temperature - (turf_air.temperature - temperature) * heater_coefficient)


// - atmospheric heater - // **works**
/obj/item/integrated_circuit/atmospherics/cooler/heater
	name = "atmospheric heater circuit"
	desc = "Heats the air around it."

/obj/item/integrated_circuit/atmospherics/cooler/heater/on_data_written()
	temperature = max(293.15,min(323.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/cooler/heater/process()
	set_pin_data(IC_OUTPUT, 2, air_contents.return_pressure())
	push_data()

	//Get the turf and its air mixture
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	var/datum/gas_mixture/turf_air = current_turf.return_air()
	if(!power_draw_idle || turf_air.temperature > temperature)
		return

	//Heat the gas
	turf_air.temperature = min(323.15,turf_air.temperature + (temperature - turf_air.temperature) * heater_coefficient)


// - tank slot - // **works**
/obj/item/integrated_circuit/input/tank_slot
	category_text = "Atmospherics"
	cooldown_per_use = 1
	name = "tank slot"
	desc = "Lets you add a tank to your assembly and remove it even when the assembly is closed."
	extended_desc = "It can help you extract gases easier."
	complexity = 25
	size = 30
	inputs = list()
	outputs = list(
		"pressure used" = IC_PINTYPE_NUMBER,
		"current tank" = IC_PINTYPE_REF
		)
	activators = list(
		"push ref" = IC_PINTYPE_PULSE_IN,
		"on insert" = IC_PINTYPE_PULSE_OUT,
		"on remove" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

	can_be_asked_input = TRUE
	demands_object_input = TRUE
	can_input_object_when_closed = TRUE

	var/obj/item/tank/internals/current_tank

/obj/item/integrated_circuit/input/tank_slot/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/input/tank_slot/process()
	push_pressure()

/obj/item/integrated_circuit/input/tank_slot/attackby(var/obj/item/tank/internals/I, var/mob/living/user)
	//Check if it truly is a tank
	if(!istype(I,/obj/item/tank/internals))
		to_chat(user,"<span class='warning'>The [I.name] doesn't seem to fit in here.</span>")
		return

	//Check if there is no other tank already inside
	if(current_tank)
		to_chat(user,"<span class='warning'>There is already a gas tank inside.</span>")
		return

	//The current tank is the one we just attached, its location is inside the circuit
	current_tank = I
	user.transferItemToLoc(I,src)
	to_chat(user,"<span class='warning'>You put the [I.name] inside the tank slot.</span>")

	//Set the pin to a weak reference of the current tank
	push_pressure()
	set_pin_data(IC_OUTPUT, 2, WEAKREF(current_tank))
	push_data()
	do_work(1)


/obj/item/integrated_circuit/input/tank_slot/ask_for_input(mob/user)
	attack_self(user)

/obj/item/integrated_circuit/input/tank_slot/attack_self(mob/user)
	//Check if no tank attached
	if(!current_tank)
		to_chat(user, "<span class='notice'>There is currently no tank attached.</span>")
		return

	//Remove tank and put in user's hands/location
	to_chat(user, "<span class='notice'>You take [current_tank] out of the tank slot.</span>")
	user.put_in_hands(current_tank)
	current_tank = null

	//Remove tank reference
	push_pressure()
	set_pin_data(IC_OUTPUT, 2, null)
	push_data()
	do_work(2)

/obj/item/integrated_circuit/input/tank_slot/do_work()
	set_pin_data(IC_OUTPUT, 2, WEAKREF(current_tank))
	push_data()

/obj/item/integrated_circuit/input/tank_slot/proc/push_pressure()
	if(!current_tank)
		set_pin_data(IC_OUTPUT, 1, 0)
		return

	var/datum/gas_mixture/tank_air = current_tank.return_air()
	if(!tank_air)
		set_pin_data(IC_OUTPUT, 1, 0)
		return

	set_pin_data(IC_OUTPUT, 1, tank_air.return_pressure())
	push_data()


#undef SOURCE_TO_TARGET
#undef TARGET_TO_SOURCE
#undef PUMP_EFFICIENCY
#undef TANK_FAILURE_PRESSURE
#undef PUMP_MAX_PRESSURE
#undef PUMP_MAX_VOLUME
