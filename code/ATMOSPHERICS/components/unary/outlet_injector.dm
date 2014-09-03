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

	update_icon()
		if(node)
			if(on && !(stat & NOPOWER))
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		else
			icon_state = "exposed"
			on = 0

		return

	power_change()
		var/old_stat = stat
		..()
		if(old_stat != stat)
			update_icon()


	process()
		..()
		injecting = 0

		if(!on || stat & NOPOWER)
			return 0

		if(air_contents.temperature > 0)
			var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			loc.assume_air(removed)

			if(network)
				network.update = 1

		return 1

	proc/inject()
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

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency)

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
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

	initialize()
		..()

		set_frequency(frequency)

	receive_signal(datum/signal/signal)
		if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
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
			volume_rate = between(0, number, air_contents.volume)

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon

			//log_admin("DEBUG \[[world.timeofday]\]: outlet_injector/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
			//return
		spawn(2)
			broadcast_status()
		update_icon()

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(node)
			if(on)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]exposed"
			on = 0
		return

	interact(mob/user as mob)
		update_multitool_menu(user)

	multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
		return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
			<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
		</ul>
"}

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/device/multitool))
			interact(user)
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