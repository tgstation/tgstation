/datum/wires/explosive
	var/const/W_BOOM = "boom"

/datum/wires/explosive/New(atom/holder)
	wires = list(
		W_BOOM
	)
	..()


/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/on_pulse(index)
	switch(index)
		if(W_BOOM)
			explode()

/datum/wires/explosive/on_cut(index, mend)
	switch(index)
		if(W_BOOM)
			if(!mend)
				explode()


/datum/wires/explosive/c4
	holder_type = /obj/item/weapon/c4

/datum/wires/explosive/c4/interactable(mob/user)
	var/obj/item/weapon/c4/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/explosive/c4/explode()
	var/obj/item/weapon/c4/P = holder
	P.explode()


/datum/wires/explosive/gibtonite
	holder_type = /obj/item/weapon/twohanded/required/gibtonite

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/weapon/twohanded/required/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)