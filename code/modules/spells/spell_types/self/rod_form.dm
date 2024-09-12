/// The base distance a wizard rod will go without upgrades.
#define BASE_WIZ_ROD_RANGE 13

/datum/action/cooldown/spell/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. \
		Purchasing this spell multiple times will also increase the rod's damage and travel range."
	button_icon_state = "immrod"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 25 SECONDS
	cooldown_reduction_per_rank = 3.75 SECONDS

	invocation = "CLANG!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_STATION

	/// The extra distance we travel per additional spell level.
	var/distance_per_spell_rank = 3
	/// The extra damage we deal per additional spell level.
	var/damage_per_spell_rank = 20
	/// The max distance the rod goes on cast
	var/rod_max_distance = BASE_WIZ_ROD_RANGE
	/// The damage bonus applied to the rod on cast
	var/rod_damage_bonus = 0

/datum/action/cooldown/spell/rod_form/cast(atom/cast_on)
	. = ..()
	// The destination turf of the rod - just a bit over the max range we calculated, for safety
	var/turf/distant_turf = get_ranged_target_turf(get_turf(cast_on), cast_on.dir, (rod_max_distance + 2))

	new /obj/effect/immovablerod/wizard(
		get_turf(cast_on),
		distant_turf,
		null,
		FALSE,
		cast_on,
		rod_max_distance,
		rod_damage_bonus,
	)

/datum/action/cooldown/spell/rod_form/level_spell(bypass_cap = FALSE)
	. = ..()
	if(!.)
		return FALSE

	rod_max_distance += distance_per_spell_rank
	rod_damage_bonus += damage_per_spell_rank
	return TRUE

/datum/action/cooldown/spell/rod_form/delevel_spell()
	. = ..()
	if(!.)
		return FALSE

	rod_max_distance -= distance_per_spell_rank
	rod_damage_bonus -= damage_per_spell_rank
	return TRUE

/// Wizard Version of the Immovable Rod.
/obj/effect/immovablerod/wizard
	notify = FALSE
	loopy_rod = TRUE
	dnd_style_level_up = FALSE
	/// The wizard who's piloting our rod.
	var/datum/weakref/our_wizard
	/// The distance the rod will go.
	var/max_distance = BASE_WIZ_ROD_RANGE
	/// The damage bonus of the rod when it smacks people.
	var/damage_bonus = 0
	/// The turf the rod started from, to calcuate distance.
	var/turf/start_turf

/obj/effect/immovablerod/wizard/Initialize(mapload, atom/target_atom, atom/specific_target, force_looping = FALSE, mob/living/wizard, max_distance = BASE_WIZ_ROD_RANGE, damage_bonus = 0)
	. = ..()
	if(wizard)
		set_wizard(wizard)
	start_turf = get_turf(src)
	src.max_distance = max_distance
	src.damage_bonus = damage_bonus

/obj/effect/immovablerod/wizard/Destroy(force)
	start_turf = null
	return ..()

/obj/effect/immovablerod/wizard/Move()
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		stop_travel()
		return
	return ..()

/obj/effect/immovablerod/wizard/penetrate(mob/living/penetrated)
	if(penetrated.can_block_magic())
		penetrated.visible_message(
			span_danger("[src] hits [penetrated], but it bounces back, then vanishes!"),
			span_userdanger("[src] hits you... but it bounces back, then vanishes!"),
			span_danger("You hear a weak, sad, CLANG.")
			)
		stop_travel()
		return

	penetrated.visible_message(
		span_danger("[penetrated] is penetrated by an immovable rod!"),
		span_userdanger("The [src] penetrates you!"),
		span_danger("You hear a CLANG!"),
		)
	penetrated.adjustBruteLoss(70 + damage_bonus)

/obj/effect/immovablerod/wizard/suplex_rod(mob/living/strongman)
	var/mob/living/wizard = our_wizard?.resolve()
	if(QDELETED(wizard))
		return ..() // There's no wizard in this rod? It's pretty much a normal rod at this point

	strongman.visible_message(
		span_boldwarning("[src] transforms into [wizard] as [strongman] suplexes them!"),
		span_warning("As you grab [src], it suddenly turns into [wizard] as you suplex them!")
		)
	to_chat(wizard, span_boldwarning("You're suddenly jolted out of rod-form as [strongman] somehow manages to grab you, slamming you into the ground!"))
	stop_travel()
	wizard.Stun(6 SECONDS)
	wizard.apply_damage(25, BRUTE)
	return TRUE

/**
 * Called when the wizard rod reaches its maximum distance
 * or is otherwise stopped by something.
 * Dumps out the wizard, and deletes.
 */
/obj/effect/immovablerod/wizard/proc/stop_travel()
	eject_wizard()
	qdel(src)

/**
 * Set wizard as our_wizard, placing them in the rod
 * and preparing them for travel.
 */
/obj/effect/immovablerod/wizard/proc/set_wizard(mob/living/wizard)
	our_wizard = WEAKREF(wizard)

	wizard.forceMove(src)
	wizard.status_flags |= GODMODE
	wizard.add_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_NO_TRANSFORM), REF(src))

/**
 * Eject our current wizard, removing them from the rod
 * and fixing all of the variables we changed.
 */
/obj/effect/immovablerod/wizard/proc/eject_wizard()
	var/mob/living/wizard = our_wizard?.resolve()
	if(QDELETED(wizard))
		return

	wizard.status_flags &= ~GODMODE
	wizard.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_NO_TRANSFORM), REF(src))
	wizard.forceMove(get_turf(src))
	our_wizard = null

#undef BASE_WIZ_ROD_RANGE
