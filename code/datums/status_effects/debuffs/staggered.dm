/// Staggered, Next Shove Stuns, No Side Kick
/// Status effects related to shoving effects and collisions due to shoving

/// Staggered can occur most often via shoving, but can also occur in other places too.
/datum/status_effect/staggered
	id = "staggered"
	tick_interval = 0.5 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/staggered/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/staggered/on_apply()
	//you can't stagger the dead.
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_NO_STAGGER))
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_staggered))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/staggered)
	return TRUE

/datum/status_effect/staggered/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/staggered)
	// Resetting both X on remove so we're back to normal
	owner.pixel_x = owner.base_pixel_x

/// Signal proc that self deletes our staggered effect
/datum/status_effect/staggered/proc/clear_staggered(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/staggered/tick(seconds_between_ticks)
	//you can't stagger the dead - in case somehow you die mid-stagger
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_NO_STAGGER))
		qdel(src)
		return
	if(HAS_TRAIT(owner, TRAIT_FAKEDEATH))
		return
	owner.do_stagger_animation()

/// Helper proc that causes the mob to do a stagger animation.
/// Doesn't change significantly, just meant to represent swaying back and forth
/mob/living/proc/do_stagger_animation()
	animate(src, pixel_x = 4, time = 0.2 SECONDS, loop = 6, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = -4, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)

/// Status effect specifically for instances where someone is vulnerable to being stunned when shoved.
/datum/status_effect/next_shove_stuns
	id = "next shove stuns"
	duration = 3 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 0.5 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE
	/// Our visual cue for the vulnerable state this status effect puts us in.
	var/mutable_appearance/vulnverability_overlay

/datum/status_effect/next_shove_stuns/on_apply()
	//Let's just clear this if they're dead or we can't stun them on a shove
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_NO_SIDE_KICK) || HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_stun_vulnverability_on_death))
	RegisterSignals(owner, list(
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_IMMOBILIZE), PROC_REF(clear_stun_vulnverability)
	)
	ADD_TRAIT(owner, TRAIT_STUN_ON_NEXT_SHOVE, STATUS_EFFECT_TRAIT)
	vulnverability_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "dazed")
	owner.add_overlay(vulnverability_overlay)
	return TRUE

/datum/status_effect/next_shove_stuns/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_DEATH,
	))
	REMOVE_TRAIT(owner, TRAIT_STUN_ON_NEXT_SHOVE, STATUS_EFFECT_TRAIT)
	if(vulnverability_overlay)
		clear_stun_vulnverability_overlay()

/// If our owner is either stunned, paralzyed or immobilized, we remove the status effect.
/// This is both an anti-chainstun measure and a sanity check.
/datum/status_effect/next_shove_stuns/proc/clear_stun_vulnverability(mob/living/source, amount = 0, ignore_canstun = FALSE)
	SIGNAL_HANDLER

	if(amount > 0)
		// Making absolutely sure we're removing this overlay
		clear_stun_vulnverability_overlay()
		qdel(src)

/datum/status_effect/next_shove_stuns/proc/clear_stun_vulnverability_on_death(mob/living/source)
	SIGNAL_HANDLER

	clear_stun_vulnverability_overlay()
	qdel(src)

/// Clears our overlay where needed.
/datum/status_effect/next_shove_stuns/proc/clear_stun_vulnverability_overlay()
	owner.cut_overlay(vulnverability_overlay)
	vulnverability_overlay = null

/// Status effect to prevent stuns from a shove
/// Only applied by shoving someone to paralyze them
/datum/status_effect/no_side_kick
	id = "no side kick"
	duration = 3.5 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 0.5 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/no_side_kick/on_apply()
	// Once again, clear if dead
	if(owner.stat == DEAD)
		return FALSE
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_on_death))
	ADD_TRAIT(owner, TRAIT_NO_SIDE_KICK, STATUS_EFFECT_TRAIT)
	return TRUE

/datum/status_effect/no_side_kick/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH))
	REMOVE_TRAIT(owner, TRAIT_NO_SIDE_KICK, STATUS_EFFECT_TRAIT)

/datum/status_effect/no_side_kick/proc/clear_on_death(mob/living/source)
	SIGNAL_HANDLER

	qdel(src)
