//States for airlock_control
#define AIRLOCK_STATE_WAIT			0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_PRESSURIZE	2

#define AIRLOCK_TARGET_INOPEN		-1
#define AIRLOCK_TARGET_NONE			0
#define AIRLOCK_TARGET_OUTOPEN		1

datum/computer/file/embedded_program/smart_airlock_controller
	var/id_tag
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	//var/sanitize_external

	state = AIRLOCK_STATE_WAIT
	var/target_state = AIRLOCK_TARGET_NONE

datum/computer/file/embedded_program/smart_airlock_controller/New()
	..()
	memory["chamber_sensor_pressure"] = ONE_ATMOSPHERE
	memory["external_sensor_pressure"] = ONE_ATMOSPHERE
	memory["internal_sensor_pressure"] = ONE_ATMOSPHERE
	memory["exterior_status"] = "unknown"
	memory["interior_status"] = "unknown"
	memory["pump_status"] = "unknown"
	memory["target_pressure"] = ONE_ATMOSPHERE

datum/computer/file/embedded_program/smart_airlock_controller/receive_signal(datum/signal/signal, receive_method, receive_param)
	var/receive_tag = signal.data["tag"]
	if(!receive_tag) return

	if(receive_tag==tag_chamber_sensor)
		if(signal.data["pressure"])
			memory["chamber_sensor_pressure"] = text2num(signal.data["pressure"])

	else if(receive_tag==tag_exterior_sensor)
		if(signal.data["pressure"])
			memory["external_sensor_pressure"] = text2num(signal.data["pressure"])

	else if(receive_tag==tag_interior_sensor)
		if(signal.data["pressure"])
			memory["internal_sensor_pressure"] = text2num(signal.data["pressure"])

	else if(receive_tag==tag_exterior_door)
		memory["exterior_status"] = signal.data["door_status"]

	else if(receive_tag==tag_interior_door)
		memory["interior_status"] = signal.data["door_status"]

	else if(receive_tag==tag_airpump)
		if(signal.data["power"])
			memory["pump_status"] = signal.data["direction"]
		else
			memory["pump_status"] = "off"

	else if(receive_tag==id_tag)
		switch(signal.data["command"])
			if("cycle_exterior")
				state = AIRLOCK_STATE_WAIT
				target_state = AIRLOCK_TARGET_OUTOPEN
			if("cycle_interior")
				state = AIRLOCK_STATE_WAIT
				target_state = AIRLOCK_TARGET_INOPEN

	master.updateDialog()

datum/computer/file/embedded_program/smart_airlock_controller/receive_user_command(command)
	var/shutdown_pump = 0
	switch(command)
		if("cycle_closed")
			state = AIRLOCK_STATE_WAIT
			target_state = AIRLOCK_TARGET_NONE
			if(memory["interior_status"] != "closed")
				var/datum/signal/signal = new
				signal.data["tag"] = tag_interior_door
				signal.data["command"] = "secure_close"
				post_signal(signal)
			if(memory["exterior_status"] != "closed")
				var/datum/signal/signal = new
				signal.data["tag"] = tag_exterior_door
				signal.data["command"] = "secure_close"
				post_signal(signal)
			shutdown_pump = 1
		if("open_interior")
			state = AIRLOCK_STATE_WAIT
			target_state = AIRLOCK_TARGET_NONE
			if(memory["interior_status"] != "open")
				var/datum/signal/signal = new
				signal.data["tag"] = tag_interior_door
				signal.data["command"] = "secure_open"
				post_signal(signal)
		if("close_interior")
			if(memory["interior_status"] != "closed")
				var/datum/signal/signal = new
				signal.data["tag"] = tag_interior_door
				signal.data["command"] = "secure_close"
				post_signal(signal)
			shutdown_pump = 1
		if("close_exterior")
			if(memory["exterior_status"] != "closed")
				var/datum/signal/signal = new
				signal.data["tag"] = tag_exterior_door
				signal.data["command"] = "secure_close"
				post_signal(signal)
			shutdown_pump = 1
		if("open_exterior")
			state = AIRLOCK_STATE_WAIT
			target_state = AIRLOCK_TARGET_NONE
			if(memory["exterior_status"] != "open")
				var/datum/signal/signal = new
				signal.data["tag"] = tag_exterior_door
				signal.data["command"] = "secure_open"
				post_signal(signal)
		if("cycle_exterior")
			state = AIRLOCK_STATE_WAIT
			target_state = AIRLOCK_TARGET_OUTOPEN
		if("cycle_interior")
			state = AIRLOCK_STATE_WAIT
			target_state = AIRLOCK_TARGET_INOPEN

	if(shutdown_pump)
		//send a signal to stop pressurizing
		if(memory["pump_status"] != "off")
			var/datum/signal/signal = new
			signal.data = list(
				"tag" = tag_airpump,
				"power" = 0,
				"sigtype"="command"
			)
			post_signal(signal)
	master.updateDialog()

