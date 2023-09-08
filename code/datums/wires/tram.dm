/datum/wires/tram_door
	holder_type = /obj/machinery/door/airlock/tram
	dictionary_key = /datum/wires/tram_door
	proper_name = "Tram Door"

/datum/wires/tram_door/New(atom/holder)
	. = ..()
	wires = list(
		WIRE_AI,
		WIRE_BACKUP1,
		WIRE_BACKUP2,
		WIRE_OPEN,
		WIRE_POWER1,
		WIRE_POWER2,
		WIRE_SAFETY,
		WIRE_SHOCK,
		WIRE_ZAP1,
		WIRE_ZAP2,
	)
	add_duds(2)

/datum/wires/tram_door/interact(mob/user)
	var/obj/machinery/door/airlock/tram/airlock_holder = holder
	if (!issilicon(user) && airlock_holder.isElectrified() && airlock_holder.shock(user, 100))
		return

	return ..()

/datum/wires/tram_door/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/door/airlock/tram/airlock = holder
	if(!issilicon(user) && airlock.isElectrified())
		var/mob/living/carbon/carbon_user = user
		if (!istype(carbon_user) || carbon_user.should_electrocute(src))
			return FALSE
	if(airlock.is_secure())
		return FALSE
	if(airlock.panel_open)
		return TRUE

/datum/wires/tram_door/get_status()
	var/obj/machinery/door/airlock/tram/airlock = holder
	var/list/status = list()
	status += "The test light is [airlock.hasPower() ? "on" : "off"]."
	status += "The AI connection light is [airlock.aiControlDisabled || (airlock.obj_flags & EMAGGED) ? "off" : "on"]."
	status += "The check sensor light is [airlock.safe ? "off" : "on"]."

	return status

/datum/wires/tram_door/on_pulse(wire)
	set waitfor = FALSE
	var/obj/machinery/door/airlock/tram/airlock = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Pulse to lose power.
			airlock.loseMainPower()
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Pulse to lose backup power.
			airlock.loseBackupPower()
		if(WIRE_OPEN) // Pulse to open door
			if(airlock.density)
				INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
			else
				INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, close), BYPASS_DOOR_CHECKS)
		if(WIRE_AI) // Pulse to disable WIRE_AI control for 10 ticks (follows same rules as cutting).
			if(airlock.aiControlDisabled == AI_WIRE_NORMAL)
				airlock.aiControlDisabled = AI_WIRE_DISABLED
			else if(airlock.aiControlDisabled == AI_WIRE_DISABLED_HACKED)
				airlock.aiControlDisabled = AI_WIRE_HACKED
			addtimer(CALLBACK(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, reset_ai_wire)), 1 SECONDS)
		if(WIRE_SHOCK) // Pulse to shock the door for 10 ticks.
			if(!airlock.secondsElectrified)
				airlock.set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, usr)
			airlock.shock(usr, 100)
		if(WIRE_SAFETY)
			airlock.safe = !airlock.safe
			if(!airlock.density)
				airlock.close()

/obj/machinery/door/airlock/tram/reset_ai_wire()
	if(aiControlDisabled == AI_WIRE_DISABLED)
		aiControlDisabled = AI_WIRE_NORMAL
	else if(aiControlDisabled == AI_WIRE_HACKED)
		aiControlDisabled = AI_WIRE_DISABLED_HACKED

/datum/wires/tram_door/on_cut(wire, mend, source)
	var/obj/machinery/door/airlock/airlock = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Cut to lose power, repair all to gain power.
			if(mend && !is_cut(WIRE_POWER1) && !is_cut(WIRE_POWER2))
				airlock.regainMainPower()
			else
				airlock.loseMainPower()
			if(isliving(usr))
				airlock.shock(usr, 50)
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Cut to lose backup power, repair all to gain backup power.
			if(mend && !is_cut(WIRE_BACKUP1) && !is_cut(WIRE_BACKUP2))
				airlock.regainBackupPower()
			else
				airlock.loseBackupPower()
			if(isliving(usr))
				airlock.shock(usr, 50)
		if(WIRE_AI) // Cut to disable WIRE_AI control, mend to re-enable.
			if(mend)
				if(airlock.aiControlDisabled == AI_WIRE_DISABLED) // 0 = normal, 1 = locked out, 2 = overridden by WIRE_AI, -1 = previously overridden by WIRE_AI
					airlock.aiControlDisabled = AI_WIRE_NORMAL
				else if(airlock.aiControlDisabled == AI_WIRE_HACKED)
					airlock.aiControlDisabled = AI_WIRE_DISABLED_HACKED
			else
				if(airlock.aiControlDisabled == AI_WIRE_NORMAL)
					airlock.aiControlDisabled = AI_WIRE_DISABLED
				else if(airlock.aiControlDisabled == AI_WIRE_DISABLED_HACKED)
					airlock.aiControlDisabled = AI_WIRE_HACKED
		if(WIRE_SHOCK) // Cut to shock the door, mend to unshock.
			if (!isnull(source))
				log_combat(source, airlock, "[mend ? "disabled" : "enabled"] shocking for")
			if(mend)
				if(airlock.secondsElectrified)
					airlock.set_electrified(MACHINE_NOT_ELECTRIFIED, usr)
			else
				if(airlock.secondsElectrified != MACHINE_ELECTRIFIED_PERMANENT)
					airlock.set_electrified(MACHINE_ELECTRIFIED_PERMANENT, usr)
				airlock.shock(usr, 100)
		if(WIRE_SAFETY) // Cut to disable safeties, mend to re-enable.
			airlock.safe = mend
			if (!isnull(source))
				log_combat(source, airlock, "[mend ? "enabled" : "disabled"] door safeties for")
		if(WIRE_ZAP1, WIRE_ZAP2) // Ouch.
			if(isliving(usr))
				airlock.shock(usr, 50)

/datum/wires/tram_door/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		return TRUE

	return ..()
