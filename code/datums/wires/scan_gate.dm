/datum/wires/scan_gate
	holder_type = /obj/machinery/scanner_gate
	proper_name = "Scanner Gate"

/datum/wires/scan_gate/New(atom/holder)
	wires = list(
		WIRE_PASS, WIRE_FAIL, WIRE_DISABLE, WIRE_ACTIVATE, WIRE_DISARM, WIRE_PROCEED
	)
	..()

/datum/wires/scan_gate/on_pulse(wire)
	var/obj/machinery/scanner_gate/V = holder
	switch(wire)
		if(WIRE_PROCEED)
			V.triggered = !V.triggered
		if(WIRE_PASS)
			V.pass = !V.pass
		if(WIRE_FAIL)
			V.fail = !V.fail
		if(WIRE_DISARM)
			V.ignore_signals = !V.ignore_signals
		if(WIRE_DISABLE)
			V.ignore_signals = TRUE
		if(WIRE_ACTIVATE)
			V.ignore_signals = FALSE

/datum/wires/scan_gate/get_status()
	var/obj/machinery/scanner_gate/V = holder
	var/list/status = list()
	status += "The Green light is [V.pass ? "blinking" : "off"]."
	status += "The Red light is [V.fail ? "blinking" : "off"]."
	status += "The Yellow light is [V.triggered ? "blinking" : "off"]."
	status += "The Purple light is [V.ignore_signals ? "on" : "off"]."
	return status
