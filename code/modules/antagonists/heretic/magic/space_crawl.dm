#define SPACE_PHASING "space-phasing"

/**
 * ### Space Crawl
 *
 * Lets the caster enter and exit tiles of space or misc turfs.
 */
/datum/action/cooldown/spell/jaunt/space_crawl
	name = "Space Phase"
	desc = "Allows you to phase in and out of existance while in space or misc tiles."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "space_crawl"

	school = SCHOOL_FORBIDDEN

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	///List of traits that are added to the heretic while in space phase jaunt
	var/static/list/jaunting_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD, TRAIT_NOBREATH)

/datum/action/cooldown/spell/jaunt/space_crawl/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/space_crawl/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/jaunt/space_crawl/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(isspaceturf(get_turf(owner)) || ismiscturf(get_turf(owner)))
		return TRUE
	if(feedback)
		to_chat(owner, span_warning("You must stand on a space or misc turf!"))
	return FALSE

/datum/action/cooldown/spell/jaunt/space_crawl/cast(mob/living/cast_on)
	. = ..()
	// Should always return something because we checked that in can_cast_spell before arriving here
	var/turf/our_turf = get_turf(cast_on)
	do_spacecrawl(our_turf, cast_on)

/**
 * Attempts to enter or exit the passed space or misc turf.
 * Returns TRUE if we successfully entered or exited said turf, FALSE otherwise
 */
/datum/action/cooldown/spell/jaunt/space_crawl/proc/do_spacecrawl(turf/our_turf, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(our_turf, jaunter)
	else
		. = try_enter_jaunt(our_turf, jaunter)

	if(!.)
		reset_spell_cooldown()
		to_chat(jaunter, span_warning("You are unable to space crawl!"))

/**
 * Attempts to enter the passed space or misc turfs.
 */
/datum/action/cooldown/spell/jaunt/space_crawl/proc/try_enter_jaunt(turf/our_turf, mob/living/jaunter)
	// Begin the jaunt
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	var/obj/effect/dummy/phased_mob/holder = enter_jaunt(jaunter, our_turf)
	if(isnull(holder))
		REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
		return FALSE

	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))
	if(iscarbon(jaunter))
		jaunter.drop_all_held_items()
		// Sanity check to ensure we didn't lose our focus as a result.
		if(!HAS_TRAIT(jaunter, TRAIT_ALLOW_HERETIC_CASTING))
			REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
			exit_jaunt(jaunter, our_turf)
			return FALSE
		// Give them some space hands to prevent them from doing things
		var/obj/item/space_crawl/left_hand = new(jaunter)
		var/obj/item/space_crawl/right_hand = new(jaunter)
		left_hand.icon_state = "spacehand_right" // Icons swapped intentionally..
		right_hand.icon_state = "spacehand_left" // ..because perspective, or something
		jaunter.put_in_hands(left_hand)
		jaunter.put_in_hands(right_hand)

	jaunter.add_traits(jaunting_traits, SPACE_PHASING)
	RegisterSignal(jaunter, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))
	playsound(our_turf, 'sound/effects/magic/cosmic_energy.ogg', 50, TRUE, -1)
	our_turf.visible_message(span_warning("[jaunter] sinks into [our_turf]!"))
	new /obj/effect/temp_visual/space_explosion(our_turf)
	jaunter.extinguish_mob()

	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	return TRUE

/**
 * Attempts to Exit the passed space or misc turf.
 */
/datum/action/cooldown/spell/jaunt/space_crawl/proc/try_exit_jaunt(turf/our_turf, mob/living/jaunter, force = FALSE)
	if(!force && HAS_TRAIT_FROM(jaunter, TRAIT_NO_TRANSFORM, REF(src)))
		to_chat(jaunter, span_warning("You cannot exit yet!!"))
		return FALSE

	if(!exit_jaunt(jaunter, our_turf))
		return FALSE
	jaunter.remove_traits(jaunting_traits, SPACE_PHASING)
	our_turf.visible_message(span_boldwarning("[jaunter] rises out of [our_turf]!"))
	return TRUE

/datum/action/cooldown/spell/jaunt/space_crawl/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(unjaunter, list(SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING)))
	playsound(get_turf(unjaunter), 'sound/effects/magic/cosmic_energy.ogg', 50, TRUE, -1)
	new /obj/effect/temp_visual/space_explosion(get_turf(unjaunter))
	if(iscarbon(unjaunter))
		for(var/obj/item/space_crawl/space_hand in unjaunter.held_items)
			unjaunter.temporarilyRemoveItemFromInventory(space_hand, force = TRUE)
			qdel(space_hand)
	return ..()

/// Signal proc for [SIGNAL_REMOVETRAIT] via [TRAIT_ALLOW_HERETIC_CASTING], losing our focus midcast will throw us out.
/datum/action/cooldown/spell/jaunt/space_crawl/proc/on_focus_lost(mob/living/source)
	SIGNAL_HANDLER
	var/turf/our_turf = get_turf(source)
	try_exit_jaunt(our_turf, source, TRUE)

/// Spacecrawl "hands", prevent the user from holding items in spacecrawl
/obj/item/space_crawl
	name = "space crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/obj/antags/eldritch.dmi'
	item_flags = ABSTRACT | DROPDEL

/obj/item/space_crawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

#undef SPACE_PHASING
