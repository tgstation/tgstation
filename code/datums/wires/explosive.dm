<<<<<<< HEAD
/datum/wires/explosive/New(atom/holder)
	add_duds(2) // In this case duds actually explode.
	..()

/datum/wires/explosive/on_pulse(index)
	explode()

/datum/wires/explosive/on_cut(index, mend)
	explode()

/datum/wires/explosive/proc/explode()
	return


/datum/wires/explosive/c4
	holder_type = /obj/item/weapon/c4

/datum/wires/explosive/c4/interactable(mob/user)
	var/obj/item/weapon/c4/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/explosive/c4/explode()
	var/obj/item/weapon/c4/P = holder
	P.explode()


/datum/wires/explosive/pizza
	holder_type = /obj/item/pizzabox
	randomize = TRUE

/datum/wires/explosive/pizza/New(atom/holder)
	wires = list(
		WIRE_DISARM
	)
	add_duds(3) // Duds also explode here.
	..()

/datum/wires/explosive/pizza/interactable(mob/user)
	var/obj/item/pizzabox/P = holder
	if(P.open && P.bomb)
		return TRUE

/datum/wires/explosive/pizza/get_status()
	var/obj/item/pizzabox/P = holder
	var/list/status = list()
	status += "The red light is [P.bomb_active ? "on" : "off"]."
	status += "The green light is [P.bomb_defused ? "on": "off"]."
	return status

/datum/wires/explosive/pizza/on_pulse(wire)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Pulse to toggle
			P.bomb_defused = !P.bomb_defused
		else // Boom
			explode()

/datum/wires/explosive/pizza/on_cut(wire, mend)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Disarm and untrap the box.
			if(!mend)
				P.bomb_defused = TRUE
		else
			if(!mend && !P.bomb_defused)
				explode()

/datum/wires/explosive/pizza/explode()
	var/obj/item/pizzabox/P = holder
	P.bomb.detonate()


/datum/wires/explosive/gibtonite
	holder_type = /obj/item/weapon/twohanded/required/gibtonite

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/weapon/twohanded/required/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)
=======
/datum/wires/explosive
	wire_count = 1

var/const/WIRE_EXPLODE = 1

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/UpdatePulsed(var/index)
	switch(index)
		if(WIRE_EXPLODE)
			explode()

/datum/wires/explosive/UpdateCut(var/index, var/mended)
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				explode()

/datum/wires/explosive/plastic
	holder_type = /obj/item/weapon/plastique

/datum/wires/explosive/plastic/CanUse(var/mob/living/L)
	var/obj/item/weapon/plastique/P = holder
	if(P.open_panel)
		return 1
	return 0

/datum/wires/explosive/plastic/explode()
	var/obj/item/weapon/plastique/P = holder
	P.explode(get_turf(P))

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
