
/datum/wires/r_n_d
	random = 1
	holder_type = /obj/machinery/r_n_d
	wire_count = 6

var/const/RD_WIRE_HACK = 1		// Hacks the r_n_d machine
var/const/RD_WIRE_SHOCK = 2		// Shocks the user, 50% chance
var/const/RD_WIRE_DISABLE = 4   // Disables the machine


/datum/wires/r_n_d/CanUse(mob/living/L)
	var/obj/machinery/r_n_d/R = holder
	if(R.panel_open)
		return 1
	return 0


/datum/wires/r_n_d/UpdatePulsed(index)
	var/obj/machinery/r_n_d/R = holder
	switch(index)
		if(RD_WIRE_HACK)
			R.hacked = !R.hacked
		if(RD_WIRE_DISABLE)
			R.disabled = !R.disabled
		if(RD_WIRE_SHOCK)
			var/Rshock = R.shocked
			R.shocked = !R.shocked
			spawn(100)
				if(R)
					R.shocked = Rshock


/datum/wires/r_n_d/UpdateCut(index,mended)
	var/obj/machinery/r_n_d/R = holder
	switch(index)
		if(RD_WIRE_HACK)
			R.hacked = !mended
		if(RD_WIRE_DISABLE)
			R.disabled = !mended
		if(RD_WIRE_SHOCK)
			R.shocked = !mended


/datum/wires/r_n_d/GetInteractWindow()
	. = ..()
	var/obj/machinery/r_n_d/R = holder
	. += text("<br>The red light is [R.disabled ? "off" : "on"].<br>")
	. += text("The green light is [R.shocked ? "off" : "on"].<br>")
	. += text("The blue light is [R.hacked ? "off" : "on"].<br>")

