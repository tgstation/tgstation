#define SHOWCASE_CONSTRUCTED 1
#define SHOWCASE_SCREWDRIVERED 2

/*Completely generic structures for use by mappers to create fake objects, i.e. display rooms*/
/obj/structure/showcase
	name = "showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE
	var/deconstruction_state = SHOWCASE_CONSTRUCTED

/obj/structure/showcase/fakeid
	name = "\improper CentCom identification console"
	desc = "You can use this to change ID's."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakeid/Initialize()
	..()
	add_overlay("id")
	add_overlay("id_key")

/obj/structure/showcase/fakesec
	name = "\improper CentCom security records"
	desc = "Used to view and edit personnel's security records"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakesec/Initialize()
	..()
	add_overlay("security")
	add_overlay("security_key")

/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = "Some sort of pod filled with blood and viscera. You swear you can see it moving..."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_g"

/obj/structure/showcase/oldpod
	name = "damaged cyrogenic pod"
	desc = "A damaged cyrogenic pod long since lost to time, including its former occupant..."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/oldpod/used
	name = "opened cyrogenic pod"
	desc = "Cyrogenic pod that has recently discharged its occupand. The pod appears non-functional."


//Deconstructing
//Showcases can be any sprite, so it makes sense that they can't be constructed.
//However if a player wants to move an existing showcase or remove one, this is for that.

/obj/structure/showcase/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/screwdriver) && !anchored)
		if(deconstruction_state == SHOWCASE_SCREWDRIVERED)
			to_chat(user, "<span class='notice'>You screw the screws back into the showcase.</span>")
			playsound(loc, W.usesound, 100, 1)
			deconstruction_state = SHOWCASE_CONSTRUCTED
		else if (deconstruction_state == SHOWCASE_CONSTRUCTED)
			to_chat(user, "<span class='notice'>You unscrew the screws.</span>")
			playsound(loc, W.usesound, 100, 1)
			deconstruction_state = SHOWCASE_SCREWDRIVERED

	if(istype(W, /obj/item/crowbar) && deconstruction_state == SHOWCASE_SCREWDRIVERED)
		if(do_after(user, 20*W.toolspeed, target = src))
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You start to crowbar the showcase apart...</span>")
			new /obj/item/stack/sheet/metal (get_turf(src), 4)
			qdel(src)

	if(deconstruction_state == SHOWCASE_CONSTRUCTED && default_unfasten_wrench(user, W))
		return

//Feedback is given in examine because showcases can basically have any sprite assigned to them

/obj/structure/showcase/examine(mob/user)
	..()

	switch(deconstruction_state)
		if(SHOWCASE_CONSTRUCTED)
			to_chat(user, "The showcase is fully constructed.")
		if(SHOWCASE_SCREWDRIVERED)
			to_chat(user, "The showcase has its screws loosened.")
		else
			to_chat(user, "If you see this, something is wrong.")
