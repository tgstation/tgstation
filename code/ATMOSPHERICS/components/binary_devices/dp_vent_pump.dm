/obj/machinery/atmospherics/binary/dp_vent_pump
	icon = 'icons/obj/atmospherics/dp_vent_pump.dmi'
	icon_state = "off"

	//node2 is output port
	//node1 is input port

	name = "Dual Port Air Vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	level = 1

	high_volume
		name = "Large Dual Port Air Vent"

		New()
			..()

			air1.volume = 1000
			air2.volume = 1000

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass input_pressure_min
	//4: Do not pass output_pressure_max

	update_icon()
		if(on)
			if(pump_direction)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0

		return

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on)
			if(pump_direction)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return

	process()
		..()

		if(!on)
			return 0

		var/datum/gas_mixture/environment = loc.return_air()
		var/environment_pressure = environment.return_pressure()

		if(pump_direction) //input -> external
			var/pressure_delta = 10000

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
			if(pressure_checks&2)
				pressure_delta = min(pressure_delta, (air1.return_pressure() - input_pressure_min))

			if(pressure_delta > 0)
				if(air1.temperature > 0)
					var/transfer_moles = pressure_delta*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = air1.remove(transfer_moles)

					loc.assume_air(removed)

					if(network1)
						network1.update = 1

		else //external -> output
			var/pressure_delta = 10000

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
			if(pressure_checks&4)
				pressure_delta = min(pressure_delta, (output_pressure_max - air2.return_pressure()))

			if(pressure_delta > 0)
				if(environment.temperature > 0)
					var/transfer_moles = pressure_delta*air2.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

					air2.merge(removed)

					if(network2)
						network2.update = 1

		return 1

	//Radio remote control

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

		broadcast_status()
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
			radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

			return 1

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)

	receive_signal(datum/signal/signal)
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
			input_pressure_min = between(
				0,
				text2num(signal.data["set_input_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("set_output_pressure" in signal.data)
			output_pressure_max = between(
				0,
				text2num(signal.data["set_output_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("set_external_pressure" in signal.data)
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon
		//if(signal.data["tag"])
		spawn(2)
			broadcast_status()
		update_icon()