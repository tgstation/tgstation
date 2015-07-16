/obj/machinery/atmospherics/components/unary/vent_scrubber
	icon_state = "scrub_map"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it"
	use_power = 1

	level = 1

	can_unwrench = 1

	var/area/initial_loc
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
	var/radio_filter_out
	var/radio_filter_in


/obj/machinery/atmospherics/components/unary/vent_scrubber/New()
	..()
	initial_loc = get_area(loc)
	if (initial_loc.master)
		initial_loc = initial_loc.master
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	if(ticker && ticker.current_state == 3)//if the game is running
		src.atmosinit()
		src.initialize()
		src.broadcast_status()

/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_icon_nopipes()
	overlays.Cut()
	if(showpipe)
		overlays += getpipeimage('icons/obj/atmospherics/components/unary_devices.dmi', "scrub_cap", initialize_directions)

	if(welded)
		icon_state = "scrub_welded"
		return

	if(!nodes[NODE1] || !on || stat & (NOPOWER|BROKEN))
		icon_state = "scrub_off"
		return

	if(scrubbing)
		icon_state = "scrub_on"
	else
		icon_state = "scrub_purge"

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/broadcast_status()
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
		"filter_toxins" = scrub_Toxins,
		"filter_NODE2o" = scrub_N2O,
		"sigtype" = "status"
	)
	if(!initial_loc.air_scrub_names[id_tag])
		var/new_name = "\improper [initial_loc.name] air scrubber #[initial_loc.air_scrub_names.len+1]"
		initial_loc.air_scrub_names[id_tag] = new_name
		src.name = new_name
	initial_loc.air_scrub_info[id_tag] = signal.data
	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1

/obj/machinery/atmospherics/components/unary/vent_scrubber/atmosinit()
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if (frequency)
		set_frequency(frequency)
	..()
/obj/machinery/atmospherics/components/unary/vent_scrubber/initialize()
	..()
	broadcast_status()


/obj/machinery/atmospherics/components/unary/vent_scrubber/process_atmos()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!nodes[NODE1])
		on = 0
	//broadcast_status()
	if(!on || welded)
		return 0

	var/datum/gas_mixture/air_contents = airs[AIR1]
	var/datum/gas_mixture/environment = loc.return_air()

	if(scrubbing)
		if((environment.toxins>0) || (environment.carbon_dioxide>0) || (environment.trace_gases.len>0))
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
			air_update_turf()

	else //Just siphoning all air
		if (air_contents.return_pressure()>=50*ONE_ATMOSPHERE)
			return

		var/transfer_moles = environment.total_moles()*(volume_rate/environment.volume)

		var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

		air_contents.merge(removed)
		air_update_turf()

	update_parents()

	return 1

/obj/machinery/atmospherics/components/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if("power" in signal.data)
		on = text2num(signal.data["power"])
	if("power_toggle" in signal.data)
		on = !on

	if("panic_siphon" in signal.data) //must be before if("scrubbing" thing
		panic = text2num(signal.data["panic_siphon"])
		if(panic)
			on = 1
			scrubbing = 0
			volume_rate = 2000
		else
			scrubbing = 1
			volume_rate = initial(volume_rate)
	if("toggle_panic_siphon" in signal.data)
		panic = !panic
		if(panic)
			on = 1
			scrubbing = 0
			volume_rate = 2000
		else
			scrubbing = 1
			volume_rate = initial(volume_rate)

	if("scrubbing" in signal.data)
		scrubbing = text2num(signal.data["scrubbing"])
	if("toggle_scrubbing" in signal.data)
		scrubbing = !scrubbing

	if("co2_scrub" in signal.data)
		scrub_CO2 = text2num(signal.data["co2_scrub"])
	if("toggle_co2_scrub" in signal.data)
		scrub_CO2 = !scrub_CO2

	if("tox_scrub" in signal.data)
		scrub_Toxins = text2num(signal.data["tox_scrub"])
	if("toggle_tox_scrub" in signal.data)
		scrub_Toxins = !scrub_Toxins

	if("NODE2o_scrub" in signal.data)
		scrub_N2O = text2num(signal.data["n2o_scrub"])
	if("toggle_NODE2o_scrub" in signal.data)
		scrub_N2O = !scrub_N2O

	if("init" in signal.data)
		name = signal.data["init"]
		return

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

//		log_admin("DEBUG \[[world.timeofday]\]: vent_scrubber/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/components/unary/vent_scrubber/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_scrubber/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			playsound(loc, 'sound/items/Welder.ogg', 40, 1)
			user << "<span class='notice'>Now welding the scrubber.</span>"
			if(do_after(user, 20, target = src))
				if(!src || !WT.isOn())
					return
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				if(!welded)
					user.visible_message("[user] welds the scrubber shut.","You weld the scrubber shut.", "You hear welding.")
					welded = 1
					update_icon()
				else
					user.visible_message("[user] unwelds the scrubber.", "You unweld the scrubber.", "You hear welding.")
					welded = 0
					update_icon()
			return 1
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!(stat & NOPOWER) && on)
		user << "<span class='warning'>You cannot unwrench this [src], turn it off first!</span>"
		return 1
	return ..()


/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	if(initial_loc)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag
	..()


/obj/machinery/atmospherics/components/unary/vent_scrubber/can_crawl_through()
	return !welded
