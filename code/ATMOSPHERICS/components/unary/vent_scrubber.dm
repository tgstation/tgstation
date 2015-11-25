/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/atmospherics/vent_scrubber.dmi'
	icon_state = "hoff"
	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"
	use_power = 1

	level				= 1

	var/id_tag			= null
	var/frequency		= 1439
	var/datum/radio_frequency/radio_connection

	var/on				= 0
	var/scrubbing		= 1 //0 = siphoning, 1 = scrubbing
	var/scrub_CO2		= 1
	var/scrub_Toxins	= 1
	var/scrub_N2O		= 0
	var/scrub_O2		= 0
	var/scrub_N2		= 0

	var/volume_rate		= 1000 // 120
	var/panic			= 0 //is this scrubber panicked?
	var/welded			= 0

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in

	machine_flags		= MULTITOOL_MENU

/obj/machinery/atmospherics/unary/vent_scrubber/on
	on					= 1
	icon_state			= "on"

/obj/machinery/atmospherics/unary/vent_scrubber/on/burn_chamber
	name				= "\improper Burn Chamber Scrubber"

	frequency			= 1449
	id_tag				= "inc_out"

	scrub_Toxins		= 0

/obj/machinery/atmospherics/unary/vent_scrubber/New()
	..()
	area_uid = areaMaster.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	if(ticker && ticker.current_state == 3)//if the game is running
		//src.initialize()
		src.broadcast_status()

/obj/machinery/atmospherics/unary/vent_scrubber/update_icon()
	if(welded)
		icon_state = "hweld"
	var/suffix=""
	if(scrub_O2)
		suffix="1"
	if(node && on && !(stat & (NOPOWER|BROKEN)))
		if(scrubbing)
			icon_state = "hon[suffix]"
		else
			icon_state = "hin"
	else
		icon_state = "hoff"
	..()
	if (istype(loc, /turf/simulated/floor) && node)
		var/turf/simulated/floor/floor = loc
		if(floor.floor_tile && node.alpha == 128)
			underlays.Cut()
	return

/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

	if(frequency != 1439)
		areaMaster.air_scrub_info -= id_tag
		areaMaster.air_scrub_names -= id_tag
		name = "Air Scrubber"
	else
		broadcast_status()

/obj/machinery/atmospherics/unary/vent_scrubber/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	..()
	src.broadcast_status()
	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
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
	if(frequency == 1439)
		if(!areaMaster.air_scrub_names[id_tag])
			var/new_name = "[areaMaster.name] Air Scrubber #[areaMaster.air_scrub_names.len+1]"
			areaMaster.air_scrub_names[id_tag] = new_name
			src.name = new_name
		areaMaster.air_scrub_info[id_tag] = signal.data

	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/initialize()
	..()
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if (frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/unary/vent_scrubber/process()
	. = ..()
	CHECK_DISABLED(scrubbers)
	if(stat & (NOPOWER|BROKEN))
		return
	if (!node)
		return // Let's not shut it off, for now.
	if(welded)
		return
	//broadcast_status()
	if(!on)
		return
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

/obj/machinery/atmospherics/unary/vent_scrubber/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()
	return


/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command") || (signal.data["type"] && signal.data["type"] != "scrubber"))
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

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>Now welding the scrubber.</span>")
			if(do_after(user, src, 20))
				if(!src || !WT.isOn()) return
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
				if(!welded)
					user.visible_message("[user] welds the scrubber shut.", "You weld the vent scrubber.", "You hear welding.")
					welded = 1
					update_icon()
				else
					user.visible_message("[user] unwelds the scrubber.", "You unweld the scrubber.", "You hear welding.")
					welded = 0
					update_icon()
			else
				to_chat(user, "<span class='notice'>The welding tool needs to be on to start this task.</span>")
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return 1
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!(stat & NOPOWER) && on)
		to_chat(user, "<span class='warning'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag", "set_id")]</li>
	</ul>
	"}

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	areaMaster.air_scrub_info.Remove(id_tag)
	areaMaster.air_scrub_names.Remove(id_tag)
	..()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_topic(var/mob/user, var/list/href_list, var/obj/O)
	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(!newid)
			return

		if(frequency == 1439)
			areaMaster.air_scrub_info -= id_tag
			areaMaster.air_scrub_names -= id_tag

		id_tag = newid
		broadcast_status()

		return MT_UPDATE

	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/change_area(oldarea, newarea)
	areaMaster.air_scrub_info.Remove(id_tag)
	areaMaster.air_scrub_names.Remove(id_tag)
	..()
	name = replacetext(name,newarea,oldarea)
	area_uid = areaMaster.uid
	broadcast_status()

/obj/machinery/atmospherics/unary/vent_scrubber/canClone(var/obj/O)
	return istype(O, /obj/machinery/atmospherics/unary/vent_scrubber)

/obj/machinery/atmospherics/unary/vent_scrubber/clone(var/obj/machinery/atmospherics/unary/vent_scrubber/O)
	if(frequency == 1439) // Note: if the frequency stays at 1439 we'll be readded to the area in set_frequency().
		areaMaster.air_scrub_info -= id_tag
		areaMaster.air_scrub_names -= id_tag
	id_tag = O.id_tag

	set_frequency(O.frequency)
	return 1
