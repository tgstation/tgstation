/datum/wires/scan_gate
	holder_type = /obj/machinery/scanner_gate

/datum/wires/scan_gate/New(atom/holder)
	wires = list(WIRE_INVERTED, WIRE_ALARM, WIRE_ALARMED)
	..()
			
/datum/wires/scan_gate/on_pulse(wire)
	var/obj/machinery/scanner_gate/S = holder
	switch(wire)
		if(WIRE_INVERTED) //Invert scan
			S.reverse = !reverse
		if(WIRE_ALARM) //Invert scan
			S.alarm_beep()