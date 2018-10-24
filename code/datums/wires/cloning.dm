/datum/wires/clonepod
	holder_type = /obj/machinery/clonepod

/datum/wires/clonepod/New(atom/holder)
	wires = list(WIRE_POWER, WIRE_CLONESTARTED, WIRE_CLONED)
	..()
			
/datum/wires/clonepod/on_pulse(wire)
	var/obj/machinery/clonepod/C = holder
	switch(wire)
		if(WIRE_POWER)
			if(isliving(C.occupant))
				C.go_out() //Force eject
				C.connected_message("Clone Ejected: Loss of power.")
