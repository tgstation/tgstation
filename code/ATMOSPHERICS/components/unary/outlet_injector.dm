/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/obj/atmospherics/outlet_injector.dmi'
	icon_state = "off"
	use_power = 1

	name = "Air Injector"
	desc = "Has a valve and pump attached to it"

	var/on = 0
	var/injecting = 0

	var/volume_rate = 50
	var/max_rate=50

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	level = 1

	machine_flags = MULTITOOL_MENU

/obj/machinery/atmospherics/unary/outlet_injector/update_icon()
	if(node)
		if(on && !(stat & NOPOWER))
			icon_state = "hon"
		else
			icon_state = "hoff"
	else
		icon_state = "exposed"
		on = 0
	..()
	if (istype(loc, /turf/simulated/floor) && node)
		var/turf/simulated/floor/floor = loc
		if(floor.floor_tile && node.alpha == 128)
			underlays.Cut()
	return

/obj/machinery/atmospherics/unary/outlet_injector/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()


/obj/machinery/atmospherics/unary/outlet_injector/process()
	. = ..()
	injecting = 0

	if(!on || stat & NOPOWER)
		return

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		if(network)
			network.update = 1

	return 1

/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	if(on || injecting)
		return 0

	injecting = 1

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		if(network)
			network.update = 1

	flick("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/atmospherics/unary/outlet_injector/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "AO",
		"power" = on,
		"volume_rate" = volume_rate,
		//"timestamp" = world.time,
		"sigtype" = "status"
	 )

	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/unary/outlet_injector/initialize()
	..()

	set_frequency(frequency)

/obj/machinery/atmospherics/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command") || (signal.data["type"] && signal.data["type"] != "injector"))
		return 0

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("inject" in signal.data)
		spawn inject()
		return

	if("set_volume_rate" in signal.data)
		var/number = text2num(signal.data["set_volume_rate"])
		volume_rate = Clamp(number, 0, air_contents.volume)

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

		//log_admin("DEBUG \[[world.timeofday]\]: outlet_injector/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
		//return
	spawn(2)
		broadcast_status()
	update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/hide(var/i) //to make the little pipe section invisible, the icon changes.
	if(node)
		if(on)
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
	else
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]exposed"
		on = 0
	return

/obj/machinery/atmospherics/unary/outlet_injector/interact(mob/user as mob)
	update_multitool_menu(user)

/obj/machinery/atmospherics/unary/outlet_injector/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
"}

/obj/machinery/atmospherics/unary/outlet_injector/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!(stat & NOPOWER) && on)
		to_chat(user, "<span class='warning'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()

/obj/machinery/atmospherics/unary/outlet_injector/canClone(var/obj/O)
	return istype(O, /obj/machinery/atmospherics/unary/outlet_injector)

/obj/machinery/atmospherics/unary/outlet_injector/clone(var/obj/machinery/atmospherics/unary/outlet_injector/O)
	id_tag = O.id_tag
	set_frequency(O.frequency)
	return 1
