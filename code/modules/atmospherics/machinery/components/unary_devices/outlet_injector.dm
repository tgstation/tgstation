/obj/machinery/atmospherics/components/unary/outlet_injector
	name = "air injector"
	desc = "Has a valve and pump attached to it"
	icon_state = "inje_map"
	use_power = 1
	can_unwrench = TRUE

	var/on = 0
	var/injecting = 0

	var/volume_rate = 50

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	level = 1

/obj/machinery/atmospherics/components/unary/outlet_injector/Destroy()
	if(SSradio)
		SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/atmospherics/components/unary/outlet_injector/on
	on = 1

/obj/machinery/atmospherics/components/unary/outlet_injector/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "inje_cap", initialize_directions))

	if(!NODE1 || !on || stat & (NOPOWER|BROKEN))
		icon_state = "inje_off"
		return

	icon_state = "inje_on"

/obj/machinery/atmospherics/components/unary/outlet_injector/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()


/obj/machinery/atmospherics/components/unary/outlet_injector/process_atmos()
	..()
	injecting = 0

	if(!on || stat & (NOPOWER|BROKEN))
		return 0

	var/datum/gas_mixture/air_contents = AIR1

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)
		air_update_turf()

		update_parents()

	return 1

/obj/machinery/atmospherics/components/unary/outlet_injector/proc/inject()
	if(on || injecting || stat & (NOPOWER|BROKEN))
		return 0

	var/datum/gas_mixture/air_contents = AIR1

	injecting = 1

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		update_parents()

	flick("inje_inject", src)

/obj/machinery/atmospherics/components/unary/outlet_injector/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency)

/obj/machinery/atmospherics/components/unary/outlet_injector/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AO",
		"power" = on,
		"volume_rate" = volume_rate,
		//"timestamp" = world.time,
		"sigtype" = "status"
	 )

	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/components/unary/outlet_injector/atmosinit()
	set_frequency(frequency)
	broadcast_status()
	..()

/obj/machinery/atmospherics/components/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
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
		var/datum/gas_mixture/air_contents = AIR1
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

/obj/machinery/atmospherics/components/unary/outlet_injector/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		on = !on
		to_chat(user, "<span class='notice'>You turn [src] [on ? "on" :"off"].</span>")
		update_icon()
		broadcast_status()
		return 0
	else
		return ..()

/obj/machinery/atmospherics/components/unary/outlet_injector/can_unwrench(mob/user)
	if(..())
		if (!(stat & NOPOWER|BROKEN) && on)
			to_chat(user, "<span class='warning'> [src], turn it off first!</span>")
		else
			return 1

