/datum/wires/mecha
	holder_type = /obj/vehicle/sealed/mecha
	proper_name = "Mecha Control"

/datum/wires/mecha/New(atom/holder)
	wires = list(WIRE_IDSCAN, WIRE_DISARM, WIRE_ZAP, WIRE_OVERCLOCK, WIRE_LAUNCH)
	var/obj/vehicle/sealed/mecha/mecha = holder
	if(mecha.mecha_flags & HAS_LIGHTS)
		wires += WIRE_LIGHT
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
	status += "The red light is [mecha.overclock_mode ? "blinking" : "off"]."
	status += "The green light is [(mecha.mecha_flags & ID_LOCK_ON) || mecha.dna_lock ? "on" : "off"]."
	if(mecha.mecha_flags & HAS_LIGHTS)
		status += "The yellow light is [mecha.light_on ? "on" : "off"]."
	status += "The blue light is [mecha.equipment_disabled ? "on" : "off"]."
	return status

/datum/wires/mecha/on_pulse(wire, user)
	var/obj/vehicle/sealed/mecha/mecha = holder
	switch(wire)
		if(WIRE_IDSCAN)
			mecha.mecha_flags ^= ID_LOCK_ON
			mecha.dna_lock = null
		if(WIRE_DISARM)
			mecha.equipment_disabled = TRUE
			mecha.set_mouse_pointer()
		if(WIRE_ZAP)
			mecha.internal_damage ^= MECHA_INT_SHORT_CIRCUIT
		if(WIRE_LIGHT)
			mecha.set_light_on(!mecha.light_on)
		if(WIRE_OVERCLOCK)
			mecha.toggle_overclock()
		if(WIRE_LAUNCH)
			try_attack(user)

/datum/wires/mecha/on_cut(wire, mend, source)
	var/obj/vehicle/sealed/mecha/mecha = holder
	switch(wire)
		if(WIRE_IDSCAN)
			if(!mend)
				mecha.mecha_flags &= ~ID_LOCK_ON
				mecha.dna_lock = null
		if(WIRE_DISARM)
			mecha.equipment_disabled = !mend
			mecha.set_mouse_pointer()
		if(WIRE_ZAP)
			if(mend)
				mecha.internal_damage &= ~MECHA_INT_SHORT_CIRCUIT
			else
				mecha.internal_damage |= MECHA_INT_SHORT_CIRCUIT
				if(isliving(source))
					mecha.shock(source, 50)
		if(WIRE_LIGHT)
			mecha.set_light_on(!mend)
		if(WIRE_OVERCLOCK)
			if(!mend)
				mecha.toggle_overclock(FALSE)
		if(WIRE_LAUNCH)
			if(!mend)
				try_attack(source)

/datum/wires/mecha/proc/try_attack(mob/living/target)
	var/obj/vehicle/sealed/mecha/mecha = holder
	if(mecha.occupant_amount()) //no powergamers sorry
		return
	var/list/obj/item/mecha_parts/mecha_equipment/armaments = list()
	if(!isnull(mecha.equip_by_category[MECHA_R_ARM]))
		armaments += mecha.equip_by_category[MECHA_R_ARM]
	if(!isnull(mecha.equip_by_category[MECHA_L_ARM]))
		armaments += mecha.equip_by_category[MECHA_L_ARM]
	var/obj/item/mecha_parts/mecha_equipment/armament = length(armaments) ? pick(armaments) : null //null makes a melee attack
	if(isnull(target))
		target = locate() in view(length(armaments) ? 5 : 1, mecha)
		if(isnull(target)) // still no target
			return

	var/disabled = mecha.equipment_disabled
	if(!isnull(armament) && armament.range & MECHA_RANGED)
		mecha.equipment_disabled = FALSE // honestly just avoid this wire
		INVOKE_ASYNC(armament, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), mecha, target)
		mecha.equipment_disabled = disabled
		return
	if(mecha.Adjacent(target) && !TIMER_COOLDOWN_RUNNING(mecha, COOLDOWN_MECHA_MELEE_ATTACK) && target.mech_melee_attack(mecha))
		TIMER_COOLDOWN_START(mecha, COOLDOWN_MECHA_MELEE_ATTACK, mecha.melee_cooldown)

/datum/wires/mecha/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/obj/vehicle/sealed/mecha/mecha = holder
	if(!HAS_SILICON_ACCESS(usr) && mecha.internal_damage & MECHA_INT_SHORT_CIRCUIT && mecha.shock(usr))
		return FALSE

/datum/wires/mecha/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		return TRUE
	return ..()
