/datum/wires/holopad
	holder_type = /obj/machinery/holopad
	proper_name = "Holopad"

/datum/wires/holopad/New(atom/holder)
	wires = list(WIRE_REPLAY, WIRE_LOOP)
	..()

/datum/wires/holopad/on_pulse(wire)
	var/obj/machinery/holopad/the_holopad = holder
	switch(wire)
		if(WIRE_REPLAY)
			if(the_holopad.replay_mode)
				the_holopad.replay_stop()
			else
				the_holopad.replay_start()
		if(WIRE_LOOP)
			if(the_holopad.loop_mode)
				the_holopad.loop_mode = FALSE
			else
				the_holopad.loop_mode = TRUE
		