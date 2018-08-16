/datum/wires/autoylathe
	holder_type = /obj/machinery/autoylathe
	proper_name = "Autoylathe"

/datum/wires/autoylathe/New(atom/holder)
	wires = list(
		WIRE_HACK, WIRE_DISABLE,
		WIRE_SHOCK, WIRE_ZAP
	)
	add_duds(6)
	..()

/datum/wires/autoylathe/interactable(mob/user)
	var/obj/machinery/autoylathe/A = holder
	if(A.panel_open)
		return TRUE

/datum/wires/autoylathe/get_status()
	var/obj/machinery/autoylathe/A = holder
	var/list/status = list()
	status += "The red light is [A.disabled ? "on" : "off"]."
	status += "The blue light is [A.hacked ? "on" : "off"]."
	return status

/datum/wires/autoylathe/on_pulse(wire)
	var/obj/machinery/autoylathe/A = holder
	switch(wire)
		if(WIRE_HACK)
			A.adjust_hacked(!A.hacked)
			addtimer(CALLBACK(A, /obj/machinery/autoylathe.proc/reset, wire), 60)
		if(WIRE_SHOCK)
			A.shocked = !A.shocked
			addtimer(CALLBACK(A, /obj/machinery/autoylathe.proc/reset, wire), 60)
		if(WIRE_DISABLE)
			A.disabled = !A.disabled
			addtimer(CALLBACK(A, /obj/machinery/autoylathe.proc/reset, wire), 60)

/datum/wires/autoylathe/on_cut(wire, mend)
	var/obj/machinery/autoylathe/A = holder
	switch(wire)
		if(WIRE_HACK)
			A.adjust_hacked(!mend)
		if(WIRE_HACK)
			A.shocked = !mend
		if(WIRE_DISABLE)
			A.disabled = !mend
		if(WIRE_ZAP)
			A.shock(usr, 50)
