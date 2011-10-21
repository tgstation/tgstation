/obj/machinery/atmospherics/unary/vent_pump
	icon = 'vent_pump.dmi'
	icon_state = "off"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it"

	level = 1
	layer = TURF_LAYER
	var/area_uid
	var/id_tag = null
	power_channel = ENVIRON

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/internal_pressure_bound = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	var/welded = 0 // Added for aliens -- TLE

	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/radio_filter_out
	var/radio_filter_in

	New()
		var/area/A = get_area(loc)
		if (A.master)
			A = A.master
		area_uid = A.uid
		if (!id_tag)
			assign_uid()
			id_tag = num2text(uid)
		if(ticker && ticker.current_state == 3)//if the game is running
			src.initialize()
			src.broadcast_status()
		..()

	high_volume
		name = "Large Air Vent"
		power_channel = EQUIP
		New()
			..()
			air_contents.volume = 1000

	update_icon()
		if(welded)
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]weld"
			return
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
		//broadcast_status() // from now air alarm/control computer should request update purposely --rastaf0
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

					air_contents.merge(removed)

					if(network)
						network.update = 1

		return 1

	//Radio remote control

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency,radio_filter_in)

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src

			signal.data = list(
				"area" = src.area_uid,
				"tag" = src.id_tag,
				"device" = "AVP",
				"power" = on,
				"direction" = pump_direction?("release"):("siphon"),
				"checks" = pressure_checks,
				"internal" = internal_pressure_bound,
				"external" = external_pressure_bound,
				"timestamp" = world.time,
				"sigtype" = "status"
			)

			radio_connection.post_signal(src, signal, radio_filter_out)

			return 1


	initialize()
		..()

		//some vents work his own spesial way
		radio_filter_in = frequency==1439?(RADIO_FROM_AIRALARM):null
		radio_filter_out = frequency==1439?(RADIO_TO_AIRALARM):null
		if(frequency)
			set_frequency(frequency)

	receive_signal(datum/signal/signal)
		if(stat & (NOPOWER|BROKEN))
			return
		//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/atmospherics/unary/vent_pump/receive_signal([signal.debug_print()])")
		if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
			return 0

		if("purge" in signal.data)
			pressure_checks &= ~1
			pump_direction = 0

		if("stabalize" in signal.data)
			pressure_checks |= 1
			pump_direction = 1

		if("power" in signal.data)
			on = text2num(signal.data["power"])

		if("power_toggle" in signal.data)
			on = !on

		if("checks" in signal.data)
			pressure_checks = text2num(signal.data["checks"])

		if("checks_toggle" in signal.data)
			pressure_checks = (pressure_checks?0:3)

		if("direction" in signal.data)
			pump_direction = text2num(signal.data["direction"])

		if("set_internal_pressure" in signal.data)
			internal_pressure_bound = between(
				0,
				text2num(signal.data["set_internal_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("set_external_pressure" in signal.data)
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("adjust_internal_pressure" in signal.data)
			internal_pressure_bound = between(
				0,
				internal_pressure_bound + text2num(signal.data["adjust_internal_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("adjust_external_pressure" in signal.data)
			external_pressure_bound = between(
				0,
				external_pressure_bound + text2num(signal.data["adjust_external_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("init" in signal.data)
			name = signal.data["init"]
			return

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon

			//log_admin("DEBUG \[[world.timeofday]\]: vent_pump/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
		spawn(2)
			broadcast_status()
		update_icon()
		return

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(welded)
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]weld"
			return
		if(on&&node)
			if(pump_direction)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
			if (W:remove_fuel(0,user))
				W:welding = 2
				user << "\blue Now welding the vent."
				if(do_after(user, 20))
					playsound(src.loc, 'Welder2.ogg', 50, 1)
					if(!welded)
						user.visible_message("[user] welds the vent shut.", "You weld the vent shut.", "You hear welding.")
						welded = 1
						update_icon()
					else
						user.visible_message("[user] unwelds the vent.", "You unweld the vent.", "You hear welding.")
						welded = 0
						update_icon()
				W:welding = 1
			else
				user << "\blue You need more welding fuel to complete this task."
				return 1
	examine()
		set src in oview(1)
		..()
		if(welded)
			usr << "It seems welded shut."

	power_change()
		if(powered(power_channel))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		update_icon()

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
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
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)
