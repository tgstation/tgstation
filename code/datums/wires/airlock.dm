/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	proper_name = "Generic Airlock"

/datum/wires/airlock/secure
	proper_name = "High Security Airlock"
	randomize = TRUE

/datum/wires/airlock/maint
	dictionary_key = /datum/wires/airlock/maint
	proper_name = "Maintenance Airlock"

/datum/wires/airlock/command
	dictionary_key = /datum/wires/airlock/command
	proper_name = "Command Airlock"

/datum/wires/airlock/service
	dictionary_key = /datum/wires/airlock/service
	proper_name = "Service Airlock"

/datum/wires/airlock/security
	dictionary_key = /datum/wires/airlock/security
	proper_name = "Security Airlock"

/datum/wires/airlock/engineering
	dictionary_key = /datum/wires/airlock/engineering
	proper_name = "Engineering Airlock"

/datum/wires/airlock/medbay
	dictionary_key = /datum/wires/airlock/medbay
	proper_name = "Medbay Airlock"

/datum/wires/airlock/science
	dictionary_key = /datum/wires/airlock/science
	proper_name = "Science Airlock"

/datum/wires/airlock/ai
	dictionary_key = /datum/wires/airlock/ai
	proper_name = "AI Airlock"

/datum/wires/airlock/New(atom/holder)
	wires = list(
		WIRE_AI,
		WIRE_BACKUP1,
		WIRE_BACKUP2,
		WIRE_BOLTS,
		WIRE_IDSCAN,
		WIRE_LIGHT,
		WIRE_OPEN,
		WIRE_POWER1,
		WIRE_POWER2,
		WIRE_SAFETY,
		WIRE_SHOCK,
		WIRE_TIMING,
		WIRE_UNRESTRICTED_EXIT,
		WIRE_ZAP1,
		WIRE_ZAP2,
	)
	add_duds(2)
	..()

/datum/wires/airlock/interact(mob/user)
	var/obj/machinery/door/airlock/airlock_holder = holder
	if (!issilicon(user) && airlock_holder.isElectrified() && airlock_holder.shock(user, 100))
		return

	return ..()

/datum/wires/airlock/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/door/airlock/A = holder
	if(!issilicon(user) && A.isElectrified())
		var/mob/living/carbon/carbon_user = user
		if (!istype(carbon_user) || carbon_user.should_electrocute(src))
			return FALSE
	if(A.is_secure())
		return FALSE
	if(A.panel_open)
		return TRUE

/datum/wires/airlock/get_status()
	var/obj/machinery/door/airlock/A = holder
	var/list/status = list()
	status += "The door bolts [A.locked ? "have engaged!" : "have disengaged."]"
	status += "The test light is [A.hasPower() ? "on" : "off"]."
	status += "The AI connection light is [A.aiControlDisabled || (A.obj_flags & EMAGGED) ? "off" : "on"]."
	status += "The check wiring light is [A.safe ? "off" : "on"]."
	status += "The timer is powered [A.autoclose ? "on" : "off"]."
	status += "The speed light is [A.normalspeed ? "on" : "off"]."
	status += "The emergency light is [A.emergency ? "on" : "off"]."

	if(A.unres_sensor)
		status += "The unrestricted exit display is [A.unres_sides ? "indicating that it is letting people pass from the [dir2text(REVERSE_DIR(A.unres_sides))]" : "faintly flickering"]."
	else
		status += "The unrestricted exit display is completely inactive."

	return status

