/datum/wires/vending
	var/const/W_THROW = "throw"
	var/const/W_CONTRABAND = "contraband"
	var/const/W_ELECTRIFY = "electrify"
	var/const/W_IDSCAN = "idscan"
	var/const/W_SPEAKER = "speaker"

	holder_type = /obj/machinery/vending

/datum/wires/vending/interactable(mob/user)
	var/obj/machinery/vending/V = holder
	if(!istype(user, /mob/living/silicon) && V.seconds_electrified && V.shock(user, 100))
		return FALSE
	if(V.panel_open)
		return TRUE

/datum/wires/vending/get_status()
	var/obj/machinery/vending/V = holder
	var/list/status = list()
	status.Add("The orange light is [V.seconds_electrified ? "on" : "off"].")
	status.Add("The red light is [V.shoot_inventory ? "off" : "blinking"].")
	status.Add("The green light is [V.extended_inventory ? "on" : "off"].")
	status.Add("A [V.scan_id ? "purple" : "yellow"] light is on.")
	status.Add("The speaker light is [V.shut_up ? "off" : "on"].")
	return status

/datum/wires/vending/on_pulse(wire)
	var/obj/machinery/vending/V = holder
	switch(wire)
		if(W_THROW)
			V.shoot_inventory = !V.shoot_inventory
		if(W_CONTRABAND)
			V.extended_inventory = !V.extended_inventory
		if(W_ELECTRIFY)
			V.seconds_electrified = 30
		if(W_IDSCAN)
			V.scan_id = !V.scan_id
		if(W_SPEAKER)
			V.shut_up = !V.shut_up

/datum/wires/vending/on_cut(wire, mend)
	var/obj/machinery/vending/V = holder
	switch(wire)
		if(W_THROW)
			V.shoot_inventory = !mend
		if(W_CONTRABAND)
			V.extended_inventory = FALSE
		if(W_ELECTRIFY)
			if(mend)
				V.seconds_electrified = FALSE
			else
				V.seconds_electrified = -1
		if(W_IDSCAN)
			V.scan_id = mend
		if(W_SPEAKER)
			V.shut_up = mend