/datum/wires/mecha
	holder_type = /obj/vehicle/sealed/mecha
	proper_name = "Mecha Control"

/datum/wires/mecha/New(atom/holder)
	wires = list(WIRE_IDSCAN, WIRE_DISARM, WIRE_ZAP, WIRE_LIGHT)
	add_duds(3)
	..()

/datum/wires/mecha/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/vehicle/sealed/mecha/mecha = holder
	return mecha.mecha_flags & PANEL_OPEN

/datum/wires/mecha/get_status()
	var/obj/vehicle/sealed/mecha/mecha = holder
	var/list/status = list()
	status += "The orange light is [mecha.internal_damage & MECHA_INT_SHORT_CIRCUIT ? "on" : "off"]."
	status += "The red light is [mecha.equipment_disabled ? "blinking" : "off"]."
	status += "The green light is [(mecha.mecha_flags & ID_LOCK_ON) || mecha.dna_lock ? "on" : "off"]."
	status += "The yellow light is [mecha.light_on ? "on" : "off"]."
	return status

/datum/wires/mecha/on_pulse(wire)
	var/obj/vehicle/sealed/mecha/mecha = holder
	switch(wire)
		if(WIRE_IDSCAN)
			mecha.mecha_flags ^= ID_LOCK_ON
			mecha.dna_lock = null
		if(WIRE_DISARM)
			mecha.equipment_disabled = TRUE
		if(WIRE_ZAP)
			mecha.internal_damage ^= MECHA_INT_SHORT_CIRCUIT
		if(WIRE_LIGHT)
			mecha.set_light_on(!mecha.light_on)

/datum/wires/mecha/on_cut(wire, mend, source)
	var/obj/vehicle/sealed/mecha/mecha = holder
	switch(wire)
		if(WIRE_IDSCAN)
			if(!mend)
				mecha.mecha_flags &= ~ID_LOCK_ON
				mecha.dna_lock = null
		if(WIRE_DISARM)
			mecha.equipment_disabled = !mend
		if(WIRE_ZAP)
			if(mend)
				mecha.internal_damage &= ~MECHA_INT_SHORT_CIRCUIT
			else
				mecha.internal_damage |= MECHA_INT_SHORT_CIRCUIT
		if(WIRE_LIGHT)
			mecha.set_light_on(!mend)

/datum/wires/mecha/ui_act(action, params)
	var/obj/vehicle/sealed/mecha/mecha = holder
	if(!issilicon(usr) && mecha.internal_damage & MECHA_INT_SHORT_CIRCUIT && mecha.shock(usr))
		return FALSE
	return ..()

/datum/wires/mecha/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		return TRUE
	return ..()
