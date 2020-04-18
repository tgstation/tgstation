/datum/wires/rig
	holder_type = /obj/item/rig/control
	proper_name = "RIG control module"

/datum/wires/rig/New(atom/holder)
	wires = list(WIRE_HACK, WIRE_DISABLE, WIRE_SHOCK, WIRE_INTERFACE)
	add_duds(2)
	..()

/datum/wires/rig/interactable(mob/user)
	var/obj/item/rig/control/RIG = holder
	if(!issilicon(user) && RIG.seconds_electrified && RIG.shock(user, 100))
		return FALSE
	if(RIG == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		to_chat(user, "<span class='warning'>You cannot access the [RIG] control panel while wearing it!</span>")
		return FALSE
	if(RIG.open)
		return TRUE

/datum/wires/rig/get_status()
	var/obj/item/rig/control/RIG = holder
	var/list/status = list()
	status += "The orange light is [RIG.seconds_electrified ? "on" : "off"]."
	status += "The red light is [RIG.malfunctioning ? "off" : "blinking"]."
	status += "The green light is [RIG.locked ? "on" : "off"]."
	status += "The yellow light is [RIG.interface_break ? "off" : "on"]."
	return status

/datum/wires/rig/on_pulse(wire)
	var/obj/item/rig/control/RIG = holder
	switch(wire)
		if(WIRE_HACK)
			RIG.locked = !RIG.locked
		if(WIRE_DISABLE)
			RIG.malfunctioning = TRUE
		if(WIRE_SHOCK)
			RIG.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_INTERFACE)
			RIG.interface_break = !RIG.interface_break

/datum/wires/rig/on_cut(wire, mend)
	var/obj/item/rig/control/RIG = holder
	switch(wire)
		if(WIRE_HACK)
			RIG.locked = !mend
		if(WIRE_DISABLE)
			RIG.malfunctioning = !mend
		if(WIRE_SHOCK)
			if(mend)
				RIG.seconds_electrified = MACHINE_NOT_ELECTRIFIED
			else
				RIG.seconds_electrified = MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_INTERFACE)
			RIG.interface_break = !mend
