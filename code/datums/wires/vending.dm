/datum/wires/vending
	holder_type = /obj/machinery/vending
	wire_count = 5

var/const/VENDING_WIRE_THROW = 1
var/const/VENDING_WIRE_CONTRABAND = 2
var/const/VENDING_WIRE_ELECTRIFY = 4
var/const/VENDING_WIRE_IDSCAN = 8
var/const/VENDING_WIRE_SPEAKER = 16

/datum/wires/vending/CanUse(mob/living/L)
	var/obj/machinery/vending/V = holder
	if(!istype(L, /mob/living/silicon))
		if(V.seconds_electrified)
			if(V.shock(L, 100))
				return 0
	if(V.panel_open)
		return 1
	return 0

/datum/wires/vending/getStatus()
	var/obj/machinery/vending/V = holder
	var/list/status = list()
	status.Add("The orange light is [V.seconds_electrified ? "on" : "off"].")
	status.Add("The red light is [V.shoot_inventory ? "off" : "blinking"].")
	status.Add("The green light is [V.extended_inventory ? "on" : "off"].")
	status.Add("A [V.scan_id ? "purple" : "yellow"] light is on.")
	status.Add("The speaker light is [V.shut_up ? "off" : "on"].")
	return status

/datum/wires/vending/UpdatePulsed(index)
	var/obj/machinery/vending/V = holder
	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !V.shoot_inventory
		if(VENDING_WIRE_CONTRABAND)
			V.extended_inventory = !V.extended_inventory
		if(VENDING_WIRE_ELECTRIFY)
			V.seconds_electrified = 30
		if(VENDING_WIRE_IDSCAN)
			V.scan_id = !V.scan_id
		if(VENDING_WIRE_SPEAKER)
			V.shut_up = !V.shut_up

/datum/wires/vending/UpdateCut(index, mended)
	var/obj/machinery/vending/V = holder
	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !mended
		if(VENDING_WIRE_CONTRABAND)
			V.extended_inventory = 0
		if(VENDING_WIRE_ELECTRIFY)
			if(mended)
				V.seconds_electrified = 0
			else
				V.seconds_electrified = -1
		if(VENDING_WIRE_IDSCAN)
			V.scan_id = 1
		if(VENDING_WIRE_SPEAKER)
			V.shut_up = mended