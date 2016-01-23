/datum/wires/alarm
	holder_type = /obj/machinery/alarm

/datum/wires/alarm/New(atom/holder)
	wires = list(
		WIRE_POWER,
		WIRE_IDSCAN, WIRE_AI,
		WIRE_PANIC, WIRE_ALARM
	)
	add_duds(3)
	..()

/datum/wires/alarm/interactable(mob/user)
	var/obj/machinery/alarm/A = holder
	if(A.panel_open && A.buildstage == 2)
		return TRUE

/datum/wires/alarm/get_status()
	var/obj/machinery/alarm/A = holder
	var/list/status = list()
	status += "The interface light is [A.locked ? "red" : "green"]."
	status += "The short indicator is [A.shorted ? "lit" : "off"]."
	status += "The AI connection light is [!A.aidisabled ? "on" : "off"]."
	return status

/datum/wires/alarm/on_pulse(wire)
	var/obj/machinery/alarm/A = holder
	switch(wire)
		if(WIRE_POWER) // Short out for a long time.
			if(!A.shorted)
				A.shorted = TRUE
				A.update_icon()
			spawn(12000)
				if(A.shorted)
					A.shorted = FALSE
					A.update_icon()
		if(WIRE_IDSCAN) // Toggle lock.
			A.locked = !A.locked
		if(WIRE_AI) // Disable AI control for a while.
			if(!A.aidisabled)
				A.aidisabled = TRUE
			spawn(100)
				if(A.aidisabled)
					A.aidisabled = FALSE
		if(WIRE_PANIC) // Toggle panic siphon.
			if(A.mode == 1) // AALARM_MODE_SCRUB
				A.mode = 3 // AALARM_MODE_PANIC
			else
				A.mode = 1 // AALARM_MODE_SCRUB
			A.apply_mode()
		if(WIRE_ALARM) // Clear alarms.
			if(A.alarm_area.atmosalert(0, holder))
				A.post_alert(0)
			A.update_icon()

/datum/wires/alarm/on_cut(wire, mend)
	var/obj/machinery/alarm/A = holder
	switch(wire)
		if(WIRE_POWER) // Short out forever.
			A.shock(usr, 50)
			A.shorted = !mend
			A.update_icon()
		if(WIRE_IDSCAN)
			if(!mend)
				A.locked = TRUE
		if(WIRE_AI)
			A.aidisabled = mend // Enable/disable AI control.
		if(WIRE_PANIC) // Force panic syphon on.
			if(!mend)
				A.mode = 3 // AALARM_MODE_PANIC
				A.apply_mode()
		if(WIRE_ALARM) // Post alarm.
			if(A.alarm_area.atmosalert(2, holder))
				A.post_alert(2)
			A.update_icon()