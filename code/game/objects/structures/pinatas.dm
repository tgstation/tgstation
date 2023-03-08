/obj/structure/pinata
	name = "pinata"
	desc = "A paper mache representation of a corgi that contains all sorts of sugary treats."
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "pinata"
	max_integrity = 120 //10 hits from a baseball bat

/obj/strucutre/pinata/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pinata)
