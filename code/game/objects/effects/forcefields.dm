/obj/effect/forcefield
	name = "FORCEWALL"
	desc = "A space wizard's magic wall."
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	/// If set, how long the force field lasts after it's created. Set to 0 to have infinite duration forcefields.
	var/initial_duration = 30 SECONDS

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(initial_duration > 0 SECONDS)
		QDEL_IN(src, initial_duration)

/obj/effect/forcefield/singularity_pull()
	return

/// The wizard's forcefield, summoned by forcewall
/obj/effect/forcefield/wizard
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// A weakref to whoever casted our forcefield.
	var/datum/weakref/caster_weakref

/obj/effect/forcefield/wizard/Initialize(mapload, mob/caster, flags = MAGIC_RESISTANCE)
	. = ..()
	if(caster)
		caster_weakref = WEAKREF(caster)
	antimagic_flags = flags

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	if(IS_WEAKREF_OF(mover, caster_weakref))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
			return TRUE

	return ..()

/// Cult forcefields
/obj/effect/forcefield/cult
	name = "glowing wall"
	desc = "An unholy shield that blocks all attacks."
	icon = 'icons/effects/cult/effects.dmi'
	icon_state = "cultshield"
	can_atmos_pass = ATMOS_PASS_NO
	initial_duration = 20 SECONDS

/// A form of the cult forcefield that lasts permanently.
/// Used on the Shuttle 667.
/obj/effect/forcefield/cult/permanent
	initial_duration = 0

/// Mime forcefields (invisible walls)

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	alpha = 0

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're gonna be here awhile."
	initial_duration = 1 MINUTES

/// Psyker forcefield
/obj/effect/forcefield/psychic
	name = "psychic forcefield"
	desc = "A wall of psychic energy powerful enough stop the motion of objects. Projectiles ricochet."
	icon_state = "psychic"
	can_atmos_pass = ATMOS_PASS_YES
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD
	receive_ricochet_chance_mod = INFINITY //we do ricochet a lot!
	initial_duration = 10 SECONDS
