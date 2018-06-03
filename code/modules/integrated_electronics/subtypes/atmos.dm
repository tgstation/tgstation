#define SOURCE_TO_TARGET 0
#define TARGET_TO_SOURCE 1
#define MAX_TARGET_PRESSURE (ONE_ATMOSPHERE*25)
#define PUMP_EFFICIENCY 0.6
#define TANK_FAILURE_PRESSURE (ONE_ATMOSPHERE*25)

/obj/item/integrated_circuit/atmospherics
	category_text = "Atmospherics"
	cooldown_per_use = 2 SECONDS

/obj/item/integrated_circuit/atmospherics/atmospheric_analyzer
	name = "atmospheric analyzer"
	desc = "A miniaturized analyzer which can scan anything that contains gases."
	extended_desc = "The nth element of gas amounts is the number of moles of the \
					nth gas in gas list. \
					Pressure is in kPa, temperature is in Kelvin. \
					Due to programming limitations, scanning an object that does \
					not contain a gas will return the air around it instead."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"target" = IC_PINTYPE_REF
			)
	outputs = list(
			"gas list" = IC_PINTYPE_LIST,
			"gas amounts" = IC_PINTYPE_LIST,
			"total moles" = IC_PINTYPE_NUMBER,
			"pressure" = IC_PINTYPE_NUMBER,
			"temperature" = IC_PINTYPE_NUMBER,
			"volume" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"scan" = IC_PINTYPE_PULSE_IN,
			"on success" = IC_PINTYPE_PULSE_OUT,
			"on failure" = IC_PINTYPE_PULSE_OUT
			)
	power_draw_per_use = 5

/obj/item/integrated_circuit/atmospherics/atmospheric_analyzer/do_work()
	for(var/i=1 to 6)
		set_pin_data(IC_OUTPUT, i, null)
	var/atom/target = get_pin_data_as_type(IC_INPUT, 1, /atom)
	var/atom/movable/acting_object = get_object()
	if(!target || !target.Adjacent(acting_object))
		activate_pin(3)
		return

	var/datum/gas_mixture/air_contents = target.return_air()
	if(!air_contents)
		activate_pin(3)
		return

	var/list/gases = air_contents.gases
	var/list/gas_names = list()
	var/list/gas_amounts = list()
	for(var/id in gases)
		var/name = gases[id][GAS_META][META_GAS_NAME]
		var/amt = round(gases[id][MOLES], 0.001)
		gas_names.Add(name)
		gas_amounts.Add(amt)

	set_pin_data(IC_OUTPUT, 1, gas_names)
	set_pin_data(IC_OUTPUT, 2, gas_amounts)
	set_pin_data(IC_OUTPUT, 3, round(air_contents.total_moles(), 0.001))
	set_pin_data(IC_OUTPUT, 4, round(air_contents.return_pressure(), 0.001))
	set_pin_data(IC_OUTPUT, 5, round(air_contents.temperature, 0.001))
	set_pin_data(IC_OUTPUT, 6, round(air_contents.return_volume(), 0.001))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump
	name = "gas pump"
	desc = "Somehow moves gases between two tanks, canisters, and other gas containers."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	complexity = 5
	size = 3
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
	var/target_pressure = ONE_ATMOSPHERE
	power_draw_per_use = 20

/obj/item/integrated_circuit/atmospherics/pump/Initialize()
	extended_desc += " Use negative pressure to move air from target to source. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure. \
					The pressure limit for circuit pumps is [round(MAX_TARGET_PRESSURE)] kPa."
	. = ..()

/obj/item/integrated_circuit/atmospherics/pump/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 3)
	update_target(amt)

/obj/item/integrated_circuit/atmospherics/pump/proc/update_target(new_amount)
	if(new_amount < 0)
		new_amount = -new_amount
		direction = TARGET_TO_SOURCE
	else
		direction = SOURCE_TO_TARGET
	if(isnum(new_amount))
		new_amount = CLAMP(new_amount, 0, MAX_TARGET_PRESSURE)
		target_pressure = new_amount

