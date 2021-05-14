/datum/wires/mod
	holder_type = /obj/item/mod/control
	proper_name = "MOD control module"

/datum/wires/mod/New(atom/holder)
	wires = list(WIRE_HACK, WIRE_DISABLE, WIRE_SHOCK, WIRE_INTERFACE)
	add_duds(2)
	..()

/datum/wires/mod/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/mod/control/MOD = holder
	if(!issilicon(user) && MOD.seconds_electrified && MOD.shock(user))
		return FALSE
	if(MOD == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		to_chat(user, "<span class='warning'>You cannot access the [MOD] control panel while wearing it!</span>")
		return FALSE
	if(MOD.open)
		return TRUE

/datum/wires/mod/get_status()
	var/obj/item/mod/control/MOD = holder
	var/list/status = list()
	status += "The orange light is [MOD.seconds_electrified ? "on" : "off"]."
	status += "The red light is [MOD.malfunctioning ? "off" : "blinking"]."
	status += "The green light is [MOD.locked ? "on" : "off"]."
	status += "The yellow light is [MOD.interface_break ? "off" : "on"]."
	return status

/datum/wires/mod/on_pulse(wire)
	var/obj/item/mod/control/MOD = holder
	switch(wire)
		if(WIRE_HACK)
			MOD.locked = !MOD.locked
		if(WIRE_DISABLE)
			MOD.malfunctioning = TRUE
		if(WIRE_SHOCK)
			MOD.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_INTERFACE)
			MOD.interface_break = !MOD.interface_break

/datum/wires/mod/on_cut(wire, mend)
	var/obj/item/mod/control/MOD = holder
	switch(wire)
		if(WIRE_HACK)
			MOD.locked = !mend
		if(WIRE_DISABLE)
			MOD.malfunctioning = !mend
		if(WIRE_SHOCK)
			if(mend)
				MOD.seconds_electrified = MACHINE_NOT_ELECTRIFIED
			else
				MOD.seconds_electrified = MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_INTERFACE)
			MOD.interface_break = !mend
