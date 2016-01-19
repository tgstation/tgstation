/datum/wires/apc
	holder_type = /obj/machinery/power/apc
	wire_count = 4

var/const/APC_WIRE_IDSCAN = 1
var/const/APC_WIRE_MAIN_POWER1 = 2
var/const/APC_WIRE_MAIN_POWER2 = 4
var/const/APC_WIRE_AI_CONTROL = 8


/datum/wires/apc/getStatus()
	var/obj/machinery/power/apc/A = holder
	var/list/status = list()
	status.Add(A.locked ? "The Air Alarm is locked." : "The Air Alarm is unlocked.")
	status.Add(A.shorted ? "The APCs power has been shorted." : "The APC is working properly!")
	status.Add(A.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")
	return status

/datum/wires/apc/CanUse(mob/living/L)
	var/obj/machinery/power/apc/A = holder
	if(A.wiresexposed)
		return 1
	return 0

/datum/wires/apc/UpdatePulsed(index)
	var/obj/machinery/power/apc/A = holder
	switch(index)
		if(APC_WIRE_IDSCAN)
			A.locked = 0
			addtimer(A, "reset", 300, FALSE, APC_WIRE_IDSCAN)

		if (APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(A.shorted == 0)
				A.shorted = 1
				addtimer(A, "reset", 1200, FALSE, index)

		if (APC_WIRE_AI_CONTROL)
			if (A.aidisabled == 0)
				A.aidisabled = 1
				addtimer(A, "reset", 10, FALSE, APC_WIRE_AI_CONTROL)
	A.updateDialog()

/datum/wires/apc/UpdateCut(index, mended)
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