/obj/item/integrated_circuit/atmospherics/pump/do_work()
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 2, /obj)
	perform_magic(source, target)
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/proc/perform_magic(atom/source, atom/target)
	if(!check_targets(source, target))
		return

	var/datum/gas_mixture/source_air = source.return_air()
	var/datum/gas_mixture/target_air = target.return_air()

	if(!source_air || !target_air)
		return

	if(direction == TARGET_TO_SOURCE)
		var/temp = source_air
		source_air = target_air
		target_air = temp
	move_gas(source_air, target_air)
	air_update_turf()

/obj/item/integrated_circuit/atmospherics/pump/proc/check_targets(atom/source, atom/target)
	var/atom/movable/acting_object = get_object()
	if(!source || !target)
		return FALSE
	if(!source.Adjacent(acting_object) || !target.Adjacent(acting_object))
		return FALSE
	if(!istype(source, /obj/item/tank) && !istype(source, /obj/machinery/portable_atmospherics) && !istype(source, /obj/item/integrated_circuit/atmospherics/tank))
		return FALSE
	if(!istype(target, /obj/item/tank) && !istype(target, /obj/machinery/portable_atmospherics) && !istype(target, /obj/item/integrated_circuit/atmospherics/tank))
		return FALSE
	return TRUE

/obj/item/integrated_circuit/atmospherics/pump/proc/move_gas(datum/gas_mixture/source_air, datum/gas_mixture/target_air)
	if((source_air.total_moles() > 0) && (source_air.temperature>0))
		var/pressure_delta = target_pressure - target_air.return_pressure()
		if(pressure_delta > 0.1)
			var/transfer_moles = (pressure_delta*target_air.volume/(source_air.temperature * R_IDEAL_GAS_EQUATION))*PUMP_EFFICIENCY
			var/datum/gas_mixture/removed = source_air.remove(transfer_moles)
			target_air.merge(removed)

/obj/item/integrated_circuit/atmospherics/pump/vent
	name = "gas vent"
	desc = "Moves gases between the environment and adjacent gas containers."
	complexity = 5
	size = 3
	inputs = list(
			"container" = IC_PINTYPE_REF,
			"target pressure" = IC_PINTYPE_NUMBER
			)

/obj/item/integrated_circuit/atmospherics/pump/vent/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 2)
	update_target(amt)

/obj/item/integrated_circuit/atmospherics/pump/vent/do_work()
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/turf/target = get_turf(get_object())
	perform_magic(source, target)
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/vent/check_targets(atom/source, atom/target)
	var/atom/movable/acting_object = get_object()
	if(!source || !target)
		return FALSE
	if(!source.Adjacent(acting_object))
		return FALSE
	if(!istype(source, /obj/item/tank) && !istype(source, /obj/machinery/portable_atmospherics) && !istype(source, /obj/item/integrated_circuit/atmospherics/tank))
		return FALSE
	if(!istype(target, /turf))
		return FALSE
	return TRUE

/obj/item/integrated_circuit/atmospherics/connector
	name = "integrated connector"
	desc = "Creates an airtight seal with standard connectors found on the floor, \
		 	allowing the assembly to exchange gases with a pipe network."
	extended_desc = "This circuit will automatically attempt to locate and connect to ports on the floor beneath it when activated. \
					You <b>must</b> set a target before connecting."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	complexity = 2
	size = 6
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

/obj/item/integrated_circuit/atmospherics/connector/ext_moved()
	if(connector)
		var/atom/movable/acting_object = get_object()
		if(get_dist(acting_object, connector) > 0)
			connector.connected_device = null
			connector = null
			activate_pin(4)

/obj/item/integrated_circuit/atmospherics/connector/portableConnectorReturnAir()
	var/obj/target = get_pin_data_as_type(IC_INPUT, 1, /obj)
	if(target && istype(target, /obj/item/tank) || istype(target, /obj/machinery/portable_atmospherics))
		return target.return_air()

