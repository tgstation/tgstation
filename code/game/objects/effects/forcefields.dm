/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon_state = "m_shield"
	anchored = 1
	opacity = 0
	density = 1
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/effect/forcefield/cult
	desc = "An unholy shield that blocks all attacks."
	name = "glowing wall"
	icon_state = "cultshield"

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	var/timeleft = 300

/obj/effect/forcefield/mime/New()
	..()
	QDEL_IN(src, timeleft)

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're goona be here a while."
	timeleft = 600