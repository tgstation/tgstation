/datum/wires/holopad
	holder_type = /obj/machinery/holopad
	proper_name = "Holopad"

/datum/wires/holopad/New(atom/holder)
	wires = list(WIRE_REPLAY)
	..()

/datum/wires/holopad/on_pulse(wire)
	var/obj/machinery/holopad/the_holopad = holder
	switch(wire)
		if(WIRE_REPLAY)
			the_holopad.replay_start()
