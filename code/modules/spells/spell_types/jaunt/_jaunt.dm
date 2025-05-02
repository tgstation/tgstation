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

/datum/action/cooldown/spell/jaunt/get_caster_from_target(atom/target)
	if(istype(target.loc, jaunt_type))
		return target

	return ..()

/datum/action/cooldown/spell/jaunt/PreActivate(atom/target)
	if(SEND_SIGNAL(target, COMSIG_MOB_PRE_JAUNT, target) & COMPONENT_BLOCK_JAUNT)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/jaunt/before_cast(atom/cast_on)
	return ..() | SPELL_NO_FEEDBACK // Don't do the feedback until after we're jaunting

/datum/action/cooldown/spell/jaunt/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/area/owner_area = get_area(owner)
	var/turf/owner_turf = get_turf(owner)
	if(!owner_area || !owner_turf)
		return FALSE // nullspaced?

	if(!check_teleport_valid(owner, owner_turf, TELEPORT_CHANNEL_MAGIC))
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
	SHOULD_CALL_PARENT(TRUE)

	var/obj/effect/dummy/phased_mob/jaunt = new jaunt_type(loc_override || get_turf(jaunter), jaunter)
	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(on_jaunt_exited))
	check_flags &= ~AB_CHECK_PHASED
	jaunter.add_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), REF(src))
	// Don't do the feedback until we have runechat hidden.
	// Otherwise the text will follow the jaunt holder, which reveals where our caster is travelling.
	spell_feedback(jaunter)

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(jaunter, COMSIG_MOB_ENTER_JAUNT, src, jaunt)
	return jaunt

/**
 * Ejects the [unjaunter] from jaunt
 * The jaunt object in turn should call on_jaunt_exited
 * If [loc_override] is supplied,
 * the jaunt will be moved to that turf
 * before ejecting the unjaunter
 *
 * Returns TRUE on successful exit, FALSE otherwise
 */
/datum/action/cooldown/spell/jaunt/proc/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	SHOULD_CALL_PARENT(TRUE)

	var/obj/effect/dummy/phased_mob/jaunt = unjaunter.loc
	if(!istype(jaunt))
		return FALSE

	if(jaunt.jaunter != unjaunter)
		CRASH("Jaunt spell attempted to exit_jaunt with an invalid unjaunter, somehow.")

	if(loc_override)
		jaunt.forceMove(loc_override)
	jaunt.eject_jaunter()
	return TRUE

/**
 * Called when a mob is ejected from the jaunt holder and goes back to normal.
 * This is called both fom exit_jaunt() but also if the caster is ejected involuntarily for some reason.
 * Use this to clear state data applied when jaunting, such as the trait TRAIT_MAGICALLY_PHASED.
 * Arguments
 * * jaunt - The mob holder effect the caster has just exited
 * * unjaunter - The spellcaster who is no longer jaunting
 */
/datum/action/cooldown/spell/jaunt/proc/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	SHOULD_CALL_PARENT(TRUE)
	check_flags |= AB_CHECK_PHASED
	unjaunter.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), REF(src))
	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(unjaunter, COMSIG_MOB_AFTER_EXIT_JAUNT, src)

/datum/action/cooldown/spell/jaunt/Remove(mob/living/remove_from)
	exit_jaunt(remove_from)
	if (!is_jaunting(remove_from)) // In case you have made exit_jaunt conditional, as in mirror walk
		return ..()
	var/obj/effect/dummy/phased_mob/jaunt = remove_from.loc
	jaunt.eject_jaunter()
	return ..()
