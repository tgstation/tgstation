#define SOURCE_TO_TARGET 0
#define TARGET_TO_SOURCE 1
#define MAX_TARGET_PRESSURE (ONE_ATMOSPHERE*25)

/obj/item/integrated_circuit/atmospherics
	category_text = "Atmospherics"
	cooldown_per_use = 10

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
	extended_desc = "Use negative pressures to suck gases out of the target instead. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure."
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
	var/target_pressure = ONE_ATMOSPHERE

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
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/proc/check_targets(atom/source, atom/target)
	var/atom/movable/acting_object = get_object()
	if(!source || !target)
		return FALSE
	if(!source.Adjacent(acting_object) || !target.Adjacent(acting_object))
		return FALSE
	if(!istype(source, /obj/item/tank) && !istype(source, /obj/machinery/portable_atmospherics))
		return FALSE
	if(!istype(target, /obj/item/tank) && !istype(target, /obj/machinery/portable_atmospherics))
		return FALSE
	return TRUE

/obj/item/integrated_circuit/atmospherics/pump/proc/move_gas(datum/gas_mixture/source_air, datum/gas_mixture/target_air)
	if((source_air.total_moles() > 0) && (source_air.temperature>0))
		var/pressure_delta = target_pressure - target_air.return_pressure()
		if(pressure_delta > 0.1)
			var/transfer_moles = pressure_delta*target_air.volume/(source_air.temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = source_air.remove(transfer_moles*0.6)
			target_air.merge(removed)

/obj/item/integrated_circuit/atmospherics/pump/vent
	name = "gas vent"
	desc = "Moves gases between the environment and adjacent gas containers."
	extended_desc = "Use negative pressures to suck gases out of the air. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure."
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

/obj/item/integrated_circuit/atmospherics/pump/vent/check_targets(atom/source, atom/target)
	var/atom/movable/acting_object = get_object()
	if(!source || !target)
		return FALSE
	if(!source.Adjacent(acting_object))
		return FALSE
	if(!istype(source, /obj/item/tank) && !istype(source, /obj/machinery/portable_atmospherics))
		return FALSE
	if(!istype(target, /turf))
		return FALSE
	return TRUE