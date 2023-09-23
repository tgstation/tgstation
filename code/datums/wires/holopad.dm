/datum/wires/holopad
	holder_type = /obj/machinery/holopad
	proper_name = "Holopad"

/datum/wires/holopad/New(atom/holder)
	wires = list(WIRE_REPLAY, WIRE_LOOP, WIRE_FORCEANSWER, WIRE_TX)
	add_duds(2)
	..()

/datum/wires/holopad/get_status()
	var/obj/machinery/holopad/the_holopad = holder
	var/list/status = list()
	status += "The transmitter is [the_holopad.transmitting ? "on" : "off"]."
	status += "The receiver override is [the_holopad.force_answer_call ? "on" : "off"]."
	return status

/datum/wires/holopad/on_pulse(wire)
	var/obj/machinery/holopad/the_holopad = holder
	switch(wire)
		if(WIRE_REPLAY)
			if(the_holopad.replay_mode)
				the_holopad.replay_stop()
			else
				the_holopad.replay_start()
		if(WIRE_LOOP)
			the_holopad.loop_mode = !the_holopad.loop_mode
		if(WIRE_FORCEANSWER)
			the_holopad.force_answer_call = !the_holopad.force_answer_call
		if(WIRE_TX)
			the_holopad.transmitting = !the_holopad.transmitting
		