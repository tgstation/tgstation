/obj/structure/window/holo
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window.  It has an electric hum to it."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER | ABSTRACT
	maxhealth = 100
	disassembled = 1 // prevents noise on destruction

/obj/structure/window/holo/hit(var/damage, var/sound_effect = 1)
	. = ..()
	spawn(50) // self-healing
		health += damage
		update_icon()

/obj/structure/window/holo/opaque
	name = "tinted window"
	opacity = 1

/obj/structure/window/holo/fulltile
	dir = 5
	maxhealth = 250

/obj/structure/window/holo/opaque/fulltile
	dir = 5
	maxhealth = 250