datum/computer/file/embedded_program/smart_airlock_controller/process()
	var/process_again = 1
	while(process_again)
		process_again = 0

		if(!state && target_state)
			//we're ready to do stuff, now what do we want to do?
			switch(target_state)
				if(AIRLOCK_TARGET_INOPEN)
					memory["target_pressure"] = memory["internal_sensor_pressure"]
				if(AIRLOCK_TARGET_OUTOPEN)
					memory["target_pressure"] = memory["external_sensor_pressure"]

			//work out whether we need to pressurize or depressurize the chamber (5% leeway with target pressure)
			var/chamber_pressure = memory["chamber_sensor_pressure"]
			var/target_pressure = memory["target_pressure"]
			if(chamber_pressure <= target_pressure)
				state = AIRLOCK_STATE_PRESSURIZE

				//send a signal to start pressurizing
				var/datum/signal/signal = new
				signal.data = list(
					"tag" = tag_airpump,
					"sigtype"="command",
					"power"=1,
					"direction"=1,
					"set_external_pressure"=target_pressure
				)
				post_signal(signal)

			else if(chamber_pressure > target_pressure)
				state = AIRLOCK_STATE_DEPRESSURIZE

				//send a signal to start depressurizing
				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.data = list(
					"tag" = tag_airpump,
					"sigtype"="command",
					"power"=1,
					"direction"=0,
					"set_external_pressure"=target_pressure
				)
				post_signal(signal)

		//actually do stuff
		//override commands are handled elsewhere, otherwise everything proceeds automatically
		switch(state)
			if(AIRLOCK_STATE_PRESSURIZE)
				if(memory["chamber_sensor_pressure"] >= memory["target_pressure"] * 0.95)
					if(target_state < 0)
						if(memory["interior_status"] != "open")
							var/datum/signal/signal = new
							signal.data["tag"] = tag_interior_door
							signal.data["command"] = "secure_open"
							post_signal(signal)
					else if(target_state > 0)
						if(memory["exterior_status"] != "open")
							var/datum/signal/signal = new
							signal.data["tag"] = tag_exterior_door
							signal.data["command"] = "secure_open"
							post_signal(signal)
					state = AIRLOCK_STATE_WAIT
					target_state = AIRLOCK_TARGET_NONE

					//send a signal to stop pumping
					if(memory["pump_status"] != "off")
						var/datum/signal/signal = new
						signal.data = list(
							"tag" = tag_airpump,
							"sigtype"="command",
							"power" = 0
						)
						post_signal(signal)
					master.updateDialog()

			if(AIRLOCK_STATE_DEPRESSURIZE)
				if(memory["chamber_sensor_pressure"] <= memory["target_pressure"] * 1.05)
					if(target_state > 0)
						if(memory["exterior_status"] != "open")
							var/datum/signal/signal = new
							signal.data["tag"] = tag_exterior_door
							signal.data["command"] = "secure_open"
							post_signal(signal)
					else if(target_state < 0)
						if(memory["interior_status"] != "open")
							var/datum/signal/signal = new
							signal.data["tag"] = tag_interior_door
							signal.data["command"] = "secure_open"
							post_signal(signal)
					state = AIRLOCK_STATE_WAIT
					target_state = AIRLOCK_TARGET_NONE

					//send a signal to stop pumping
					if(memory["pump_status"] != "off")
						var/datum/signal/signal = new
						signal.data = list(
							"tag" = tag_airpump,
							"sigtype"="command",
							"power" = 0
						)
						post_signal(signal)
					master.updateDialog()

	//memory["sensor_pressure"] = sensor_pressure
	memory["processing"] = state != target_state
	//sensor_pressure = null //not sure if we can comment this out. Uncomment in case of problems -rastaf0

	return 1


