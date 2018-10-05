/datum/wires/cloning
	holder_type = /obj/machinery/clonepod

/datum/wires/cloning/New(atom/holder)
	wires = list(WIRE_POWER, WIRE_CLONESTARTED, WIRE_CLONED)
	..()

/datum/wires/cloning/on_cut(wire, mend)
	var/obj/machinery/clonepod/C = holder
	switch(wire)
		if(WIRE_POWER) //Cut the power
			C.shorted = !mend
			
/datum/wires/cloning/on_pulse(wire)
	var/obj/machinery/clonepod/C = holder
	switch(wire)
		if(WIRE_POWER)
			if(C.mob_occupant)
				C.go_out() //Force eject
				C.connected_message("Clone Ejected: Loss of power.")
