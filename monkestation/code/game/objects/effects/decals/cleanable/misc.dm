/obj/effect/decal/cleanable/confetti
	name = "Confetti"
	desc = "The party is in town!"
	icon = 'monkestation/icons/obj/misc/confetti.dmi'
	icon_state = "confetti1"

/obj/effect/decal/cleanable/confetti/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state = pick("confetti1", "confetti2", "confetti3")
	src.transform = turn(src.transform, pick(90, 180, 270))