/obj/item/integrated_circuit/atmospherics/connector/do_work()
	var/atom/movable/acting_object = get_object()
	if(connector)
		connector.connected_device = null
		connector = null
		activate_pin(4)
		return
	var/obj/machinery/atmospherics/components/unary/portables_connector/PC = locate() in get_turf(acting_object)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 1, /obj)
	if(!PC || get_dist(acting_object, PC) > 0 || !target)
		activate_pin(3)
		return
	connector = PC
	connector.connected_device = src
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/filter
	name = "gas filter"
	desc = "Filters one gas out of a mixture."
	complexity = 20
	size = 5
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"filtered output" = IC_PINTYPE_REF,
			"unfiltered output" = IC_PINTYPE_REF,
			"wanted gas" = IC_PINTYPE_STRING,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	power_draw_per_use = 30

/obj/item/integrated_circuit/atmospherics/pump/filter/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 5)
	target_pressure = CLAMP(amt, 0, MAX_TARGET_PRESSURE)

/obj/item/integrated_circuit/atmospherics/pump/filter/do_work()
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/filtered = get_pin_data_as_type(IC_INPUT, 2, /obj)
	var/obj/unfiltered = get_pin_data_as_type(IC_INPUT, 3, /obj)
	var/wanted = get_pin_data(IC_INPUT, 4)
	if(!check_targets(source, filtered) || !check_targets(source, unfiltered) || !wanted)
		return

	var/datum/gas_mixture/source_air = source.return_air()
	var/datum/gas_mixture/filtered_air = filtered.return_air()
	var/datum/gas_mixture/unfiltered_air = unfiltered.return_air()

	if(!source_air || !filtered_air || !unfiltered_air)
		return

	var/pressure_delta = target_pressure - unfiltered_air.return_pressure()
	var/transfer_moles

	if(source_air.temperature > 0)
		transfer_moles = (pressure_delta*unfiltered_air.volume/(source_air.temperature * R_IDEAL_GAS_EQUATION))*PUMP_EFFICIENCY

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = source_air.remove(transfer_moles)
		if(!removed)
			return
		for(var/filtered_gas in removed.gases)
			var/name = removed.gases[filtered_gas][GAS_META][META_GAS_NAME]
			if(name == wanted)
				var/datum/gas_mixture/filtered_out = new
				filtered_out.temperature = removed.temperature
				filtered_out.add_gas(filtered_gas)
				filtered_out.gases[filtered_gas][MOLES] = removed.gases[filtered_gas][MOLES]

				removed.gases[filtered_gas][MOLES] = 0
				removed.garbage_collect()

				var/datum/gas_mixture/target = (filtered_air.return_pressure() < target_pressure ? filtered_air : source_air)
				target.merge(filtered_out)
				break
		unfiltered_air.merge(removed)
		activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/filter/Initialize()
	. = ..()
	extended_desc = "Remember to properly spell and capitalize the filtered gas name. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure. \
					The pressure limit for circuit pumps is [round(MAX_TARGET_PRESSURE)] kPa."

/obj/item/integrated_circuit/atmospherics/tank
	name = "integrated tank"
	desc = "A small tank for the storage of gases."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	size = 4
	outputs = list(
			"self reference" = IC_PINTYPE_REF
			)
	activators = list(
			"push ref" = IC_PINTYPE_PULSE_IN
			)
	var/datum/gas_mixture/air_contents
	var/volume = 3 //emergency tank sized
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

/obj/item/integrated_circuit/atmospherics/tank/process()
	if(!broken && air_contents.return_pressure() > TANK_FAILURE_PRESSURE)
		broken = TRUE
	if(broken)
		release()

/obj/item/integrated_circuit/atmospherics/tank/proc/release()
	if(air_contents.total_moles() > 0)
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
		loc.assume_air(expelled_gas)

/obj/item/integrated_circuit/atmospherics/tank/large
	name = "large integrated tank"
	desc = "A less small tank for the storage of gases."
	volume = 6
	size = 8
	spawn_flags = IC_SPAWN_RESEARCH

#undef SOURCE_TO_TARGET
#undef TARGET_TO_SOURCE
#undef MAX_TARGET_PRESSURE
#undef PUMP_EFFICIENCY
#undef TANK_FAILURE_PRESSURE