/datum/wires/rnd
	holder_type = /obj/machinery/r_n_d
	wire_count = 5

/datum/wires/rnd/New()
	wire_names=list(
		"[RND_WIRE_DISABLE]"	= "Disable",
		"[RND_WIRE_SHOCK]" 		= "Shock",
		"[RND_WIRE_HACK]" 		= "Hack"
	)
	..()

var/const/RND_WIRE_DISABLE = 1
var/const/RND_WIRE_SHOCK = 2
var/const/RND_WIRE_HACK = 4

/datum/wires/rnd/CanUse(var/mob/living/L)
	var/obj/machinery/r_n_d/rnd = holder
	if(rnd.panel_open)
		return 1
	return 0

/datum/wires/rnd/GetInteractWindow()
	var/obj/machinery/r_n_d/rnd = holder
	. += ..()
	. += "The red light is [rnd.disabled ? "off" : "on"].<BR>"
	. += "The green light is [rnd.shocked ? "off" : "on"].<BR>"
	. += "The blue light is [rnd.hacked ? "off" : "on"].<BR>"

/datum/wires/rnd/UpdatePulsed(var/index)
	var/obj/machinery/r_n_d/rnd = holder
	switch(index)
		if(RND_WIRE_DISABLE)
			rnd.disabled = !rnd.disabled
		if(RND_WIRE_SHOCK)
			rnd.shocked += 30
		if(RND_WIRE_HACK)
			rnd.hacked = !rnd.hacked
			rnd.update_hacked()

/datum/wires/rnd/UpdateCut(var/index, var/mended)
	var/obj/machinery/r_n_d/rnd = holder
	switch(index)
		if(RND_WIRE_DISABLE)
			rnd.disabled = !mended
		if(RND_WIRE_SHOCK)
			rnd.shocked = (mended ? 0 : -1)
		if(RND_WIRE_HACK)
			rnd.hacked = 0
			rnd.update_hacked()
