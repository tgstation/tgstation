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
	cooldown_time = 16 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	/// Furthest range we can activate ability at
	var/max_range = 7
	/// Type of projectile to fire
	var/projectile_type = /obj/projectile/temp/watcher
	/// Sound the projectile we fire makes
	var/projectile_sound = 'sound/weapons/pierce.ogg'
	/// Time to watch for
	var/overwatch_duration = 4 SECONDS

/datum/action/cooldown/watcher_overwatch/New(Target, original)
	. = ..()
	melee_cooldown_time = overwatch_duration

/datum/action/cooldown/watcher_overwatch/PreActivate(atom/target)
	if (!isliving(target))
		return
	if (get_dist(owner, target) > max_range)
		return
	return ..()

/datum/action/cooldown/watcher_overwatch/Activate(mob/living/target)
	var/mob/living/living_owner = owner
	living_owner.face_atom(target)
	living_owner.Stun(overwatch_duration, ignore_canstun = TRUE)
	target.apply_status_effect(/datum/status_effect/overwatch, overwatch_duration, owner, projectile_type, projectile_sound)
	return ..()

/// Status effect which tracks whether our overwatched mob moves or acts
/datum/status_effect/overwatch
	id = "watcher_overwatch"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/overwatch
	/// Visual effect to make the status obvious
	var/datum/beam/link
	/// Which watcher is watching?
	var/mob/living/watcher
	/// Type of projectile to fire
	var/projectile_type
	/// Noise to make when we shoot beam
	var/projectile_sound
	/// Did the overwatch ever trigger during our run?
	var/overwatch_triggered = FALSE
	/// Signals which trigger a hostile response
	var/static/list/forbidden_actions = list(
		COMSIG_MOB_ABILITY_STARTED,
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_THROW,
		COMSIG_MOVABLE_MOVED,
	)

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
	owner.do_alert_animation()
	owner.Immobilize(0.25 SECONDS) // Just long enough that they don't trigger it by mistake
	owner.playsound_local(owner, 'sound/machines/chime.ogg', 50, TRUE)
	link = owner.Beam(watcher, icon_state = "r_beam", override_target_pixel_x = 0)
	RegisterSignals(owner, forbidden_actions, PROC_REF(opportunity_attack))
	RegisterSignals(watcher, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_watcher_died))

/datum/status_effect/overwatch/on_remove()
	UnregisterSignal(owner, forbidden_actions)
	UnregisterSignal(watcher, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	QDEL_NULL(link)
	if (!overwatch_triggered && !QDELETED(watcher))
		watcher.Stun(2 SECONDS, ignore_canstun = TRUE) // Reward for standing still
	watcher = null
	return ..()

/// Uh oh, you did something within my threat radius, now we're going to shoot you
/datum/status_effect/overwatch/proc/opportunity_attack()
	SIGNAL_HANDLER
	if (!can_see(watcher, owner))
		qdel(src)
		return
	overwatch_triggered = TRUE
	INVOKE_ASYNC(watcher, TYPE_PROC_REF(/atom/, fire_projectile), projectile_type, owner, projectile_sound)

/// Can't overwatch you if I don't exist
/datum/status_effect/overwatch/proc/on_watcher_died()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/overwatch
	name = "Overwatched"
	desc = "Freeze! You are being watched!"
	icon_state = "aimed"
