/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/atmospherics/vent_scrubber.dmi'
	icon_state = "off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"
	use_power = 1

	level = 1

	var/id_tag = null
	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/scrub_CO2 = 1
	var/scrub_Toxins = 0
	var/scrub_N2O = 0
	var/scrub_O2 = 0
	var/scrub_N2 = 0

	var/volume_rate = 1000 // 120
	var/panic = 0 //is this scrubber panicked?

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in
	New()
		..()
		area_uid = areaMaster.uid
		if (!id_tag)
			assign_uid()
			id_tag = num2text(uid)
		if(ticker && ticker.current_state == 3)//if the game is running
			src.initialize()
			src.broadcast_status()

	update_icon()
		var/hidden=""
		if(level == 1 && istype(loc, /turf/simulated))
			hidden="h"
		var/suffix=""
		if(scrub_O2)
			suffix="1"
		if(node && on && !(stat & (NOPOWER|BROKEN)))
			if(scrubbing)
				icon_state = "[hidden]on[suffix]"
			else
				icon_state = "[hidden]in"
		else
			icon_state = "[hidden]off"
		return

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src
			signal.data = list(
				"area" = area_uid,
				"tag" = id_tag,
				"device" = "AScr",
				"timestamp" = world.time,
				"power" = on,
				"scrubbing" = scrubbing,
				"panic" = panic,
				"filter_co2" = scrub_CO2,
				"filter_tox" = scrub_Toxins,
				"filter_n2o" = scrub_N2O,
				"filter_o2" = scrub_O2,
				"filter_n2" = scrub_N2,
				"sigtype" = "status"
			)
			if(!areaMaster.air_scrub_names[id_tag])
				var/new_name = "[areaMaster.name] Air Scrubber #[areaMaster.air_scrub_names.len+1]"
				areaMaster.air_scrub_names[id_tag] = new_name
				src.name = new_name
			areaMaster.air_scrub_info[id_tag] = signal.data
			radio_connection.post_signal(src, signal, radio_filter_out)

			return 1

	initialize()
		..()
		radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
		radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
		if (frequency)
			set_frequency(frequency)

	process()
		..()
		CHECK_DISABLED(scrubbers)
		if(stat & (NOPOWER|BROKEN))
			return
		if (!node)
			on = 0
		//broadcast_status()
		if(!on)
			return 0
		// New GC does this sometimes
		if(!loc) return


		var/datum/gas_mixture/environment = loc.return_air()

		if(scrubbing)
			// Are we scrubbing gasses that are present?
			if(\
				(scrub_Toxins && environment.toxins > 0) ||\
				(scrub_CO2 && environment.carbon_dioxide > 0) ||\
				(scrub_N2O && environment.trace_gases.len > 0) ||\
				(scrub_O2 && environment.oxygen > 0) ||\
				(scrub_N2 && environment.nitrogen > 0))
				var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

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

				if(scrub_O2)
					filtered_out.oxygen = removed.oxygen
					removed.oxygen = 0

				if(scrub_N2)
					filtered_out.nitrogen = removed.nitrogen
					removed.nitrogen = 0

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
		if(stat & (NOPOWER|BROKEN))
			return
		if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
			return 0

		if(signal.data["power"] != null)
			on = text2num(signal.data["power"])
		if(signal.data["power_toggle"] != null)
			on = !on

		if(signal.data["panic_siphon"]) //must be before if("scrubbing" thing
			panic = text2num(signal.data["panic_siphon"]) // We send 0 for false in the alarm.
			if(panic)
				on = 1
				scrubbing = 0
				volume_rate = 2000
			else
				scrubbing = 1
				volume_rate = initial(volume_rate)
		if(signal.data["toggle_panic_siphon"] != null)
			panic = !panic
			if(panic)
				on = 1
				scrubbing = 0
				volume_rate = 2000
			else
				scrubbing = 1
				volume_rate = initial(volume_rate)

		if(signal.data["scrubbing"] != null)
			scrubbing = text2num(signal.data["scrubbing"])
		if(signal.data["toggle_scrubbing"])
			scrubbing = !scrubbing

		if(signal.data["co2_scrub"] != null)
			scrub_CO2 = text2num(signal.data["co2_scrub"])
		if(signal.data["toggle_co2_scrub"])
			scrub_CO2 = !scrub_CO2

		if(signal.data["tox_scrub"] != null)
			scrub_Toxins = text2num(signal.data["tox_scrub"])
		if(signal.data["toggle_tox_scrub"])
			scrub_Toxins = !scrub_Toxins

		if(signal.data["n2o_scrub"] != null)
			scrub_N2O = text2num(signal.data["n2o_scrub"])
		if(signal.data["toggle_n2o_scrub"])
			scrub_N2O = !scrub_N2O

		if(signal.data["o2_scrub"] != null)
			scrub_O2 = text2num(signal.data["o2_scrub"])
		if(signal.data["toggle_o2_scrub"])
			scrub_O2 = !scrub_O2

		if(signal.data["n2_scrub"] != null)
			scrub_N2 = text2num(signal.data["n2_scrub"])
		if(signal.data["toggle_n2_scrub"])
			scrub_N2 = !scrub_N2

		if(signal.data["init"] != null)
			name = signal.data["init"]
			return

		if(signal.data["status"] != null)
			spawn(2)
				broadcast_status()
			return //do not update_icon

//			log_admin("DEBUG \[[world.timeofday]\]: vent_scrubber/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
		spawn(2)
			broadcast_status()
		update_icon()
		return

	power_change()
		if(powered(power_channel))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		update_icon()

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/device/multitool))
			update_multitool_menu(user)
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

	multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
		return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
			<li>[format_tag("ID Tag","id_tag")]</li>
		</ul>
		"}

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	areaMaster.air_scrub_info.Remove(id_tag)
	areaMaster.air_scrub_names.Remove(id_tag)
	..()
