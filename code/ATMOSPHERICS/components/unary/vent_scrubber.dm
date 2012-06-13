/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'vent_scrubber.dmi'
	icon_state = "off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = 1

	var/id_tag = null

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/scrub_CO2 = 1
	var/scrub_Toxins = 0
	var/scrub_N2O = 0
	var/scrub_rate = 1

	var/volume_rate = 120
	var/panic = 0 //is this scrubber panicked?

	var/area_uid
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
		if(alarm_area && "\"[id_tag]\"" in alarm_area.master.air_scrubbers)
			alarm_area.master.air_scrubbers.Remove("\"[id_tag]\"")
		..()

	initialize()
		spawn(20)
			broadcast_status()

	update_icon()
		if(node && on && !(stat & (NOPOWER|BROKEN)))
			if(scrubbing)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		return

	proc/broadcast_status()
		var/area/alarm_area = get_area(src)
		if(alarm_area.master.master_air_alarm)
			if(!id_tag)
				if(alarm_area.master.master_air_alarm)
					alarm_area.master.master_air_alarm.register_env_machine(src)
			else if(!"\"[id_tag]\"" in alarm_area.air_scrubbers)
				if(alarm_area.master.master_air_alarm)
					alarm_area.master.master_air_alarm.register_env_machine(src)
			else if(stat & (NOPOWER|BROKEN))
				alarm_area.master.air_scrubbers.Remove("\"[id_tag]\"")
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

		var/datum/gas_mixture/environment = loc.return_air()

		if(scrubbing)
			if((environment.toxins>0) || (environment.carbon_dioxide>0) || (environment.trace_gases.len>0))
				var/transfer_moles = min(1, volume_rate*scrub_rate/environment.volume)*environment.total_moles

				//Take a gas sample
				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
				if (isnull(removed)) //in space
					return

				//Filter it
				var/datum/gas_mixture/filtered_out = new
				filtered_out.temperature = removed.temperature
				if(scrub_Toxins)
					filtered_out.toxins = removed.toxins
					removed.toxins = 0
				if(scrub_CO2)
					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0

				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/sleeping_agent) && scrub_N2O)
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas


				//Remix the resulting gases
				filtered_out.update_values()
				removed.update_values()
				air_contents.merge(filtered_out)

				loc.assume_air(removed)

				if(network)
					network.update = 1

		else //Just siphoning all air
			if (air_contents.return_pressure()>=50*ONE_ATMOSPHERE)
				return

			var/transfer_moles = environment.total_moles*(volume_rate*scrub_rate/environment.volume)

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

			air_contents.merge(removed)

			if(network)
				network.update = 1

		return 1
/* //unused piece of code
	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(scrubbing)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return
*/

	proc/receive(var/list/signal)
		if(stat & (NOPOWER|BROKEN))
			return

		if("power" in signal)
			on = text2num(signal["power"])
		if("power_toggle" in signal)
			on = !on

		if("panic_siphon" in signal) //must be before if("scrubbing" thing
			panic = text2num(signal["panic_siphon"])
			if(panic)
				on = 1
				scrubbing = 0
				volume_rate = 2000
			else
				scrubbing = 1
				volume_rate = initial(volume_rate)
		if("toggle_panic_siphon" in signal)
			panic = !panic
			if(panic)
				on = 1
				scrubbing = 0
				volume_rate = 2000
			else
				scrubbing = 1
				volume_rate = initial(volume_rate)

		if("scrubbing" in signal)
			scrubbing = text2num(signal["scrubbing"])
		if("toggle_scrubbing" in signal)
			scrubbing = !scrubbing

		if("co2_scrub" in signal)
			scrub_CO2 = text2num(signal["co2_scrub"])
		if("toggle_co2_scrub" in signal)
			scrub_CO2 = !scrub_CO2

		if("tox_scrub" in signal)
			scrub_Toxins = text2num(signal["tox_scrub"])
		if("toggle_tox_scrub" in signal)
			scrub_Toxins = !scrub_Toxins

		if("n2o_scrub" in signal)
			scrub_N2O = text2num(signal["n2o_scrub"])
		if("toggle_n2o_scrub" in signal)
			scrub_N2O = !scrub_N2O

		if("init" in signal)
			name = signal["init"]
			return

		if("setting" in signal)
			scrub_rate = text2num(signal["setting"])

		spawn(2)
			broadcast_status()
		update_icon()
		return

	power_change()
		if(powered(ENVIRON))
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
