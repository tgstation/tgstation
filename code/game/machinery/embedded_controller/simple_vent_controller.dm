/datum/computer/file/embedded_program/simple_vent_controller

	var/airpump_tag

	receive_user_command(command)
		switch(command)
			if("vent_inactive")
				var/datum/signal/signal = new
				signal.data = list(
					"tag" = airpump_tag,
					"sigtype"="command"
				)
				signal.data["power"] = 0
				post_signal(signal)

			if("vent_pump")
				var/datum/signal/signal = new
				signal.data = list(
					"tag" = airpump_tag,
					"sigtype"="command"
				)
				signal.data["stabilize"] = 1
				signal.data["power"] = 1
				post_signal(signal)

			if("vent_clear")
				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.data = list(
					"tag" = airpump_tag,
					"sigtype"="command"
				)
				signal.data["purge"] = 1
				signal.data["power"] = 1
				post_signal(signal)

	process()
		return 0


/obj/machinery/embedded_controller/radio/simple_vent_controller
	boardtype = /obj/item/weapon/circuitboard/ecb/vent_controller

	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Vent Controller"
	density = 0
	unacidable = 1

	frequency = 1229
	power_channel = ENVIRON

	// Setup parameters only
	var/airpump_tag

	initialize()
		..()

		var/datum/computer/file/embedded_program/simple_vent_controller/new_prog = new

		new_prog.airpump_tag = airpump_tag
		new_prog.master = src
		program = new_prog

	update_icon()
		if(on && program)
			icon_state = "airlock_control_standby"
		else
			icon_state = "airlock_control_off"


	return_text()
		var/state_options = null
		state_options = {"<A href='?src=\ref[src];command=vent_inactive'>Deactivate Vent</A><BR>
<A href='?src=\ref[src];command=vent_pump'>Activate Vent / Pump</A><BR>
<A href='?src=\ref[src];command=vent_clear'>Activate Vent / Clear</A><BR>"}
		var/output = {"<B>Vent Control Console</B><HR>
[state_options]<HR>"}

		return output

	multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
		return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1229]">Reset</a>)</li>
			<li>[format_tag("Pump ID","airpump_tag")]</li>
		</ul>"}

	Topic(href, href_list)
		if(..())
			return

		if(!issilicon(usr))
			if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
				return

		if("set_freq" in href_list)
			var/newfreq=frequency
			if(href_list["set_freq"]!="-1")
				newfreq=text2num(href_list["set_freq"])
			else
				newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, frequency) as null|num
			if(newfreq)
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place
				if(newfreq < 10000)
					frequency = newfreq
					initialize()

		usr.set_machine(src)
		update_multitool_menu(usr)