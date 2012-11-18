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
				signal.data["stabalize"] = 1
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
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Vent Controller"
	density = 0

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