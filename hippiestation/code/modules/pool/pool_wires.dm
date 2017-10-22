#define POOL_WIRE_DRAIN "drain"
#define POOL_WIRE_TEMP "temp"


/datum/wires/poolcontroller
	holder_type = /obj/machinery/poolcontroller

/datum/wires/poolcontroller/New(atom/holder)
	wires = list(
		POOL_WIRE_DRAIN, WIRE_SHOCK, WIRE_ZAP, POOL_WIRE_TEMP
	)
	add_duds(3)
	..()

/datum/wires/poolcontroller/interactable(mob/user)
	var/obj/machinery/poolcontroller/P = holder
	if(P.panel_open)
		return TRUE

/datum/wires/poolcontroller/get_status()
	var/obj/machinery/poolcontroller/P = holder
	var/list/status = list()
	status += "The blue light is [P.drainable ? "on" : "off"]."
	status += "The red light is [P.tempunlocked ? "on" : "off"]."
	status += "The yellow light is [P.shocked ? "on" : "off"]."
	return status

/datum/wires/poolcontroller/on_pulse(wire)
	var/obj/machinery/poolcontroller/P = holder
	switch(wire)
		if(POOL_WIRE_DRAIN)
			P.drainable = FALSE
		if(POOL_WIRE_TEMP)
			P.tempunlocked = FALSE
		if(WIRE_SHOCK)
			P.shocked = !P.shocked
			addtimer(CALLBACK(P, /obj/machinery/autolathe.proc/reset, wire), 60)

/datum/wires/poolcontroller/on_cut(wire, mend)
	var/obj/machinery/poolcontroller/P = holder
	switch(wire)
		if(POOL_WIRE_DRAIN)
			if(mend)
				P.drainable = FALSE
			else
				P.drainable = TRUE
		if(POOL_WIRE_TEMP)
			if(mend)
				P.tempunlocked = FALSE
			else
				P.tempunlocked = TRUE
		if(WIRE_ZAP)
			P.shock(usr, 50)
		if(WIRE_SHOCK)
			if(mend)
				P.stat |= NOPOWER
			else
				P.stat &= ~NOPOWER