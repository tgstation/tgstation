/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	var/timeleft = 300 //Set to 0 for permanent forcefields (ugh)

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(timeleft)
		QDEL_IN(src, timeleft)

/obj/effect/forcefield/singularity_pull()
	return

/obj/effect/forcefield/cult
	desc = "An unholy shield that blocks all attacks."
	name = "glowing wall"
	icon = 'icons/effects/cult/effects.dmi'
	icon_state = "cultshield"
	can_atmos_pass = ATMOS_PASS_NO
	timeleft = 200

/// A form of the cult forcefield that lasts permanently.
/// Used on the Shuttle 667.
/obj/effect/forcefield/cult/permanent
	timeleft = 0

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	alpha = 0

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're gonna be here awhile."
	timeleft = 600
