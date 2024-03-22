/datum/wires/fax
	holder_type = /obj/machinery/fax
	proper_name = "Fax Unit"

/datum/wires/fax/New(atom/holder)
	wires = list(WIRE_SHOCK, WIRE_SIGNAL, WIRE_THROW, WIRE_LOADCHECK,)
	add_duds(1)
	return ..()

/datum/wires/fax/interactable(mob/user)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/fax/machine = holder
	if(!HAS_SILICON_ACCESS(user) && machine.seconds_electrified && machine.shock(user, 100))
		return FALSE
	if(machine.panel_open)
		return TRUE

/datum/wires/fax/get_status()
	var/obj/machinery/fax/machine = holder
	var/list/status = list()
	status += "A red light is [machine.seconds_electrified ? "blinking" : "off"]."
	status += "The network light is [machine.visible_to_network ? "on" : "off"]."
	status += "The output servo is [machine.hurl_contents ? "spinning rapidly" : "on"]."
	status += "The input servo is [machine.allow_exotic_faxes ? "spinning rapidly" : "on"]."
	return status

/datum/wires/fax/on_pulse(wire)
	var/obj/machinery/fax/machine = holder
	switch(wire)
		if(WIRE_SHOCK)
			machine.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_SIGNAL)
			machine.visible_to_network = !machine.visible_to_network
		if(WIRE_THROW)
			machine.hurl_contents = !machine.hurl_contents
		if(WIRE_LOADCHECK)
			machine.allow_exotic_faxes = !machine.allow_exotic_faxes

/datum/wires/fax/on_cut(wire, mend, source)
	var/obj/machinery/fax/machine = holder
	switch(wire)
		if(WIRE_SHOCK)
			machine.seconds_electrified = (mend) ? MACHINE_NOT_ELECTRIFIED : MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_SIGNAL)
			machine.visible_to_network = mend
		if(WIRE_THROW)
			machine.hurl_contents = !mend
		if(WIRE_LOADCHECK)
			machine.allow_exotic_faxes = !mend
