/datum/wires/scanner_gate
	holder_type = /obj/machinery/scanner_gate
	proper_name = "Scanner Gate"
	wires = list(WIRE_ACCEPT, WIRE_DENY, WIRE_DISABLE)

/datum/wires/scanner_gate/on_pulse(wire, user)
	. = ..()
	var/obj/machinery/scanner_gate/scan_gate = holder
	switch(wire)
		if(WIRE_ACCEPT)
			scan_gate.light_pass = !scan_gate.light_pass
		if(WIRE_DENY)
			scan_gate.light_fail = !scan_gate.light_fail
		if(WIRE_DISABLE)
			scan_gate.ignore_signals = !scan_gate.ignore_signals

/datum/wires/scanner_gate/get_status()
	var/obj/machinery/scanner_gate/scanner = holder
	. = list()
	. += "The Green light is [scanner.light_pass ? "on" : "off"]."
	. += "The Red light is [scanner.light_fail ? "on" : "off"]."
	. += "The Purple light is [scanner.ignore_signals ? "on" : "off"]."
