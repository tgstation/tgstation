/**
 * ## Jaunt spells
 *
 * A basic subtype for jaunt related spells.
 * Jaunt spells put their caster in a dummy
 * phased_mob effect that allows them to float
 * around incorporeally.
 *
 * Doesn't actually implement any behavior on cast to
 * enter or exit the jaunt - that must be done via subtypes.
 *
 * Use enter_jaunt() and exit_jaunt() as wrappers.
 */
/datum/action/cooldown/spell/jaunt
	school = SCHOOL_TRANSMUTATION

	invocation_type = INVOCATION_NONE

	/// What dummy mob type do we put jaunters in on jaunt?
	var/jaunt_type = /obj/effect/dummy/phased_mob

/datum/action/cooldown/spell/jaunt/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/area/owner_area = get_area(owner)
	var/turf/owner_turf = get_turf(owner)
	if(!owner_area || !owner_turf)
		return FALSE // nullspaced?

	if(owner_area.area_flags & NOTELEPORT)
		if(feedback)
			to_chat(owner, span_danger("Some dull, universal force is stopping you from jaunting here."))
		return FALSE

	if(owner_turf?.turf_flags & NOJAUNT)
		if(feedback)
			to_chat(owner, span_danger("An otherwordly force is preventing you from jaunting here."))
		return FALSE

	return isliving(owner)


/**
 * Places the [jaunter] in a jaunt holder mob
 * If [loc_override] is supplied,
 * the jaunt will be moved to that turf to start at
 *
 * Returns the holder mob that was created
 */
/datum/action/cooldown/spell/jaunt/proc/enter_jaunt(mob/living/jaunter, turf/loc_override)
	var/obj/effect/dummy/phased_mob/jaunt = new jaunt_type(loc_override || get_turf(jaunter), jaunter)
	spell_requirements |= SPELL_CASTABLE_WHILE_PHASED
	ADD_TRAIT(jaunter, TRAIT_MAGICALLY_PHASED, REF(src))

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(jaunter, COMSIG_MOB_ENTER_JAUNT, src, jaunt)
	return jaunt

/**
 * Ejects the [unjaunter] from jaunt
 * If [loc_override] is supplied,
 * the jaunt will be moved to that turf
 * before ejecting the unjaunter
 *
 * Returns TRUE on successful exit, FALSE otherwise
 */
/datum/action/cooldown/spell/jaunt/proc/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	var/obj/effect/dummy/phased_mob/jaunt = unjaunter.loc
	if(!istype(jaunt))
		return FALSE

	if(jaunt.jaunter != unjaunter)
		CRASH("Jaunt spell attempted to exit_jaunt with an invalid unjaunter, somehow.")

	if(loc_override)
		jaunt.forceMove(loc_override)
	jaunt.eject_jaunter()
	spell_requirements &= ~SPELL_CASTABLE_WHILE_PHASED
	REMOVE_TRAIT(unjaunter, TRAIT_MAGICALLY_PHASED, REF(src))

	// Ditto - this needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(unjaunter, COMSIG_MOB_AFTER_EXIT_JAUNT, src)
	return TRUE

/// Simple helper to check if the passed mob is currently jaunting or not
/datum/action/cooldown/spell/jaunt/proc/is_jaunting(mob/living/user)
	return istype(user.loc, /obj/effect/dummy/phased_mob)

/datum/action/cooldown/spell/jaunt/Remove(mob/living/remove_from)
	exit_jaunt(remove_from)
	return ..()
