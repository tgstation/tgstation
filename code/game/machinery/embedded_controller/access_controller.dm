//States for airlock_control
#define ACCESS_STATE_INTERNAL	-1
#define ACCESS_STATE_LOCKED		0
#define ACCESS_STATE_EXTERNAL	1

datum/computer/file/embedded_program/access_controller
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag

	state = ACCESS_STATE_LOCKED
	var/target_state = ACCESS_STATE_LOCKED

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==exterior_door_tag)
			if(signal.data["door_status"] == "closed")
				if(signal.data["lock_status"] == "locked")
					memory["exterior_status"] = "locked"
				else
					memory["exterior_status"] = "closed"
			else
				memory["exterior_status"] = "open"

		else if(receive_tag==interior_door_tag)
			if(signal.data["door_status"] == "closed")
				if(signal.data["lock_status"] == "locked")
					memory["interior_status"] = "locked"
				else
					memory["interior_status"] = "closed"
			else
				memory["interior_status"] = "open"

		else if(receive_tag==id_tag)
			switch(signal.data["command"])
				if("cycle_interior")
					target_state = ACCESS_STATE_INTERNAL
				if("cycle_exterior")
					target_state = ACCESS_STATE_EXTERNAL
				if("cycle")
					if(state < ACCESS_STATE_LOCKED)
						target_state = ACCESS_STATE_EXTERNAL
					else
						target_state = ACCESS_STATE_INTERNAL

	receive_user_command(command)
		switch(command)
			if("cycle_closed")
				target_state = ACCESS_STATE_LOCKED
			if("cycle_exterior")
				target_state = ACCESS_STATE_EXTERNAL
			if("cycle_interior")
				target_state = ACCESS_STATE_INTERNAL

	process()
		var/process_again = 1
		while(process_again)
			process_again = 0
			switch(state)
				if(ACCESS_STATE_INTERNAL) // state -1
					if(target_state > state)
						if(memory["interior_status"] == "locked")
							state = ACCESS_STATE_LOCKED
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							if(memory["interior_status"] == "closed")
								signal.data["command"] = "lock"
							else
								signal.data["command"] = "secure_close"
							post_signal(signal)

				if(ACCESS_STATE_LOCKED)
					if(target_state < state)
						if(memory["exterior_status"] != "locked")
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							if(memory["exterior_status"] == "closed")
								signal.data["command"] = "lock"
							else
								signal.data["command"] = "secure_close"
							post_signal(signal)
						else
							if(memory["interior_status"] == "closed" || memory["interior_status"] == "open")
								state = ACCESS_STATE_INTERNAL
								process_again = 1
							else
								var/datum/signal/signal = new
								signal.data["tag"] = interior_door_tag
								signal.data["command"] = "secure_open"
								post_signal(signal)
					else if(target_state > state)
						if(memory["interior_status"] != "locked")
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							if(memory["interior_status"] == "closed")
								signal.data["command"] = "lock"
							else
								signal.data["command"] = "secure_close"
							post_signal(signal)
						else
							if(memory["exterior_status"] == "closed" || memory["exterior_status"] == "open")
								state = ACCESS_STATE_EXTERNAL
								process_again = 1
							else
								var/datum/signal/signal = new
								signal.data["tag"] = exterior_door_tag
								signal.data["command"] = "secure_open"
								post_signal(signal)
					else
						if(memory["interior_status"] != "locked")
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							if(memory["interior_status"] == "closed")
								signal.data["command"] = "lock"
							else
								signal.data["command"] = "secure_close"
							post_signal(signal)
						else if(memory["exterior_status"] != "locked")
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							if(memory["exterior_status"] == "closed")
								signal.data["command"] = "lock"
							else
								signal.data["command"] = "secure_close"
							post_signal(signal)

				if(ACCESS_STATE_EXTERNAL) //state 1
					if(target_state < state)
						if(memory["exterior_status"] == "locked")
							state = ACCESS_STATE_LOCKED
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							if(memory["exterior_status"] == "closed")
								signal.data["command"] = "lock"
							else
								signal.data["command"] = "secure_close"
							post_signal(signal)


		return 1


obj/machinery/embedded_controller/radio/access_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"

	name = "Access Console"
	density = 0
	power_channel = ENVIRON

	frequency = 1449

	// Setup parameters only
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag

	initialize()
		..()

		var/datum/computer/file/embedded_program/access_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.exterior_door_tag = exterior_door_tag
		new_prog.interior_door_tag = interior_door_tag

		new_prog.master = src
		program = new_prog

	update_icon()
		if(on && program)
			if(program.memory["processing"])
				icon_state = "access_control_process"
			else
				icon_state = "access_control_standby"
		else
			icon_state = "access_control_off"


	return_text()
		var/state_options = null

		var/state = 0
		var/exterior_status = "----"
		var/interior_status = "----"
		if(program)
			state = program.state
			exterior_status = program.memory["exterior_status"]
			interior_status = program.memory["interior_status"]

		switch(state)
			if(ACCESS_STATE_INTERNAL)
				state_options = {"<A href='?src=\ref[src];command=cycle_closed'>Lock Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>"}
			if(ACCESS_STATE_LOCKED)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Unlock Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Unlock Exterior Airlock</A><BR>"}
			if(ACCESS_STATE_EXTERNAL)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_closed'>Lock Exterior Airlock</A><BR>"}

		var/output = {"<B>Access Control Console</B><HR>
[state_options]<HR>
<B>Exterior Door: </B> [exterior_status]<BR>
<B>Interior Door: </B> [interior_status]<BR>"}

		return output