obj/machinery/embedded_controller/radio/smart_airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Cycling Airlock Console"
	density = 0
	unacidable = 1
	frequency = 1449
	power_channel = ENVIRON

	// Setup parameters only
	var/id_tag
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	//var/sanitize_external

	initialize()
		..()

		var/datum/computer/file/embedded_program/smart_airlock_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.tag_exterior_door = tag_exterior_door
		new_prog.tag_interior_door = tag_interior_door
		new_prog.tag_airpump = tag_airpump
		new_prog.tag_chamber_sensor = tag_chamber_sensor
		new_prog.tag_exterior_sensor = tag_exterior_sensor
		new_prog.tag_interior_sensor = tag_interior_sensor
		//new_prog.sanitize_external = sanitize_external

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
		var/state_options = ""

		var/state = 0
		var/chamber_sensor_pressure = "----"
		var/external_sensor_pressure = "----"
		var/internal_sensor_pressure = "----"
		var/exterior_status = "----"
		var/interior_status = "----"
		var/pump_status = "----"
		var/target_pressure = "----"
		if(program)
			state = program.state
			chamber_sensor_pressure = program.memory["chamber_sensor_pressure"]
			external_sensor_pressure = program.memory["external_sensor_pressure"]
			internal_sensor_pressure = program.memory["internal_sensor_pressure"]
			exterior_status = program.memory["exterior_status"]
			interior_status = program.memory["interior_status"]
			pump_status = program.memory["pump_status"]
			target_pressure = program.memory["target_pressure"]

		var/exterior_closed = 0
		if(exterior_status == "closed")
			exterior_closed = 1
		var/interior_closed = 0
		if(interior_status == "closed")
			interior_closed = 1

		state_options += "<B>Exterior status: </B> [exterior_status] ([external_sensor_pressure] kPa)<br>"
		if(exterior_closed)
			state_options += "<A href='?src=\ref[src];command=open_exterior'>Open exterior airlock</A> "
			if(abs(chamber_sensor_pressure - external_sensor_pressure) > ONE_ATMOSPHERE * 0.05)
				state_options += "<font color='red'><b>WARNING</b></font>"
			state_options += "<BR>"
			if(!state && exterior_closed && interior_closed)
				state_options += "<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>"
			else
				state_options += "<br>"
		else
			state_options += "<A href='?src=\ref[src];command=close_exterior'>Close exterior airlock</A><BR>"
			state_options += "<BR>"

		state_options += "<B>Interior status: </B> [interior_status] ([internal_sensor_pressure] kPa)<br>"
		if(interior_closed)
			state_options += "<A href='?src=\ref[src];command=open_interior'>Open interior airlock</A> "
			if(abs(chamber_sensor_pressure - internal_sensor_pressure) > ONE_ATMOSPHERE * 0.05)
				state_options += "<font color='red'><b>WARNING</b></font>"
			state_options += "<BR>"
			if(!state && exterior_closed && interior_closed)
				state_options += "<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>"
			else
				state_options += "<br>"
		else
			state_options += "<A href='?src=\ref[src];command=close_interior'>Close interior airlock</A><BR>"
			state_options += "<BR>"

		state_options += "<br>"
		state_options += "<B>Chamber Pressure:</B> [chamber_sensor_pressure] kPa<BR>"
		state_options += "<B>Target Chamber Pressure:</B> [target_pressure] kPa<BR>"
		state_options += "<B>Control Pump: </B> [pump_status]<BR>"
		if(state)
			state_options += "<A href='?src=\ref[src];command=cycle_closed'>Abort Cycling</A><BR>"
		else
			state_options += "<br>"

		return state_options

#undef AIRLOCK_STATE_PRESSURIZE
#undef AIRLOCK_STATE_WAIT
#undef AIRLOCK_STATE_DEPRESSURIZE

#undef AIRLOCK_TARGET_INOPEN
#undef AIRLOCK_TARGET_CLOSED
#undef AIRLOCK_TARGET_OUTOPEN
