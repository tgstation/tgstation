/*
Acts like a normal vent, but has an input AND output.
*/
#define EXT_BOUND	1
#define INPUT_MIN	2
#define OUTPUT_MAX	4

/obj/machinery/atmospherics/components/binary/dp_vent_pump
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi' //We reuse the normal vent icons!
	icon_state = "dpvent_map"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	level = 1
	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	var/on = FALSE
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	var/pressure_checks = EXT_BOUND
	//EXT_BOUND: Do not pass external_pressure_bound
	//INPUT_MIN: Do not pass input_pressure_min
	//OUTPUT_MAX: Do not pass output_pressure_max

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on
	on = TRUE
	icon_state = "dpvent_map_on"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/Destroy()
	SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume
	name = "large dual-port air vent"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on
	on = TRUE
	icon_state = "dpvent_map_on"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/New()
	..()
	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2
	air1.volume = 1000
	air2.volume = 1000

/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage('icons/obj/atmospherics/components/unary_devices.dmi', "dpvent_cap"))

	if(!on || stat & (NOPOWER|BROKEN))
		icon_state = "vent_off"
		return

	if(pump_direction)
		icon_state = "vent_out"
	else
		icon_state = "vent_in"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/process_atmos()
	..()

	if(!on)
		return FALSE
	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(pump_direction) //input -> external
		var/pressure_delta = 10000

		if(pressure_checks&EXT_BOUND)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&INPUT_MIN)
			pressure_delta = min(pressure_delta, (air1.return_pressure() - input_pressure_min))

		if(pressure_delta > 0)
			if(air1.temperature > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = air1.remove(transfer_moles)
				//Removed can be null if there is no atmosphere in air1
				if(!removed)
					return FALSE

				loc.assume_air(removed)
				air_update_turf()

				var/datum/pipeline/parent1 = PARENT1
				parent1.update = 1

	else //external -> output
		var/pressure_delta = 10000

		if(pressure_checks&EXT_BOUND)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks&INPUT_MIN)
			pressure_delta = min(pressure_delta, (output_pressure_max - air2.return_pressure()))

		if(pressure_delta > 0)
			if(environment.temperature > 0)
				var/transfer_moles = pressure_delta*air2.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
				//removed can be null if there is no air in the location
				if(!removed)
					return FALSE

				air2.merge(removed)
				air_update_turf()

				var/datum/pipeline/parent2 = PARENT2
				parent2.update = 1

	return TRUE

	//Radio remote control

/obj/machinery/atmospherics/components/binary/dp_vent_pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = GLOB.RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/dp_vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "ADVP",
		"power" = on,
		"direction" = pump_direction?("release"):("siphon"),
		"checks" = pressure_checks,
		"input" = input_pressure_min,
		"output" = output_pressure_max,
		"external" = external_pressure_bound,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal, filter = GLOB.RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/components/binary/dp_vent_pump/atmosinit()
	..()
	if(frequency)
		set_frequency(frequency)
	broadcast_status()

/obj/machinery/atmospherics/components/binary/dp_vent_pump/receive_signal(datum/signal/signal)

	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0
	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_direction" in signal.data)
		pump_direction = text2num(signal.data["set_direction"])

	if("checks" in signal.data)
		pressure_checks = text2num(signal.data["checks"])

	if("purge" in signal.data)
		pressure_checks &= ~1
		pump_direction = 0

	if("stabalize" in signal.data)
		pressure_checks |= 1
		pump_direction = 1

	if("set_input_pressure" in signal.data)
		input_pressure_min = Clamp(text2num(signal.data["set_input_pressure"]),0,ONE_ATMOSPHERE*50)

	if("set_output_pressure" in signal.data)
		output_pressure_max = Clamp(text2num(signal.data["set_output_pressure"]),0,ONE_ATMOSPHERE*50)

	if("set_external_pressure" in signal.data)
		external_pressure_bound = Clamp(text2num(signal.data["set_external_pressure"]),0,ONE_ATMOSPHERE*50)

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon
	//if(signal.data["tag"])
	spawn(2)
		broadcast_status()
	update_icon()

#undef EXT_BOUND
#undef INPUT_MIN
#undef OUTPUT_MAX
