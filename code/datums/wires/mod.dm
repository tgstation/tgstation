/datum/wires/mod
	holder_type = /obj/item/mod/control
	proper_name = "MOD control unit"

/datum/wires/mod/New(atom/holder)
	wires = list(WIRE_HACK, WIRE_DISABLE, WIRE_SHOCK, WIRE_INTERFACE)
	add_duds(2)
	..()

/datum/wires/mod/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/mod/control/mod = holder
	return mod.open

/datum/wires/mod/get_status()
	var/obj/item/mod/control/mod = holder
	var/list/status = list()
	status += "The orange light is [mod.seconds_electrified ? "on" : "off"]."
	status += "The red light is [mod.malfunctioning ? "off" : "blinking"]."
	status += "The green light is [mod.locked ? "on" : "off"]."
	status += "The yellow light is [mod.interface_break ? "off" : "on"]."
	return status

/datum/wires/mod/on_pulse(wire)
	var/obj/item/mod/control/mod = holder
	switch(wire)
		if(WIRE_HACK)
			mod.locked = !mod.locked
		if(WIRE_DISABLE)
			mod.malfunctioning = TRUE
		if(WIRE_SHOCK)
			mod.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_INTERFACE)
			mod.interface_break = !mod.interface_break

/datum/wires/mod/on_cut(wire, mend, source)
	var/obj/item/mod/control/mod = holder
	switch(wire)
		if(WIRE_HACK)
			if(!mend)
				mod.req_access = list()
		if(WIRE_DISABLE)
			mod.malfunctioning = !mend
		if(WIRE_SHOCK)
			if(mend)
				mod.seconds_electrified = MACHINE_NOT_ELECTRIFIED
			else
				mod.seconds_electrified = MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_INTERFACE)
			mod.interface_break = !mend

/datum/wires/mod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/obj/item/mod/control/mod = holder
	var/mob/user = ui.user
	if(!HAS_SILICON_ACCESS(user) && mod.seconds_electrified && mod.shock(user))
		return FALSE
	return ..()

/datum/wires/mod/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		return TRUE
	return ..()
