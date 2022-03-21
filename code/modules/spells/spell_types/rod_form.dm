/// The base distance a wizard rod will go without upgrades.
#define BASE_WIZ_ROD_RANGE 13

/obj/effect/proc_holder/spell/targeted/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. Purchasing this spell multiple times will also increase the rod's damage and travel range."
	clothes_req = TRUE
	human_req = FALSE
	charge_max = 250
	cooldown_min = 100
	range = -1
	school = SCHOOL_TRANSMUTATION
	include_user = TRUE
	invocation = "CLANG!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "immrod"
	/// The extra distance we travel per additional spell level.
	var/distance_per_spell_rank = 3
	/// The extra damage we deal per additional spell level.
	var/damage_per_spell_rank = 20

/obj/effect/proc_holder/spell/targeted/rod_form/cast(list/targets, mob/user = usr)
	var/area/our_area = get_area(user)
	if(istype(our_area, /area/wizard_station))
		to_chat(user, span_warning("You know better than to trash Wizard Federation property. Best wait until you leave to use [src]."))
		return

	// You travel farther when you upgrade the spell.
	var/rod_max_distance = BASE_WIZ_ROD_RANGE + (spell_level * distance_per_spell_rank)
	// You do more damage when you upgrade the spell.
	var/rod_damage_bonus = (spell_level * damage_per_spell_rank)

	for(var/mob/living/caster in targets)
		new /obj/effect/immovablerod/wizard(
			get_turf(caster),
			get_ranged_target_turf(get_turf(caster), caster.dir, (rod_max_distance + 2)), // Just a bit over the distance we got
			null,
			FALSE,
			caster,
			rod_max_distance,
			rod_damage_bonus,
		)

/// Wizard Version of the Immovable Rod.
/obj/effect/immovablerod/wizard
	notify = FALSE
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
	if(penetrated.anti_magic_check())
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
 * Called when the wizard rod reaches it's maximum distance
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
	wizard.notransform = TRUE
	wizard.status_flags |= GODMODE

/**
 * Eject our current wizard, removing them from the rod
 * and fixing all of the variables we changed.
 */
/obj/effect/immovablerod/wizard/proc/eject_wizard()
	var/mob/living/wizard = our_wizard?.resolve()
	if(QDELETED(wizard))
		return

	wizard.status_flags &= ~GODMODE
	wizard.notransform = FALSE
	wizard.forceMove(get_turf(src))
	our_wizard = null

#undef BASE_WIZ_ROD_RANGE
