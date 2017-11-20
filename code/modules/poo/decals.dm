/obj/effect/decal/cleanable/poo
	name = "poo"
	desc = "It's poop. Out of someone's ass."
	icon = 'icons/obj/poo.dmi'
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

/obj/effect/decal/cleanable/pee
	name = "pee"
	desc = "It's piss. Don't slip!"
	icon = 'icons/obj/poo.dmi'
	random_icon_states = list("pee1", "pee2", "pee3")

/obj/effect/decal/cleanable/pee/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 30, NO_SLIP_WHEN_WALKING)