<<<<<<< HEAD
/datum/wires/apc
	holder_type = /obj/machinery/power/apc

/datum/wires/apc/New(atom/holder)
	wires = list(
		WIRE_POWER1, WIRE_POWER2,
		WIRE_IDSCAN, WIRE_AI
	)
	add_duds(6)
	..()

/datum/wires/apc/interactable(mob/user)
	var/obj/machinery/power/apc/A = holder
	if(A.panel_open && !A.opened)
		return TRUE

/datum/wires/apc/get_status()
	var/obj/machinery/power/apc/A = holder
	var/list/status = list()
	status += "The interface light is [A.locked ? "red" : "green"]."
	status += "The short indicator is [A.shorted ? "lit" : "off"]."
	status += "The AI connection light is [!A.aidisabled ? "on" : "off"]."
	return status

/datum/wires/apc/on_pulse(wire)
	var/obj/machinery/power/apc/A = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Short for a long while.
			if(!A.shorted)
				A.shorted = TRUE
				addtimer(A, "reset", 1200, FALSE, wire)
		if(WIRE_IDSCAN) // Unlock for a little while.
			A.locked = FALSE
			addtimer(A, "reset", 300, FALSE, wire)
		if(WIRE_AI) // Disable AI control for a very short time.
			if(!A.aidisabled)
				A.aidisabled = TRUE
				addtimer(A, "reset", 10, FALSE, wire)

/datum/wires/apc/on_cut(index, mend)
	var/obj/machinery/power/apc/A = holder
	switch(index)
		if(WIRE_POWER1, WIRE_POWER2) // Short out.
			if(mend && !is_cut(WIRE_POWER1) && !is_cut(WIRE_POWER2))
				A.shorted = FALSE
				A.shock(usr, 50)
			else
				A.shorted = TRUE
				A.shock(usr, 50)
		if(WIRE_AI) // Disable AI control.
			if(mend)
				A.aidisabled = FALSE
			else
				A.aidisabled = TRUE
=======
/datum/wires/apc
	holder_type = /obj/machinery/power/apc
	wire_count = 4

/datum/wires/apc/New()
	wire_names=list(
		"[APC_WIRE_IDSCAN]" 		= "ID scan",
		"[APC_WIRE_MAIN_POWER1]" 	= "Power 1",
		"[APC_WIRE_MAIN_POWER2]" 	= "Power 2",
		"[APC_WIRE_AI_CONTROL]" 	= "AI Control"
	)
	..()

var/const/APC_WIRE_IDSCAN = 1
var/const/APC_WIRE_MAIN_POWER1 = 2
var/const/APC_WIRE_MAIN_POWER2 = 4
var/const/APC_WIRE_AI_CONTROL = 8

/datum/wires/apc/GetInteractWindow()
	var/obj/machinery/power/apc/A = holder
	. += ..()
	. += text("<br>\n[(A.locked ? "The APC is locked." : "The APC is unlocked.")]<br>\n[(A.shorted ? "The APCs power has been shorted." : "The APC is working properly!")]<br>\n[(A.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")


/datum/wires/apc/CanUse(var/mob/living/L)
	var/obj/machinery/power/apc/A = holder
	if(A.wiresexposed)
		return 1
	return 0

/datum/wires/apc/UpdatePulsed(var/index)

	var/obj/machinery/power/apc/A = holder

	switch(index)

		if(APC_WIRE_IDSCAN)
			A.locked = 0

			spawn(300)
				if(A)
					A.locked = 1
					A.updateDialog()

		if (APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(A.shorted == 0)
				A.shorted = 1

				spawn(1200)
					if(A && !IsIndexCut(APC_WIRE_MAIN_POWER1) && !IsIndexCut(APC_WIRE_MAIN_POWER2))
						A.shorted = 0
						A.updateDialog()

		if (APC_WIRE_AI_CONTROL)
			if (A.aidisabled == 0)
				A.aidisabled = 1

				spawn(10)
					if(A && !IsIndexCut(APC_WIRE_AI_CONTROL))
						A.aidisabled = 0
						A.updateDialog()

	A.updateDialog()

/datum/wires/apc/UpdateCut(var/index, var/mended)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)

			if(!mended)
				A.shock(usr, 50)
				A.shorted = 1

			else if(!IsIndexCut(APC_WIRE_MAIN_POWER1) && !IsIndexCut(APC_WIRE_MAIN_POWER2))
				A.shorted = 0
				A.shock(usr, 50)

		if(APC_WIRE_AI_CONTROL)

			if(!mended)
				if (A.aidisabled == 0)
					A.aidisabled = 1
			else
				if (A.aidisabled == 1)
					A.aidisabled = 0
	A.updateDialog()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
