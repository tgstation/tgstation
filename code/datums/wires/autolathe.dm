/datum/wires/autolathe
	var/const/W_HACK = "hack"
	var/const/W_DISABLE = "disable"
	var/const/W_SHOCK = "shock"
	var/const/W_ZAP = "zap"

	holder_type = /obj/machinery/autolathe

/datum/wires/autolathe/New(atom/holder)
	wires = list(
		W_HACK, W_DISABLE,
		W_SHOCK, W_ZAP
	)
	add_duds(6)
	..()

/datum/wires/autolathe/interactable(mob/user)
	var/obj/machinery/autolathe/A = holder
	if(A.panel_open)
		return TRUE

/datum/wires/autolathe/get_status()
	var/obj/machinery/autolathe/A = holder
	var/list/status = list()
	status.Add("The red light is [A.disabled ? "off" : "on"].")
	status.Add("The blue light is [A.hacked ? "off" : "on"].")
	return status

/datum/wires/autolathe/on_pulse(wire)
	var/obj/machinery/autolathe/A = holder
	switch(wire)
		if(W_HACK)
			A.adjust_hacked(!A.hacked)
			spawn(50)
				if(A && !is_cut(wire))
					A.adjust_hacked(FALSE)
		if(W_SHOCK)
			A.shocked = !A.shocked
			spawn(50)
				if(A && !is_cut(wire))
					A.shocked = FALSE
		if(W_DISABLE)
			A.disabled = !A.disabled
			spawn(50)
				if(A && !is_cut(wire))
					A.disabled = FALSE

/datum/wires/autolathe/on_cut(wire, mend)
	var/obj/machinery/autolathe/A = holder
	switch(wire)
		if(W_HACK)
			A.adjust_hacked(mend)
		if(W_HACK)
			A.shocked = !mend
		if(W_DISABLE)
			A.disabled = !mend
		if(W_ZAP)
			A.shock(usr, 50)