/datum/wires/airlock/on_pulse(wire)
	set waitfor = FALSE
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Pulse to lose power.
			A.loseMainPower()
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Pulse to lose backup power.
			A.loseBackupPower()
		if(WIRE_OPEN) // Pulse to open door (only works not emagged and ID wire is cut or no access is required).
			if(A.obj_flags & EMAGGED)
				return
			if(!A.requiresID() || A.check_access(null))
				if(A.density)
					INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, open), 1)
				else
					INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close), 1)
		if(WIRE_BOLTS) // Pulse to toggle bolts (but only raises if power is on).
			if(!A.locked)
				A.bolt()
			else
				if(A.hasPower())
					A.unbolt()
			A.update_appearance()
		if(WIRE_IDSCAN) // Pulse to disable emergency access and flash the red lights.
			if(A.hasPower() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = FALSE
					A.update_appearance()
		if(WIRE_AI) // Pulse to disable WIRE_AI control for 10 ticks (follows same rules as cutting).
			if(A.aiControlDisabled == AI_WIRE_NORMAL)
				A.aiControlDisabled = AI_WIRE_DISABLED
			else if(A.aiControlDisabled == AI_WIRE_DISABLED_HACKED)
				A.aiControlDisabled = AI_WIRE_HACKED
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/door/airlock, reset_ai_wire)), 1 SECONDS)
		if(WIRE_SHOCK) // Pulse to shock the door for 10 ticks.
			if(!A.secondsElectrified)
				A.set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, usr)
			A.shock(usr, 100)
		if(WIRE_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				A.close()
		if(WIRE_TIMING)
			A.normalspeed = !A.normalspeed
		if(WIRE_LIGHT)
			A.lights = !A.lights
			A.update_appearance()
		if(WIRE_UNRESTRICTED_EXIT) // Pulse to switch the direction around by 180 degrees (North goes to South, East goes to West, vice-versa)
			if(!A.unres_sensor) //only works if the "sensor" is installed (a variable that we assign to the door either upon creation of a door with unrestricted directions or if an unrestricted helper is added to a door in mapping)
				return
			A.unres_sides = REVERSE_DIR(A.unres_sides)
			A.update_appearance()

/obj/machinery/door/airlock/proc/reset_ai_wire()
	if(aiControlDisabled == AI_WIRE_DISABLED)
		aiControlDisabled = AI_WIRE_NORMAL
	else if(aiControlDisabled == AI_WIRE_HACKED)
		aiControlDisabled = AI_WIRE_DISABLED_HACKED

/datum/wires/airlock/on_cut(wire, mend, source)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Cut to lose power, repair all to gain power.
			if(mend && !is_cut(WIRE_POWER1) && !is_cut(WIRE_POWER2))
				A.regainMainPower()
			else
				A.loseMainPower()
			if(isliving(usr))
				A.shock(usr, 50)
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Cut to lose backup power, repair all to gain backup power.
			if(mend && !is_cut(WIRE_BACKUP1) && !is_cut(WIRE_BACKUP2))
				A.regainBackupPower()
			else
				A.loseBackupPower()
			if(isliving(usr))
				A.shock(usr, 50)
		if(WIRE_BOLTS) // Cut to engage bolts, mend does nothing.
			if(!mend)
				A.bolt()
		if(WIRE_AI) // Cut to disable WIRE_AI control, mend to re-enable.
			if(mend)
				if(A.aiControlDisabled == AI_WIRE_DISABLED) // 0 = normal, 1 = locked out, 2 = overridden by WIRE_AI, -1 = previously overridden by WIRE_AI
					A.aiControlDisabled = AI_WIRE_NORMAL
				else if(A.aiControlDisabled == AI_WIRE_HACKED)
					A.aiControlDisabled = AI_WIRE_DISABLED_HACKED
			else
				if(A.aiControlDisabled == AI_WIRE_NORMAL)
					A.aiControlDisabled = AI_WIRE_DISABLED
				else if(A.aiControlDisabled == AI_WIRE_DISABLED_HACKED)
					A.aiControlDisabled = AI_WIRE_HACKED
		if(WIRE_SHOCK) // Cut to shock the door, mend to unshock.
			if (!isnull(source))
				log_combat(source, A, "[mend ? "disabled" : "enabled"] shocking for")
			if(mend)
				if(A.secondsElectrified)
					A.set_electrified(MACHINE_NOT_ELECTRIFIED, usr)
			else
				if(A.secondsElectrified != MACHINE_ELECTRIFIED_PERMANENT)
					A.set_electrified(MACHINE_ELECTRIFIED_PERMANENT, usr)
				A.shock(usr, 100)
		if(WIRE_SAFETY) // Cut to disable safeties, mend to re-enable.
			A.safe = mend
			if (!isnull(source))
				log_combat(source, A, "[mend ? "enabled" : "disabled"] door safeties for")
		if(WIRE_TIMING) // Cut to disable auto-close, mend to re-enable.
			A.autoclose = mend
			if(A.autoclose && !A.density)
				INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close))
		if(WIRE_LIGHT) // Cut to disable lights, mend to re-enable.
			A.lights = mend
			A.update_appearance()
		if(WIRE_ZAP1, WIRE_ZAP2) // Ouch.
			if(isliving(usr))
				A.shock(usr, 50)
		if(WIRE_UNRESTRICTED_EXIT) // If this wire is cut, the unrestricted helper goes away. If you mend it, it'll go "haywire" and pick a new direction at random. Might have to cut/mend a time or two to get the direction you want.
			if(!A.unres_sensor) //only works if the "sensor" is installed (a variable that we assign to the door either upon creation of a door with unrestricted directions, or if an unrestricted helper is added to a door in mapping)
				return
			if(mend)
				A.unres_sides = pick(NORTH, SOUTH, EAST, WEST)
				A.update_appearance()
			else
				A.unres_sides = NONE
				A.update_appearance()


/datum/wires/airlock/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		return TRUE

	return ..()
