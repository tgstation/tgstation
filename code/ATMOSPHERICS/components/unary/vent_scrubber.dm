/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'vent_scrubber.dmi'
	icon_state = "off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = 1

	var/id_tag = null
	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/scrub_CO2 = 1
	var/scrub_Toxins = 0
	var/scrub_N2O = 0

	var/volume_rate = 120
	var/panic = 0 //is this scrubber panicked?

	var/area_uid

	New()
		var/area/A = get_area(loc)
		if (A.master)
			A = A.master
		area_uid = A.uid
		id_tag = "\ref[src]"
		..()

	update_icon()
		if(node && on && !(stat & (NOPOWER|BROKEN)))
			if(scrubbing)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		return

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src
			signal.data["area"] = area_uid
			signal.data["tag"] = id_tag
			signal.data["device"] = "AScr"
			signal.data["timestamp"] = air_master.current_cycle
			signal.data["on"] = on
			signal.data["scrubbing"] = scrubbing
			signal.data["panic"] = panic
			signal.data["filter_co2"] = scrub_CO2
			signal.data["filter_toxins"] = scrub_Toxins
			signal.data["filter_n2o"] = scrub_N2O
			radio_connection.post_signal(src, signal)

			return 1

	initialize()
		..()
		if (frequency)
			set_frequency(frequency)


	process()
		..()
		if(stat & (NOPOWER|BROKEN))
			return
		if (!node)
			on = 0
		broadcast_status()
		if(!on)
			return 0


		var/datum/gas_mixture/environment = loc.return_air()

		if(scrubbing)
			if((environment.toxins>0) || (environment.carbon_dioxide>0) || (environment.trace_gases.len>0))
				var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

				//Take a gas sample
				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
				if (isnull(removed)) //in space
					return
				var/power = (scrub_Toxins+scrub_CO2+scrub_N2O)*volume_rate/12
				use_power(round(power+5), ENVIRON)
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
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas
						else if(istype(trace_gas, /datum/gas/sleeping_agent) && scrub_N2O)
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas


				//Remix the resulting gases
				air_contents.merge(filtered_out)

				loc.assume_air(removed)

				if(network)
					network.update = 1

		else //Just siphoning all air
			if (air_contents.return_pressure()>=50*ONE_ATMOSPHERE)
				return
			use_power(round(volume_rate/12)+5, ENVIRON)
			var/transfer_moles = environment.total_moles()*(volume_rate/environment.volume)

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

	receive_signal(datum/signal/signal)
		if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
			return ..()

		switch(signal.data["command"])
			if("toggle_power")
				on = !on
			if("toggle_scrubbing")
				scrubbing = !scrubbing
			if("toggle_co2_scrub")
				scrub_CO2 = !scrub_CO2
			if("toggle_tox_scrub")
				scrub_Toxins = !scrub_Toxins
			if("toggle_n2o_scrub")
				scrub_N2O = !scrub_N2O
			if("toggle_panic_siphon")
				panic = !panic
				if(panic)
					on = 1
					scrubbing = 0
					volume_rate = 2000
				else
					scrubbing = 1
					volume_rate = initial(volume_rate)
			if("init")
				name = signal.data["parameter"]
		if(signal.data["tag"])
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
