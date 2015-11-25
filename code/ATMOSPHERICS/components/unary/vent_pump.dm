/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/obj/atmospherics/vent_pump.dmi'
	icon_state = "hoff"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it"
	use_power = 1

	level = 1
	var/area_uid
	var/id_tag = null

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/internal_pressure_bound = 0

	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	var/welded = 0 // Added for aliens -- TLE
	var/canSpawnMice = 1 // Set to 0 to prevent spawning of mice.

	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/radio_filter_out
	var/radio_filter_in

	machine_flags = MULTITOOL_MENU

	starting_volume = 400 // Previously 200

/obj/machinery/atmospherics/unary/vent_pump/on
	on = 1
	icon_state = "hout"

/obj/machinery/atmospherics/unary/vent_pump/siphon
	pump_direction = 0
	icon_state = "hoff"

/obj/machinery/atmospherics/unary/vent_pump/siphon/on
	on = 1
	icon_state = "hin"

/obj/machinery/atmospherics/unary/vent_pump/New()
	..()
	area_uid = areaMaster.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	if(ticker && ticker.current_state == 3)//if the game is running
		//src.initialize()
		src.broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "Large Air Vent"
	power_channel = EQUIP

/obj/machinery/atmospherics/unary/vent_pump/high_volume/New()
	..()
	air_contents.volume = 1000

/obj/machinery/atmospherics/unary/vent_pump/update_icon()
	if(welded)
		icon_state = "hweld"
		return
	if(on && !(stat & (NOPOWER|BROKEN)))
		if(pump_direction)
			icon_state = "hout"
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

/obj/machinery/atmospherics/unary/vent_pump/process()
	. = ..()
	CHECK_DISABLED(vents)
	if (!node)
		return // Turning off the vent is a PITA. - N3X
	if(stat & (NOPOWER|BROKEN))
		return
		//on = 0

	//broadcast_status() // from now air alarm/control computer should request update purposely --rastaf0
	if(!on)
		return

	if(welded)
		return

	// New GC does this sometimes
	if(!loc) return

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(pump_direction) //internal -> external
		var/pressure_delta = 10000

		if(pressure_checks&1)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&2)
			pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

		if(pressure_delta > 0.1)
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

		if(pressure_delta > 0.1)
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

/obj/machinery/atmospherics/unary/vent_pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency,radio_filter_in)

	if(frequency != 1439)
		areaMaster.air_vent_info -= id_tag
		areaMaster.air_vent_names -= id_tag
		name = "Vent Pump"
	else
		broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	..()
	src.broadcast_status()
	return 1

/obj/machinery/atmospherics/unary/vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
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

	if(frequency == 1439)
		if(!areaMaster.air_vent_names[id_tag])
			var/new_name = "[areaMaster.name] Vent Pump #[areaMaster.air_vent_names.len+1]"
			areaMaster.air_vent_names[id_tag] = new_name
			name = new_name
		areaMaster.air_vent_info[id_tag] = signal.data

	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1


/obj/machinery/atmospherics/unary/vent_pump/initialize()
	..()

	//some vents work his own spesial way
	radio_filter_in = frequency==1439?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==1439?(RADIO_TO_AIRALARM):null
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/unary/vent_pump/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/atmospherics/unary/vent_pump/receive_signal([signal.debug_print()])")
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command") || (signal.data["type"] && signal.data["type"] != "vent"))
		return 0

	var/handled=0
	if("purge" in signal.data)
		pressure_checks &= ~1
		pump_direction = 0
		handled=1

	if("stabilize" in signal.data)
		pressure_checks |= 1
		pump_direction = 1
		handled = 1

	if("power" in signal.data)
		on = text2num(signal.data["power"])
		handled = 1

	if("power_toggle" in signal.data)
		on = !on
		handled = 1

	if("checks" in signal.data)
		pressure_checks = text2num(signal.data["checks"])
		handled = 1

	if("checks_toggle" in signal.data)
		pressure_checks = (pressure_checks?0:3)
		handled = 1

	if("direction" in signal.data)
		pump_direction = text2num(signal.data["direction"])
		handled = 1

	if("set_internal_pressure" in signal.data)
		internal_pressure_bound = Clamp(text2num(signal.data["set_internal_pressure"]), 0, ONE_ATMOSPHERE * 50)
		handled =1

	if("set_external_pressure" in signal.data)
		external_pressure_bound = Clamp(text2num(signal.data["set_external_pressure"]), 0, ONE_ATMOSPHERE * 50)
		handled = 1

	if("adjust_internal_pressure" in signal.data)
		internal_pressure_bound = Clamp(internal_pressure_bound + text2num(signal.data["adjust_internal_pressure"]), 0, ONE_ATMOSPHERE * 50)
		handled = 1

	if("adjust_external_pressure" in signal.data)
		external_pressure_bound = Clamp(external_pressure_bound + text2num(signal.data["adjust_external_pressure"]), 0, ONE_ATMOSPHERE * 50)
		handled = 1

	if("init" in signal.data)
		name = signal.data["init"]
		return

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	if(!handled)
		testing("\[[world.timeofday]\]: vent_pump/receive_signal: unknown command \n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_pump/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	..()
	if(welded)
		to_chat(user, "<span class='info'>It seems welded shut.</span>")

/obj/machinery/atmospherics/unary/vent_pump/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/atmospherics/unary/vent_pump/interact(mob/user as mob)
	update_multitool_menu(user)

/obj/machinery/atmospherics/unary/vent_pump/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</li>
	</ul>
	"}

/obj/machinery/atmospherics/unary/vent_pump/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/unary/vent_pump/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>Now welding the vent.</span>")
			if(do_after(user, src, 20))
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

/obj/machinery/atmospherics/unary/vent_pump/Destroy()
	areaMaster.air_vent_info.Remove(id_tag)
	areaMaster.air_vent_names.Remove(id_tag)
	..()

/obj/machinery/atmospherics/unary/vent_pump/multitool_topic(var/mob/user, var/list/href_list, var/obj/O)
	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src.id_tag) as null|text), 1, MAX_MESSAGE_LEN)
		if(!newid)
			return
		if(frequency == 1439)
			areaMaster.air_vent_info -= id_tag
			areaMaster.air_vent_names -= id_tag

		id_tag = newid
		broadcast_status()

		return MT_UPDATE

	return ..()

/obj/machinery/atmospherics/unary/vent_pump/change_area(oldarea, newarea)
	areaMaster.air_vent_info.Remove(id_tag)
	areaMaster.air_vent_names.Remove(id_tag)
	..()
	name = replacetext(name,newarea,oldarea)
	area_uid = areaMaster.uid
	broadcast_status()

/obj/machinery/atmospherics/unary/vent_pump/canClone(var/obj/O)
	return istype(O, /obj/machinery/atmospherics/unary/vent_pump)

/obj/machinery/atmospherics/unary/vent_pump/clone(var/obj/machinery/atmospherics/unary/vent_pump/O)
	if(frequency == 1439) // Note: if the frequency stays at 1439 we'll be readded to the area in set_frequency().
		areaMaster.air_vent_info -= id_tag
		areaMaster.air_vent_names -= id_tag
	id_tag = O.id_tag

	set_frequency(O.frequency)
	return 1
