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

	multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
		return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[id_tag]</a></li>
		</ul>
		"}

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
				"tag" = id_tag,
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
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)

	receive_signal(datum/signal/signal)

		if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
			return 0

		var/handled=0
		if("power" in signal.data)
			on = text2num(signal.data["power"])
			handled=1

		if("power_toggle" in signal.data)
			on = !on
			handled=1

		if("direction" in signal.data)
			pump_direction = text2num(signal.data["direction"])
			handled=1

		if("checks" in signal.data)
			pressure_checks = text2num(signal.data["checks"])
			handled=1

		if("purge" in signal.data)
			pressure_checks &= ~1
			pump_direction = 0
			handled=1

		if("stabilize" in signal.data)
			pressure_checks |= 1
			pump_direction = 1
			handled=1

		if("set_input_pressure" in signal.data)
			input_pressure_min = between(
				0,
				text2num(signal.data["set_input_pressure"]),
				ONE_ATMOSPHERE*50
			)
			handled=1

		if("set_output_pressure" in signal.data)
			output_pressure_max = between(
				0,
				text2num(signal.data["set_output_pressure"]),
				ONE_ATMOSPHERE*50
			)
			handled=1

		if("set_external_pressure" in signal.data)
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE*50
			)
			handled=1

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon
		if(!handled)
			testing("\[[world.timeofday]\]: dp_vent_pump/receive_signal: unknown command \n[signal.debug_print()]")
		spawn(2)
			broadcast_status()
		update_icon()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		/*
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if (WT.remove_fuel(0,user))
				user << "\blue Now welding the vent."
				if(do_after(user, 20))
					if(!src || !WT.isOn()) return
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
					if(!welded)
						user.visible_message("[user] welds the vent shut.", "You weld the vent shut.", "You hear welding.")
						welded = 1
						update_icon()
					else
						user.visible_message("[user] unwelds the vent.", "You unweld the vent.", "You hear welding.")
						welded = 0
						update_icon()
				else
					user << "\blue The welding tool needs to be on to start this task."
			else
				user << "\blue You need more welding fuel to complete this task."
				return 1*/
		if(istype(W, /obj/item/device/multitool))
			interact(user)
			return 1
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		if (!(stat & NOPOWER) && on)
			user << "\red You cannot unwrench this [src], turn it off first."
			return 1
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)
