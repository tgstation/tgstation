/obj/machinery/meter
	name = "gas flow meter"
	desc = "It measures something."
	icon = 'icons/obj/atmospherics/pipes/meter.dmi'
	icon_state = "meter"
	layer = HIGH_PIPE_LAYER
	power_channel = AREA_USAGE_ENVIRON
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.03
	max_integrity = 150
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 40, ACID = 0)
	greyscale_config = /datum/greyscale_config/meter
	greyscale_colors = COLOR_GRAY
	///The pipe we are attaching to
	var/obj/machinery/atmospherics/pipe/target
	///The piping layer of the target
	var/target_layer = PIPING_LAYER_DEFAULT

/obj/machinery/meter/Destroy()
	SSair.stop_processing_machine(src)
	target = null
	return ..()

/obj/machinery/meter/Initialize(mapload, new_piping_layer)
	if(!isnull(new_piping_layer))
		target_layer = new_piping_layer

	SSair.start_processing_machine(src)

	if(!target)
		reattach_to_layer()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/atmos_meter,
	))
	return ..()

/obj/machinery/meter/proc/reattach_to_layer()
	var/obj/machinery/atmospherics/candidate
	for(var/obj/machinery/atmospherics/pipe/pipe in loc)
		if(pipe.piping_layer == target_layer)
			candidate = pipe
	if(candidate)
		target = candidate
		setAttachLayer(candidate.piping_layer)

/obj/machinery/meter/proc/setAttachLayer(new_layer)
	target_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, target_layer)

/obj/machinery/meter/on_set_is_operational(old_value)
	if(is_operational)
		SSair.start_processing_machine(src)//dont set icon_state here because it will be reset on next process() if it ever happens
	else
		icon_state = "meter"
		SSair.stop_processing_machine(src)

/obj/machinery/meter/process_atmos()
	var/datum/gas_mixture/pipe_air = target.return_air()
	if(!pipe_air)
		icon_state = "meter0"
		return FALSE

	var/env_pressure = pipe_air.return_pressure()
	if(env_pressure <= 0.15 * ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	var/env_temperature = pipe_air.temperature

	var/new_greyscale = greyscale_colors

	if(env_pressure == 0 || env_temperature == 0)
		new_greyscale = COLOR_GRAY
	else
		switch(env_temperature)
			if(BODYTEMP_HEAT_WARNING_3 to INFINITY)
				new_greyscale = COLOR_RED
			if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
				new_greyscale = COLOR_ORANGE
			if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2)
				new_greyscale = COLOR_YELLOW
			if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1)
				new_greyscale = COLOR_VIBRANT_LIME
			if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1)
				new_greyscale = COLOR_CYAN
			if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
				new_greyscale = COLOR_BLUE
			else
				new_greyscale = COLOR_VIOLET

	if(new_greyscale != greyscale_colors)//dont update if nothing has changed since last update
		greyscale_colors = new_greyscale
		set_greyscale(greyscale_colors)

/obj/machinery/meter/proc/status()
	if (target)
		var/datum/gas_mixture/pipe_air = target.return_air()
		if(pipe_air)
			. = "The pressure gauge reads [round(pipe_air.return_pressure(), 0.01)] kPa; [round(pipe_air.temperature,0.01)] K ([round(pipe_air.temperature-T0C,0.01)]&deg;C)."
		else
			. = "The sensor error light is blinking."
	else
		. = "The connect error light is blinking."

/obj/machinery/meter/examine(mob/user)
	. = ..()
	. += status()

/obj/machinery/meter/wrench_act(mob/user, obj/item/wrench)
	..()
	to_chat(user, span_notice("You begin to unfasten \the [src]..."))
	if (wrench.use_tool(src, user, 40, volume=50))
		user.visible_message(
			"[user] unfastens \the [src].",
			span_notice("You unfasten \the [src]."),
			span_hear("You hear ratchet."))
		deconstruct()
	return TRUE

/obj/machinery/meter/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/pipe_meter(loc)
	. = ..()

/obj/machinery/meter/interact(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	else
		to_chat(user, status())

/obj/machinery/meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/item/circuit_component/atmos_meter
	display_name = "Atmospheric Meter"
	desc = "Allows to read the pressure and temperature of the pipenet."

	///Signals the circuit to retrieve the pipenet's current pressure and temperature
	var/datum/port/input/request_data

	///Pressure of the pipenet
	var/datum/port/output/pressure
	///Temperature of the pipenet
	var/datum/port/output/temperature

	///The component parent object
	var/obj/machinery/meter/connected_meter

/obj/item/circuit_component/atmos_meter/populate_ports()
	request_data = add_input_port("Request Meter Data", PORT_TYPE_SIGNAL, trigger = .proc/request_meter_data)

	pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)

/obj/item/circuit_component/atmos_meter/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/meter))
		connected_meter = shell

/obj/item/circuit_component/atmos_meter/unregister_usb_parent(atom/movable/shell)
	connected_meter = null
	return ..()

/obj/item/circuit_component/atmos_meter/proc/request_meter_data()
	CIRCUIT_TRIGGER
	if(!connected_meter)
		return
	var/datum/gas_mixture/environment = connected_meter.target.return_air()
	pressure.set_output(environment.return_pressure())
	temperature.set_output(environment.temperature)

// TURF METER - REPORTS A TILE'S AIR CONTENTS
// why are you yelling?
/obj/machinery/meter/turf

/obj/machinery/meter/turf/reattach_to_layer()
	target = loc

/obj/machinery/meter/layer2
	target_layer = 2

/obj/machinery/meter/layer4
	target_layer = 4
