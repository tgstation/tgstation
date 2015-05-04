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

	var/list/scrubbing_gases = list(CARBON_DIOXIDE, //list of gas ids we scrub
									PLASMA,
									NITROUS_OXIDE)

	var/volume_rate = 1000 // 120
	var/panic = 0 //is this scrubber panicked?
	var/welded = 0

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in

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
	var/hidden=""
	if(level == 1 && istype(loc, /turf/simulated))
		hidden="h"
	if(welded)
		icon_state = "[hidden]weld"
		return
	var/suffix=""
	if(OXYGEN in scrubbing_gases)
		suffix="1"
	if(node && on && !(stat & (NOPOWER|BROKEN)))
		if(scrubbing)
			icon_state = "[hidden]on[suffix]"
		else
			icon_state = "[hidden]in"
	else
		icon_state = "[hidden]off"
	return

/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/unary/vent_scrubber/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	..()
	src.broadcast_status()
	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
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
		"filter_co2" = (CARBON_DIOXIDE in scrubbing_gases),
		"filter_tox" = (PLASMA in scrubbing_gases),
		"filter_n2o" = (NITROUS_OXIDE in scrubbing_gases),
		"filter_o2" = (OXYGEN in scrubbing_gases),
		"filter_n2" = (NITROGEN in scrubbing_gases),
		"sigtype" = "status"
	)
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
	..()
	CHECK_DISABLED(scrubbers)
	if(stat & (NOPOWER|BROKEN))
		return
	if (!node)
		return 0 // Let's not shut it off, for now.
	if(welded)
		return 0
	//broadcast_status()
	if(!on)
		return 0
	// New GC does this sometimes
	if(!loc) return


	var/datum/gas_mixture/environment = loc.return_air()

	if(scrubbing)
		if(scrubbing_gases.len)
			var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

			//Take a gas sample
			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			if (isnull(removed)) //in space
				return

			var/datum/gas_mixture/filtered_out = new

			for(var/gasid in removed.gases)
				if(!(gasid in scrubbing_gases))
					continue

				filtered_out.adjust_gas(gasid, removed.get_moles_by_id(gasid), 0) //move to filtered
				removed.set_gas(gasid, 0, 0) //set to 0

			//Filter it

			filtered_out.temperature = removed.temperature

			filtered_out.update_values()
			removed.update_values()

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
/obj/machinery/atmospherics/unary/vent_scrubber/hide(var/i) //to make the little pipe section invisible, the icon changes.
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

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
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
		toggle_gas_scrub(CARBON_DIOXIDE, text2num(signal.data["co2_scrub"]))
	if(signal.data["toggle_co2_scrub"])
		toggle_gas_scrub(CARBON_DIOXIDE)

	if(signal.data["tox_scrub"] != null)
		toggle_gas_scrub(PLASMA, text2num(signal.data["tox_scrub"]))
	if(signal.data["toggle_tox_scrub"])
		toggle_gas_scrub(PLASMA)

	if(signal.data["n2o_scrub"] != null)
		toggle_gas_scrub(NITROUS_OXIDE, text2num(signal.data["n2o_scrub"]))
	if(signal.data["toggle_n2o_scrub"])
		toggle_gas_scrub(NITROUS_OXIDE)

	if(signal.data["o2_scrub"] != null)
		toggle_gas_scrub(OXYGEN, text2num(signal.data["o2_scrub"]))
	if(signal.data["toggle_o2_scrub"])
		toggle_gas_scrub(OXYGEN)

	if(signal.data["n2_scrub"] != null)
		toggle_gas_scrub(NITROGEN, text2num(signal.data["n2_scrub"]))
	if(signal.data["toggle_n2_scrub"])
		toggle_gas_scrub(NITROGEN)

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

//forcestate 1 turns scrubbing on, forcestate -1 turns scrubbing off. Otherwise, it toggles
/obj/machinery/atmospherics/unary/vent_scrubber/proc/toggle_gas_scrub(gasid, forcestate)
	if(!forcestate)
		if(gasid in scrubbing_gases)
			scrubbing_gases -= gasid
		else
			scrubbing_gases += gasid
	else
		switch(forcestate)
			if(1)
				scrubbing_gases |= gasid //adds it if it's not added already
			if(-1)
				scrubbing_gases -= gasid //since this only works if it's in, we remove it

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			user << "<span class='notice'>Now welding the scrubber.</span>"
			if(do_after(user, 20))
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
				user << "<span class='notice'>The welding tool needs to be on to start this task.</span>"
		else
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
			return 1
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!(stat & NOPOWER) && on)
		user << "<span class='warning'>You cannot unwrench this [src], turn it off first.</span>"
		return 1
	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
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
