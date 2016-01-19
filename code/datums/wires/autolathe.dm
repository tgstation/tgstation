/datum/wires/autolathe

	holder_type = /obj/machinery/autolathe
	wire_count = 10

var/const/AUTOLATHE_HACK_WIRE = 1
var/const/AUTOLATHE_SHOCK_WIRE = 2
var/const/AUTOLATHE_DISABLE_WIRE = 4


/datum/wires/autolathe/getStatus()
	var/obj/machinery/autolathe/A = holder
	var/list/status = list()
	status.Add("The red light is [A.disabled ? "off" : "on"].")
	status.Add("The blue light is [A.hacked ? "off" : "on"].")
	return status

/datum/wires/autolathe/CanUse()
	var/obj/machinery/autolathe/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/autolathe/UpdateCut(index, mended)
	var/obj/machinery/autolathe/A = holder
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			if(!A.hacked)
				A.adjust_hacked(1)
		if(AUTOLATHE_SHOCK_WIRE)
			A.shocked = !mended
		if(AUTOLATHE_DISABLE_WIRE)
			A.disabled = !mended

/datum/wires/autolathe/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/autolathe/A = holder
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			A.adjust_hacked(!A.hacked)
			spawn(50)
				if(A && !IsIndexCut(index))
					A.adjust_hacked(0)
					Interact(usr)
		if(AUTOLATHE_SHOCK_WIRE)
			A.shocked = !A.shocked
			spawn(50)
				if(A && !IsIndexCut(index))
					A.shocked = 0
					Interact(usr)
		if(AUTOLATHE_DISABLE_WIRE)
			A.disabled = !A.disabled
			spawn(50)
				if(A && !IsIndexCut(index))
					A.disabled = 0
					Interact(usr)