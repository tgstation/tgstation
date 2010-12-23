/obj/machinery/atmospherics/unary/vent_pump
	icon = 'vent_pump.dmi'
	icon_state = "off"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it"

	level = 1

	high_volume
		name = "Large Air Vent"

		New()
			..()

			air_contents.volume = 1000

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/internal_pressure_bound = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	var/welded = 0 // Added for aliens -- TLE

	update_icon()
		if(on && !(stat & (NOPOWER|BROKEN)))
			if(pump_direction)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"

		return
	process()
		..()
		if(stat & (NOPOWER|BROKEN))
			return
		if (!node)
			on = 0
		broadcast_status()

		if(!on)
			return 0
		if(welded)
			return 0

		var/datum/gas_mixture/environment = loc.return_air()
		var/environment_pressure = environment.return_pressure()

		if(pump_direction) //internal -> external
			var/pressure_delta = 10000

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
			if(pressure_checks&2)
				pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

			if(pressure_delta > 0)
				if(air_contents.temperature > 0)
					var/transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

					use_power(10, ENVIRON)
					loc.assume_air(removed)

					if(network)
						network.update = 1

		else //external -> internal
			var/pressure_delta = 10000

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
			if(pressure_checks&2)
				pressure_delta = min(pressure_delta, (internal_pressure_bound - air_contents.return_pressure()))

			if(pressure_delta > 0)
				if(environment.temperature > 0)
					var/transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
					if (isnull(removed)) //in space
						return
					use_power(10, ENVIRON)
					air_contents.merge(removed)

					if(network)
						network.update = 1

		return 1

	//Radio remote control

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, "[frequency]")

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src

			signal.data["tag"] = id
			signal.data["device"] = "AVP"
			signal.data["power"] = on?("on"):("off")
			signal.data["direction"] = pump_direction?("release"):("siphon")
			signal.data["checks"] = pressure_checks
			signal.data["internal"] = internal_pressure_bound
			signal.data["external"] = external_pressure_bound

			radio_connection.post_signal(src, signal)

			return 1

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)
		update_icon()

	receive_signal(datum/signal/signal)
		if(signal.data["tag"] && (signal.data["tag"] != id))
			return 0

		switch(signal.data["command"])
			if("power_on")
				on = 1

			if("power_off")
				on = 0

			if("power_toggle")
				on = !on

			if("toggle_checks")
				pressure_checks = (pressure_checks?0:3)


			if("set_direction")
				var/number = text2num(signal.data["parameter"])
				if(number > 0.5)
					pump_direction = 1
				else
					pump_direction = 0

			if("purge")
				pressure_checks &= ~1
				pump_direction = 0

			if("stabalize")
				pressure_checks |= 1
				pump_direction = 1

			if("set_checks")
				var/number = round(text2num(signal.data["parameter"]),1)
				pressure_checks = number

			if("set_internal_pressure")
				var/number = text2num(signal.data["parameter"])
				number = min(max(number, 0), ONE_ATMOSPHERE*50)

				internal_pressure_bound = number

			if("set_external_pressure")
				var/number = text2num(signal.data["parameter"])
				number = min(max(number, 0), ONE_ATMOSPHERE*50)

				external_pressure_bound = number

		if(signal.data["tag"])
			spawn(2)
				broadcast_status()
				update_icon()
		return

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(pump_direction)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return

	attackby(obj/item/W, mob/user)			// Added for aliens -- TLE
		// Stolen from the Emitter welding code of the Singularity
		if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
			if (W:get_fuel() < 1)
				user << "\blue You need more welding fuel to complete this task."
				return
			W:use_fuel(1)
			playsound(src.loc, 'Welder2.ogg', 50, 1)

			if(!welded)
				user.visible_message("[user] welds the vent shut.", "You weld the vent shut.", "You hear welding.")
				welded = 1
			else
				user.visible_message("[user] unwelds the vent.", "You unweld the vent.", "You hear welding.")
				welded = 0

	examine()
		set src in oview(1)
		..()
		if(welded)
			usr << "It seems welded shut."

	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		update_icon()
