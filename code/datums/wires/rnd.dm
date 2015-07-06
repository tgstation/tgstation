/datum/wires/rnd

	holder_type = /obj/machinery/r_n_d
	wire_count = 6

var/const/RND_HACK_WIRE = 1
var/const/RND_SHOCK_WIRE = 2
var/const/RND_DISABLE_WIRE = 4

/datum/wires/rnd/GetInteractWindow()
	var/obj/machinery/r_n_d/R = holder
	. += ..()
	. += text("<BR>The red light is [R.disabled ? "off" : "on"].<BR>The green light is [R.shocked ? "off" : "on"].<BR>The blue light is [R.hacked ? "off" : "on"].<BR>")

/datum/wires/rnd/CanUse()
	var/obj/machinery/r_n_d/R = holder
	if(R.panel_open)
		return 1
	return 0

/datum/wires/rnd/Interact(var/mob/living/user)
	if(CanUse(user))
		var/obj/machinery/r_n_d/V = holder
		V.attack_hand(user)

/datum/wires/rnd/UpdateCut(index, mended)
	var/obj/machinery/r_n_d/R = holder
	switch(index)
		if(RND_HACK_WIRE)
			if(!R.hacked)
				R.adjust_hacked(1)
		if(RND_SHOCK_WIRE)
			R.shocked = !mended
		if(RND_DISABLE_WIRE)
			R.disabled = !mended

/datum/wires/rnd/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/r_n_d/R = holder
	switch(index)
		if(RND_HACK_WIRE)
			R.adjust_hacked(!R.hacked)
			spawn(50)
				if(R && !IsIndexCut(index))
					R.adjust_hacked(0)
					Interact(usr)
		if(RND_SHOCK_WIRE)
			R.shocked = !R.shocked
			spawn(50)
				if(R && !IsIndexCut(index))
					R.shocked = 0
					Interact(usr)
		if(RND_DISABLE_WIRE)
			R.disabled = !R.disabled
			spawn(50)
				if(R && !IsIndexCut(index))
					R.disabled = 0
					Interact(usr)