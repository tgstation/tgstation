/obj/structure/window/holo
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window.  It has an electric hum to it."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER
	maxhealth = 100
	disassembled = 1 // prevents noise on destruction

/obj/structure/window/holo/New()
	..()
	for(var/O in contents)
		qdel(O) // standard window code generates stuff no matter what we want

/obj/structure/window/holo/spawnfragments()
	qdel(src)
	return

/obj/structure/window/holo/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/screwdriver))
		user << "You see no screws to unfasten!"
		return
	return ..()

/obj/structure/window/holo/hit(var/damage, var/sound_effect = 1)
	. = ..()
	spawn(50) // self-healing
		health += damage

/obj/structure/window/holo/opaque
	name = "tinted window"
	opacity = 1

/obj/structure/window/holo/fulltile
	dir = 5
	maxhealth = 250

/obj/structure/window/holo/opaque/fulltile
	dir = 5
	maxhealth = 250