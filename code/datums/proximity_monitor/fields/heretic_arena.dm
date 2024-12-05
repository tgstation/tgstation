// Invisible effect that doesnt exist outside of containing the prox monitor
/obj/effect/abstract/heretic_arena
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	/// Proximity monitor that handles the effects we are looking for
	var/datum/proximity_monitor/advanced/heretic_arena/arena

/obj/effect/abstract/heretic_arena/Initialize(mapload, range, duration)
	. = ..()
	arena = new(src, range)
	QDEL_IN(src, duration)

/obj/effect/abstract/heretic_arena/Destroy(force)
	. = ..()
	QDEL_NULL(arena)

/datum/proximity_monitor/advanced/heretic_arena
	/// List of mobs inside our arena
	var/list/contained_mobs = list()
	/// List of border walls we have placed on the edges of the monitor
	var/list/border_walls = list()
	/// List of immunities given to our combatants
	var/static/list/given_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_NO_TELEPORT,
	)

/datum/proximity_monitor/advanced/heretic_arena/New(atom/_host, range, _ignore_if_not_on_turf)
	. = ..()
	recalculate_field(full_recalc = TRUE)
	var/list/things_in_range = range(range)
	for(var/mob/living/carbon/human/human_in_range in things_in_range)
		human_in_range.add_traits(given_immunities, HERETIC_ARENA_TRAIT)
		contained_mobs += human_in_range
		if(!IS_HERETIC(human_in_range))
			var/obj/item/melee/sickly_blade/training/new_blade = new(get_turf(human_in_range))
			INVOKE_ASYNC(human_in_range, TYPE_PROC_REF(/mob, put_in_hands), new_blade)
		human_in_range.apply_status_effect(/datum/status_effect/arena_tracker)
		RegisterSignal(human_in_range)

/datum/proximity_monitor/advanced/heretic_arena/Destroy()
	for(var/mob/living/carbon/human/mob in contained_mobs)
		mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
		mob.remove_status_effect(/datum/status_effect/arena_tracker)
	for(var/turf/to_restore in border_walls)
		to_restore.ChangeTurf(border_walls[to_restore])
	return ..()

/datum/proximity_monitor/advanced/heretic_arena/setup_edge_turf(turf/target)
	. = ..()
	var/old_turf = target.type
	target.ChangeTurf(/turf/closed/indestructible/heretic_wall)
	border_walls += target
	border_walls[target] += old_turf

/datum/proximity_monitor/advanced/heretic_arena/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(isliving(movable))
		var/mob/living/living_mob = movable
		living_mob.remove_status_effect(/datum/status_effect/arena_tracker) // Once you leave the arena you can't come back
		living_mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)

/turf/closed/indestructible/heretic_wall
	name = "eldritch wall"
	desc = "A wall? Made of something incomprehensible. You really don't want to be touching this..."
	icon = 'icons/turf/walls.dmi'
	icon_state = "eldritch_wall"
	opacity = FALSE
	pass_flags_self = NONE // No PASSCLOSEDTURF because only arena victors are allowed to go in or out

/turf/closed/indestructible/heretic_wall/CanAllowThrough(atom/movable/mover, border_dir)
	if(isliving(mover))
		var/mob/living/living_mover = mover
		var/datum/status_effect/arena_tracker/tracker = living_mover.has_status_effect(/datum/status_effect/arena_tracker)
		if(tracker?.arena_victor)
			return TRUE
	return ..()

/turf/closed/indestructible/heretic_wall/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(isliving(bumped_atom))
		var/mob/living/living_mob = bumped_atom
		var/atom/target = get_edge_target_turf(living_mob, get_dir(src, get_step_away(living_mob, src)))
		living_mob.throw_at(target, 4, 5)
		to_chat(living_mob, span_userdanger("The wall repels you with tremendous force!"))

/**
 * Status applied to every mob in the heretic arena.
 * Tracks the last person to damage owner.
 * When owner enters crit, we send a signal to their status so they can leave the arena
 */

/datum/status_effect/arena_tracker
	id = "arena_tracker"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// Tracks the last person who dealt damage to this mob
	var/mob/last_attacker
	/// If our mob is free to leave, set to true
	var/arena_victor = FALSE
	/// The overlay for our mob, changes color to indicate that they are a victor and are free to leave
	var/mutable_appearance/crown_overlay

/datum/status_effect/arena_tracker/on_apply()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), PROC_REF(on_enter_crit))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))
	RegisterSignal(owner, "COMSIG_OWNER_ENTERED_CRIT", PROC_REF(on_crit_somebody))
	// XANTODO - Placeholder sprite
	crown_overlay = mutable_appearance('icons/mob/effects/halo.dmi', "halo[rand(1, 6)]", -HALO_LAYER)
	owner.add_overlay(crown_overlay)
	return TRUE

/datum/status_effect/arena_tracker/on_remove()
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), COMSIG_MOB_APPLY_DAMAGE, "COMSIG_OWNER_ENTERED_CRIT"))
	owner.cut_overlay(crown_overlay)
	crown_overlay = null

/datum/status_effect/arena_tracker/proc/on_enter_crit(mob/owner)
	SIGNAL_HANDLER
	SEND_SIGNAL(last_attacker, "COMSIG_OWNER_ENTERED_CRIT")

/datum/status_effect/arena_tracker/proc/damage_taken(
	datum/source,
	damage_amount,
	damagetype,
	def_zone,
	blocked,
	wound_bonus,
	bare_wound_bonus,
	sharpness,
	attack_direction,
	attacking_item,
	wound_clothing,
)
	SIGNAL_HANDLER
	if(isnull(attacking_item))
		stack_trace("proc/damage_taken() was called but without passing attacking_item")
		return
	if(!isobj(attacking_item))
		return
	var/obj/attacking_object = attacking_item

	// Track being hit by a mob holding a stick
	if(ismob(attacking_object.loc))
		last_attacker = attacking_object.loc
		return

	// Track being hit by a mob throwing a stick
	if(isitem(attacking_object))
		var/obj/item/thrown_item = attacking_item
		var/thrown_by = thrown_item.thrownby?.resolve()
		if(ismob(thrown_by))
			last_attacker = thrown_by
			return

	// Edge case. If our attacking_item is a gun which the owner has dropped we need to find out who shot us
	// Track being hit by a mob shooting a stick
	if(isprojectile(attacking_object))
		var/obj/projectile/attacking_projectile = attacking_object
		if(ismob(attacking_projectile.firer))
			last_attacker = attacking_projectile.firer

/// Called when you crit somebody to update your crown
/datum/status_effect/arena_tracker/proc/on_crit_somebody()
	SIGNAL_HANDLER
	owner.cut_overlay(crown_overlay)
	crown_overlay.color = list(
		1, 1, 0,
		1, 1, 0,
		1, 1, 0,
	)
	owner.add_overlay(crown_overlay)

	// The mansus celebrates your efforts
	if(IS_HERETIC(owner))
		owner.heal_overall_damage(60, 60, 60)
		owner.adjustToxLoss(-60)
		owner.adjustOxyLoss(-60)
		if(iscarbon(owner))
			var/mob/living/carbon/carbon_owner = owner
			for(var/datum/wound/wound as anything in carbon_owner.all_wounds)
				wound.remove_wound()

	if(arena_victor) // No need to spam if we've already killed at least 1 person
		return
	if(IS_HERETIC(owner))
		to_chat(owner, span_hypnophrase("The mansus is pleased with your performance."))
	else
		to_chat(owner, span_hypnophrase("You feel a weight lift off your shoulders."))
	arena_victor = TRUE
