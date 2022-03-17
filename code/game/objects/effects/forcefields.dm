/obj/effect/forcefield
	name = "FORCEWALL"
	desc = "A space wizard's magic wall."
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	/// Set to 0 for permanent forcefields (ugh)
	var/timeleft = 30 SECONDS

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(timeleft)
		QDEL_IN(src, timeleft)

/obj/effect/forcefield/singularity_pull()
	return

/// The wizard's forcefield, summoned by forcewall
/obj/effect/forcefield/wizard
	/// A weakref to whoever casted our forcefield.
	var/datum/weakref/caster_weakref

/obj/effect/forcefield/wizard/Initialize(mapload, mob/caster)
	. = ..()
	caster_weakref = WEAKREF(caster)

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(WEAKREF(mover) == caster_weakref)
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.anti_magic_check(chargecost = 0))
			return TRUE

/// Cult forcefields
/obj/effect/forcefield/cult
	desc = "An unholy shield that blocks all attacks."
	name = "glowing wall"
	icon = 'icons/effects/cult/effects.dmi'
	icon_state = "cultshield"
	can_atmos_pass = ATMOS_PASS_NO
	timeleft = 20 SECONDS

/// A form of the cult forcefield that lasts permanently.
/// Used on the Shuttle 667.
/obj/effect/forcefield/cult/permanent
	timeleft = 0

/// Mime forcefields (invisible walls)

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	alpha = 0

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're gonna be here awhile."
	timeleft = 1 MINUTES
