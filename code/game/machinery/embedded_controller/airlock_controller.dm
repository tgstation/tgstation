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
	var/sanitize_external

	state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED
	var/sensor_pressure = null

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==sensor_tag)
			if(signal.data["pressure"])
				sensor_pressure = text2num(signal.data["pressure"])

		else if(receive_tag==exterior_door_tag)
			memory["exterior_status"] = signal.data["door_status"]

		else if(receive_tag==interior_door_tag)
			memory["interior_status"] = signal.data["door_status"]

		else if(receive_tag==airpump_tag)
			if(signal.data["power"])
				memory["pump_status"] = signal.data["direction"]
			else
				memory["pump_status"] = "off"

		else if(receive_tag==id_tag)
			switch(signal.data["command"])
				if("cycle")
					if(state < AIRLOCK_STATE_CLOSED)
						target_state = AIRLOCK_STATE_OUTOPEN
					else
						target_state = AIRLOCK_STATE_INOPEN
				if("cycle_exterior")
					target_state = AIRLOCK_STATE_OUTOPEN
				if("cycle_interior")
					target_state = AIRLOCK_STATE_INOPEN

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
			if("cycle_both")
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
						if(sensor_pressure >= ONE_ATMOSPHERE*0.95)
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
								signal.data["stabalize"] = 1
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
					var/target_pressure = ONE_ATMOSPHERE*0.05
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
		memory["processing"] = state != target_state
		//sensor_pressure = null //not sure if we can comment this out. Uncomment in case of problems -rastaf0

		return 1


obj/machinery/embedded_controller/radio/airlock_controller
	icon = 'airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Airlock Console"
	density = 0

	frequency = 1449

	// Setup parameters only
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

	initialize()
		..()

		var/datum/computer/file/embedded_program/airlock_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.exterior_door_tag = exterior_door_tag
		new_prog.interior_door_tag = interior_door_tag
		new_prog.airpump_tag = airpump_tag
		new_prog.sensor_tag = sensor_tag
		new_prog.sanitize_external = sanitize_external

		new_prog.master = src
		program = new_prog

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
		var/exterior_status = "----"
		var/interior_status = "----"
		var/pump_status = "----"
		if(program)
			state = program.state
			sensor_pressure = program.memory["sensor_pressure"]
			exterior_status = program.memory["exterior_status"]
			interior_status = program.memory["interior_status"]
			pump_status = program.memory["pump_status"]

		switch(state)
			if(AIRLOCK_STATE_INOPEN)
				state_options = "<A href='?src=\ref[src];command=cycle_closed'>Close Interior Airlock</A><BR>\
				<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>"
			if(AIRLOCK_STATE_PRESSURIZE)
				state_options = "<A href='?src=\ref[src];command=abort'>Abort Cycling</A><BR>"
			if(AIRLOCK_STATE_CLOSED)
				state_options = "<A href='?src=\ref[src];command=cycle_interior'>Open Interior Airlock</A><BR>\
<A href='?src=\ref[src];command=cycle_exterior'>Open Exterior Airlock</A><BR>"
			if(AIRLOCK_STATE_DEPRESSURIZE)
				state_options = "<A href='?src=\ref[src];command=abort'>Abort Cycling</A><BR>"
			if(AIRLOCK_STATE_OUTOPEN)
				state_options = "<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>\
<A href='?src=\ref[src];command=cycle_closed'>Close Exterior Airlock</A><BR>"
			if(AIRLOCK_STATE_BOTHOPEN)
				state_options = "<A href='?src=\ref[src];command=close'>Close Airlocks</A><BR>"

		var/output = {"<B>Airlock Control Console</B><HR>
[state_options]<HR>
<B>Chamber Pressure:</B> [sensor_pressure] kPa<BR>
<B>Exterior Door: </B> [exterior_status]<BR>
<B>Interior Door: </B> [interior_status]<BR>
<B>Control Pump: </B> [pump_status]<BR><br>"}

		if(program && program.state == AIRLOCK_STATE_CLOSED)
			output += {"<A href='?src=\ref[src];command=cycle_both'>Force Both Airlocks</A><br>
	<A href='?src=\ref[src];command=force_interior'>Force Inner Airlock</A><br>
	<A href='?src=\ref[src];command=force_exterior'>Force Outer Airlock</A>"}

		return output