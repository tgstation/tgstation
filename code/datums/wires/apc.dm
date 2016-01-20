/datum/wires/apc
	var/const/W_POWER1 = "power1"
	var/const/W_POWER2 = "power2"
	var/const/W_IDSCAN = "idscan"
	var/const/W_AI = "ai"

	holder_type = /obj/machinery/power/apc

/datum/wires/apc/New(atom/holder)
	wires = list(
		W_POWER1, W_POWER2,
		W_IDSCAN, W_AI
	)
	add_duds(6)
	..()

/datum/wires/apc/interactable(mob/user)
	var/obj/machinery/power/apc/A = holder
	if(A.wiresexposed)
		return TRUE

/datum/wires/apc/get_status()
	var/obj/machinery/power/apc/A = holder
	var/list/status = list()
	status.Add("The interface light is [A.locked ? "red" : "green"].")
	status.Add("The short indicator is [A.shorted ? "lit" : "off"].")
	status.Add("The AI connection light is [!A.aidisabled ? "on" : "off"].")
	return status

/datum/wires/apc/on_pulse(wire)
	var/obj/machinery/power/apc/A = holder
	switch(wire)
		if(W_POWER1, W_POWER2) // Short for a long while.
			if(!A.shorted)
				A.shorted = TRUE
				addtimer(A, "reset", 1200, FALSE, index)
		if(W_IDSCAN) // Unlock for a little while.
			A.locked = FALSE
			addtimer(A, "reset", 300, FALSE, index)
		if (W_AI) // Disable AI control for a very short time.
			if (!A.aidisabled)
				A.aidisabled = TRUE
				addtimer(A, "reset", 10, FALSE, index)

/datum/wires/apc/on_cut(index, mend)
	var/obj/machinery/power/apc/A = holder
	switch(index)
		if(W_POWER1, W_POWER2) // Short out.
			if(mend && !is_cut(W_POWER1) && !is_cut(W_POWER2))
				A.shorted = FALSE
				A.shock(usr, 50)
			else
				A.shorted = TRUE
				A.shock(usr, 50)
		if(W_AI) // Disable AI control.
			if(mend)
				A.aidisabled = FALSE
			else
				A.aidisabled = TRUE