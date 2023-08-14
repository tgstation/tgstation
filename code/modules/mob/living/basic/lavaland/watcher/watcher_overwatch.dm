/**
 * Automatically shoot at a target if they do anything while this is active on them.
 */
/datum/action/cooldown/watcher_overwatch
	name = "Overwatch"
	desc = "Keep a close eye on the target's actions, automatically firing upon them if they act."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	/// Furthest range we can activate ability at
	var/max_range = 7
	/// Type of projectile to fire
	var/projectile_type = /obj/projectile/temp/watcher
	/// Time to watch for
	var/overwatch_duration = 500 SECONDS

/datum/action/cooldown/watcher_overwatch/New(Target, original)
	. = ..()
	melee_cooldown_time = overwatch_duration

/datum/action/cooldown/watcher_overwatch/PreActivate(atom/target)
	if (!isliving(target))
		return
	return ..()

/datum/action/cooldown/watcher_overwatch/Activate(mob/living/target)
	var/mob/living/living_owner = owner
	living_owner.face_atom(target)
	living_owner.Stun(overwatch_duration, ignore_canstun = TRUE)
	target.apply_status_effect(/datum/status_effect/overwatch, overwatch_duration, owner, projectile_type)
	return ..()

/datum/status_effect/overwatch
	id = "watcher_overwatch"
	duration = 5 SECONDS
	/// Visual effect to make the status obvious
	var/datum/beam/link
	/// Which watcher is watching?
	var/mob/living/watcher
	/// Type of projectile to fire
	var/projectile_type
	/// Noise to make when we shoot beam
	var/projectile_sound

/datum/status_effect/overwatch/on_creation(mob/living/new_owner, set_duration, mob/living/watcher, projectile_type, projectile_sound)
	if (isnull(watcher) || isnull(projectile_type))
		return FALSE
	src.watcher = watcher
	src.projectile_type = projectile_type
	src.projectile_sound = projectile_sound
	if (!isnull(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/overwatch/on_apply()
	. = ..()
	if (!.)
		return
	link = watcher.Beam(owner, icon_state = "r_beam", override_origin_pixel_x = 0)
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ITEM_AFTERATTACK, COMSIG_MOB_THROW), PROC_REF(opportunity_attack))
	RegisterSignals(watcher, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_watcher_died))

/datum/status_effect/overwatch/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ITEM_AFTERATTACK, COMSIG_MOB_THROW))
	UnregisterSignal(watcher, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	QDEL_NULL(link)
	watcher = null
	return ..()

/// Uh oh, you did something within my threat radius, now we're going to shoot you
/datum/status_effect/overwatch/proc/opportunity_attack()
	SIGNAL_HANDLER
	if (!can_see(watcher, owner))
		qdel(src)
		return
	INVOKE_ASYNC(watcher, TYPE_PROC_REF(/atom/, fire_projectile), projectile_type, owner, projectile_sound)

/datum/status_effect/overwatch/proc/on_watcher_died()
	SIGNAL_HANDLER
	qdel(src)
