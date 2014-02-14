//States for airlock_control
#define AIRLOCK_STATE_INOPEN		-2
#define AIRLOCK_STATE_PRESSURIZE	-1
#define AIRLOCK_STATE_CLOSED		0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_OUTOPEN		2
#define AIRLOCK_STATE_BOTHOPEN		3

datum/computer/file/embedded_program/airlock_controller
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sensor_tag_int
	var/sanitize_external

	state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED
	var/sensor_pressure = null
	var/int_sensor_pressure = ONE_ATMOSPHERE

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==sensor_tag)
			if("pressure" in signal.data)
				sensor_pressure = signal.data["pressure"]
		else if(receive_tag==sensor_tag_int)
			if("pressure" in signal.data)
				int_sensor_pressure = signal.data["pressure"]

		else if(receive_tag==exterior_door_tag)
			memory["exterior_status"] = signal.data["door_status"]
			if(signal.data["bumped_with_access"])
				target_state = AIRLOCK_STATE_OUTOPEN

		else if(receive_tag==interior_door_tag)
			memory["interior_status"] = signal.data["door_status"]
			if(signal.data["bumped_with_access"])
				target_state = AIRLOCK_STATE_INOPEN

		else if(receive_tag==airpump_tag)
			if(signal.data["power"])
				memory["pump_status"] = signal.data["direction"]
			else
				memory["pump_status"] = "off"

		else if(receive_tag==id_tag)
			switch(signal.data["command"])
				if("cycle_exterior")
					target_state = AIRLOCK_STATE_OUTOPEN
				if("cycle_interior")
					target_state = AIRLOCK_STATE_INOPEN
				if("cycle")
					if(state < AIRLOCK_STATE_CLOSED)
						target_state = AIRLOCK_STATE_OUTOPEN
					else
						target_state = AIRLOCK_STATE_INOPEN
				if("cycle_interior")
					target_state = AIRLOCK_STATE_INOPEN
				if("cycle_exterior")
					target_state = AIRLOCK_STATE_OUTOPEN

	receive_user_command(command)
		switch(command)
			if("cycle_closed")
				target_state = AIRLOCK_STATE_CLOSED
			if("cycle_exterior")
				target_state = AIRLOCK_STATE_OUTOPEN
			if("cycle_interior")
				target_state = AIRLOCK_STATE_INOPEN
			if("abort")
				target_state = AIRLOCK_STATE_CLOSED
			if("force_both")
				target_state = AIRLOCK_STATE_BOTHOPEN
				state = AIRLOCK_STATE_BOTHOPEN
				var/datum/signal/signal = new
				signal.data["tag"] = interior_door_tag
				signal.data["command"] = "secure_open"
				post_signal(signal)
				signal = new
				signal.data["tag"] = exterior_door_tag
				signal.data["command"] = "secure_open"
				post_signal(signal)
			if("force_exterior")
				target_state = AIRLOCK_STATE_OUTOPEN
				state = AIRLOCK_STATE_OUTOPEN
				var/datum/signal/signal = new
				signal.data["tag"] = exterior_door_tag
				signal.data["command"] = "secure_open"
				post_signal(signal)
			if("force_interior")
				target_state = AIRLOCK_STATE_INOPEN
				state = AIRLOCK_STATE_INOPEN
				var/datum/signal/signal = new
				signal.data["tag"] = interior_door_tag
				signal.data["command"] = "secure_open"
				post_signal(signal)
			if("close")
				target_state = AIRLOCK_STATE_CLOSED
				state = AIRLOCK_STATE_CLOSED
				var/datum/signal/signal = new
				signal.data["tag"] = exterior_door_tag
				signal.data["command"] = "secure_close"
				post_signal(signal)
				signal = new
				signal.data["tag"] = interior_door_tag
				signal.data["command"] = "secure_close"
				post_signal(signal)

	process()
		var/process_again = 1
		while(process_again)
			process_again = 0
			switch(state)
				if(AIRLOCK_STATE_INOPEN) // state -2
					if(target_state > state)
						if(memory["interior_status"] == "closed")
							state = AIRLOCK_STATE_CLOSED
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)
					else
						if(memory["pump_status"] != "off")
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"power" = 0,
								"sigtype"="command"
							)
							post_signal(signal)

				if(AIRLOCK_STATE_PRESSURIZE)
					if(target_state < state)
						if(sensor_pressure >= int_sensor_pressure*0.95)
							if(memory["interior_status"] == "open")
								state = AIRLOCK_STATE_INOPEN
								process_again = 1
							else
								var/datum/signal/signal = new
								signal.data["tag"] = interior_door_tag
								signal.data["command"] = "secure_open"
								post_signal(signal)
						else
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"sigtype"="command"
							)
							if(memory["pump_status"] == "siphon")
								signal.data["stabilize"] = 1
							else if(memory["pump_status"] != "release")
								signal.data["power"] = 1
							post_signal(signal)
					else if(target_state > state)
						state = AIRLOCK_STATE_CLOSED
						process_again = 1

				if(AIRLOCK_STATE_CLOSED)
					if(target_state > state)
						if(memory["interior_status"] == "closed")
							state = AIRLOCK_STATE_DEPRESSURIZE
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)
					else if(target_state < state)
						if(memory["exterior_status"] == "closed")
							state = AIRLOCK_STATE_PRESSURIZE
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)

					else
						if(memory["pump_status"] != "off")
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"power" = 0,
								"sigtype"="command"
							)
							post_signal(signal)

				if(AIRLOCK_STATE_DEPRESSURIZE)
					var/target_pressure = ONE_ATMOSPHERE*0.04
					if(sanitize_external)
						target_pressure = ONE_ATMOSPHERE*0.01

					if(sensor_pressure <= target_pressure)
						if(target_state > state)
							if(memory["exterior_status"] == "open")
								state = AIRLOCK_STATE_OUTOPEN
							else
								var/datum/signal/signal = new
								signal.data["tag"] = exterior_door_tag
								signal.data["command"] = "secure_open"
								post_signal(signal)
						else if(target_state < state)
							state = AIRLOCK_STATE_CLOSED
							process_again = 1
					else if((target_state < state) && !sanitize_external)
						state = AIRLOCK_STATE_CLOSED
						process_again = 1
					else
						var/datum/signal/signal = new
						signal.transmission_method = 1 //radio signal
						signal.data = list(
							"tag" = airpump_tag,
							"sigtype"="command"
						)
						if(memory["pump_status"] == "release")
							signal.data["purge"] = 1
						else if(memory["pump_status"] != "siphon")
							signal.data["power"] = 1
						post_signal(signal)

				if(AIRLOCK_STATE_OUTOPEN) //state 2
					if(target_state < state)
						if(memory["exterior_status"] == "closed")
							if(sanitize_external)
								state = AIRLOCK_STATE_DEPRESSURIZE
								process_again = 1
							else
								state = AIRLOCK_STATE_CLOSED
								process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)
					else
						if(memory["pump_status"] != "off")
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"power" = 0,
								"sigtype"="command"
							)
							post_signal(signal)

		memory["sensor_pressure"] = sensor_pressure
		memory["int_sensor_pressure"] = int_sensor_pressure
		memory["processing"] = state != target_state
		//sensor_pressure = null //not sure if we can comment this out. Uncomment in case of problems -rastaf0

		return 1


