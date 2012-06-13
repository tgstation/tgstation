/obj/machinery/atmospherics/unary/vent_pump
	icon = 'vent_pump.dmi'
	icon_state = "off"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it"

	level = 1
	var/area_uid
	var/id_tag
	power_channel = ENVIRON

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing
	var/pump_speed = 1 //Used to adjust speed for siphons

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/internal_pressure_bound = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	var/welded = 0 // Added for aliens -- TLE

	New()
		var/area/A = get_area(loc)
		if (A.master)
			A = A.master
		area_uid = A.uid
		if (!id_tag)
			assign_uid()
			id_tag = num2text(uid)
		if(ticker && ticker.current_state == 3)//if the game is running
			initialize()
			broadcast_status()
		..()

	Del()
		var/area/alarm_area = get_area(src)
		if(alarm_area && "\"[id_tag]\"" in alarm_area.master.air_vents)
			alarm_area.master.air_vents.Remove("\"[id_tag]\"")
		..()

	high_volume
		name = "Large Air Vent"

		New()
			..()
			air_contents.volume = 1000

	initialize()
		spawn(20)
			broadcast_status()

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
		broadcast_status()
		if(stat & (NOPOWER|BROKEN))
			return
		if (!node)
			on = 0

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
					var/transfer_moles = pressure_delta*environment.volume*environment.group_multiplier*pump_speed/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

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
					var/transfer_moles = pressure_delta*air_contents.volume*air_contents.group_multiplier*pump_speed/(environment.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
					if (isnull(removed)) //in space
						return

					air_contents.merge(removed)

					if(network)
						network.update = 1

		return 1




	proc/broadcast_status()
		var/area/alarm_area = get_area(src)
		if(alarm_area.master.master_air_alarm)
			if(!id_tag)
				if(alarm_area.master.master_air_alarm)
					alarm_area.master.master_air_alarm.register_env_machine(src)
					world << "No ID, air alarm. New ID = [id_tag]"
				else
					world << "No ID, no air alarm."
			else if(!"\"[id_tag]\"" in alarm_area.air_vents)
				if(alarm_area.master.master_air_alarm)
					alarm_area.master.master_air_alarm.register_env_machine(src)
					world << "ID, air alarm. New ID = [id_tag]"
				else
					world << "ID = [id_tag], no air alarm."
			else if(stat & (NOPOWER|BROKEN))
				alarm_area.master.air_vents.Remove("\"[id_tag]\"")
				world << "Broken"
		else
			world << "Trying to register (No alarm)"


	proc/receive(var/list/signal)
		if(stat & (NOPOWER|BROKEN))
			return

		if("purge" in signal)
			pressure_checks &= ~1
			pump_direction = 0

		if("stabalize" in signal)
			pressure_checks |= 1
			pump_direction = 1

		if("power" in signal)
			on = text2num(signal["power"])

		if("power_toggle" in signal)
			on = !on

		if("checks" in signal)
			pressure_checks = text2num(signal["checks"])

		if("checks_toggle" in signal)
			pressure_checks = (pressure_checks?0:3)

		if("direction" in signal)
			pump_direction = text2num(signal["direction"])

		if("set_internal_pressure" in signal)
			internal_pressure_bound = between(0, text2num(signal["set_internal_pressure"]), ONE_ATMOSPHERE*50)

		if("set_external_pressure" in signal)
			external_pressure_bound = between(0, text2num(signal["set_external_pressure"]), ONE_ATMOSPHERE*50)

		if("adjust_internal_pressure" in signal)
			internal_pressure_bound = between(0, text2num(signal["adjust_internal_pressure"]), ONE_ATMOSPHERE*50)

		if("adjust_external_pressure" in signal)
			external_pressure_bound = between(0, text2num(signal["adjust_external_pressure"]), ONE_ATMOSPHERE*50)

		if("init" in signal)
			name = signal["init"]
			return

		if("setting" in signal)
			pump_speed = text2num(signal["setting"])

			//log_admin("DEBUG \[[world.timeofday]\]: vent_pump/receive_signal: unknown command \"[signal["command"]]\"\n[signal.debug_print()]")
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
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if (WT.remove_fuel(0,user))
				user << "\blue Now welding the vent."
				if(do_after(user, 20))
					if(!src || !WT.isOn()) return
					playsound(src.loc, 'Welder2.ogg', 50, 1)
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
