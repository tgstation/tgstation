<<<<<<< HEAD
/datum/wires/vending
	holder_type = /obj/machinery/vending

/datum/wires/vending/New(atom/holder)
	wires = list(
		WIRE_THROW, WIRE_ELECTRIFY, WIRE_SPEAKER,
		WIRE_CONTRABAND, WIRE_IDSCAN
	)
	add_duds(1)
	..()

/datum/wires/vending/interactable(mob/user)
	var/obj/machinery/vending/V = holder
	if(!istype(user, /mob/living/silicon) && V.seconds_electrified && V.shock(user, 100))
		return FALSE
	if(V.panel_open)
		return TRUE

/datum/wires/vending/get_status()
	var/obj/machinery/vending/V = holder
	var/list/status = list()
	status += "The orange light is [V.seconds_electrified ? "on" : "off"]."
	status += "The red light is [V.shoot_inventory ? "off" : "blinking"]."
	status += "The green light is [V.extended_inventory ? "on" : "off"]."
	status += "A [V.scan_id ? "purple" : "yellow"] light is on."
	status += "The speaker light is [V.shut_up ? "off" : "on"]."
	return status

/datum/wires/vending/on_pulse(wire)
	var/obj/machinery/vending/V = holder
	switch(wire)
		if(WIRE_THROW)
			V.shoot_inventory = !V.shoot_inventory
		if(WIRE_CONTRABAND)
			V.extended_inventory = !V.extended_inventory
		if(WIRE_ELECTRIFY)
			V.seconds_electrified = 30
		if(WIRE_IDSCAN)
			V.scan_id = !V.scan_id
		if(WIRE_SPEAKER)
			V.shut_up = !V.shut_up

/datum/wires/vending/on_cut(wire, mend)
	var/obj/machinery/vending/V = holder
	switch(wire)
		if(WIRE_THROW)
			V.shoot_inventory = !mend
		if(WIRE_CONTRABAND)
			V.extended_inventory = FALSE
		if(WIRE_ELECTRIFY)
			if(mend)
				V.seconds_electrified = FALSE
			else
				V.seconds_electrified = -1
		if(WIRE_IDSCAN)
			V.scan_id = mend
		if(WIRE_SPEAKER)
			V.shut_up = mend
=======
/datum/wires/vending
	holder_type = /obj/machinery/vending
	wire_count = 4

/datum/wires/vending/New()
	wire_names=list(
		"[VENDING_WIRE_THROW]" 		= "Firing",
		"[VENDING_WIRE_CONTRABAND]" = "Contraband",
		"[VENDING_WIRE_ELECTRIFY]" 	= "Shock",
		"[VENDING_WIRE_IDSCAN]" 	= "ID Scan"
	)
	..()

var/const/VENDING_WIRE_THROW = 1
var/const/VENDING_WIRE_CONTRABAND = 2
var/const/VENDING_WIRE_ELECTRIFY = 4
var/const/VENDING_WIRE_IDSCAN = 8

/datum/wires/vending/CanUse(var/mob/living/L)
	var/obj/machinery/vending/V = holder
	if(L.lying || L.incapacitated())
		return 0
	if(!istype(L, /mob/living/silicon))
		if(V.seconds_electrified)
			if(V.shock(L, 100))
				return 0
	if(V.panel_open)
		return 1
	return 0

/datum/wires/vending/Interact(var/mob/living/user)
	if(CanUse(user))
		var/obj/machinery/vending/V = holder
		V.attack_hand(user)

/datum/wires/vending/GetInteractWindow()
	var/obj/machinery/vending/V = holder
	. += ..()
	. += "<BR>The orange light is [V.seconds_electrified ? "on" : "off"].<BR>"
	. += "The red light is [V.shoot_inventory ? "off" : "blinking"].<BR>"
	. += "The green light is [V.extended_inventory ? "on" : "off"].<BR>"
	. += "A [V.scan_id ? "purple" : "yellow"] light is on.<BR>"

/datum/wires/vending/UpdatePulsed(var/index)
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

/datum/wires/vending/UpdateCut(var/index, var/mended)
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