obj/machinery/embedded_controller/radio/airlock_controller
	boardtype = /obj/item/weapon/circuitboard/ecb/airlock_controller

	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Airlock Console"
	density = 0
	unacidable = 1

	frequency = 1449
	power_channel = ENVIRON

	// Setup parameters only
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sensor_tag_int
	var/sanitize_external

	initialize()
		..()

		var/datum/computer/file/embedded_program/airlock_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.exterior_door_tag = exterior_door_tag
		new_prog.interior_door_tag = interior_door_tag
		new_prog.airpump_tag = airpump_tag
		new_prog.sensor_tag = sensor_tag
		new_prog.sensor_tag_int = sensor_tag_int
		new_prog.sanitize_external = sanitize_external

		new_prog.master = src
		program = new_prog

	multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
		return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1449]">Reset</a>)</li>
			<li>[format_tag("ID Tag","id_tag")]</li>
			<li>[format_tag("Pump ID","airpump_tag")]</li>
			<li><b>Sanitize:</b> <a href="?src=\ref[src];toggle_sanitize=1">[sanitize_external]</a></li>
		</ul>
		<b>Doors:</b>
		<ul>
			<li>[format_tag("Exterior","exterior_door_tag")]</li>
			<li>[format_tag("Interior","interior_door_tag")]</li>
		</ul>
		<b>Sensors:</b>
		<ul>
			<li>[format_tag("Chamber","sensor_tag")]</li>
			<li>[format_tag("Interior","sensor_tag_int")]</li>
		</ul>"}

	Topic(href, href_list)
		if(..())
			return

		if(!issilicon(usr))
			if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
				return

		if("set_id" in href_list)
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				id_tag = newid
				initialize()

		if("toggle_sanitize" in href_list)
			sanitize_external=!sanitize_external
			initialize()

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

	update_icon()
		if(on && program)
			if(program.memory["processing"])
				icon_state = "airlock_control_process"
			else
				icon_state = "airlock_control_standby"
		else
			icon_state = "airlock_control_off"


	return_text()
		var/state_options = null

		var/state = 0
		var/sensor_pressure = "----"
		var/int_sensor_pressure = "----"
		var/exterior_status = "----"
		var/interior_status = "----"
		var/pump_status = "----"
		if(program)
			state = program.state
			sensor_pressure = program.memory["sensor_pressure"]
			int_sensor_pressure = program.memory["int_sensor_pressure"]
			exterior_status = program.memory["exterior_status"]
			interior_status = program.memory["interior_status"]
			pump_status = program.memory["pump_status"]

		switch(state)
			if(AIRLOCK_STATE_INOPEN)
				state_options = {"<A href='?src=\ref[src];command=cycle_closed'>Close Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>"}
			if(AIRLOCK_STATE_PRESSURIZE)
				state_options = "<A href='?src=\ref[src];command=abort'>Abort Cycling</A><BR>"
			if(AIRLOCK_STATE_CLOSED)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Open Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Open Exterior Airlock</A><BR>"}
			if(AIRLOCK_STATE_DEPRESSURIZE)
				state_options = "<A href='?src=\ref[src];command=abort'>Abort Cycling</A><BR>"
			if(AIRLOCK_STATE_OUTOPEN)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_closed'>Close Exterior Airlock</A><BR>"}
			if(AIRLOCK_STATE_BOTHOPEN)
				state_options = "<A href='?src=\ref[src];command=close'>Close Airlocks</A><BR>"

		var/output = {"<B>Airlock Control Console</B><HR>
[state_options]<HR>
<B>Chamber Pressure:</B> [sensor_pressure] kPa<BR>
<B>Internal Pressure:</B> [int_sensor_pressure] kPa<BR>
<B>Exterior Door: </B> [exterior_status]<BR>
<B>Interior Door: </B> [interior_status]<BR>
<B>Control Pump: </B> [pump_status]<BR>"}

		if(program && program.state == AIRLOCK_STATE_CLOSED)
			output += {"<A href='?src=\ref[src];command=force_both'>Force Both Airlocks</A><br>
	<A href='?src=\ref[src];command=force_interior'>Force Inner Airlock</A><br>
	<A href='?src=\ref[src];command=force_exterior'>Force Outer Airlock</A>"}

		return output