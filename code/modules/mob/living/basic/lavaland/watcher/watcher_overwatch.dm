/**
 * Automatically shoot at a target if they do anything while this is active on them.
 * Currently not given to any mob, but retained so admins can use it.
 */
/datum/action/cooldown/mob_cooldown/watcher_overwatch
	name = "Overwatch"
	desc = "Keep a close eye on the target's actions, automatically firing upon them if they act."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 20 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	/// Furthest range we can activate ability at
	var/max_range = 7
	/// Type of projectile to fire
	var/projectile_type = /obj/projectile/temp/watcher
	/// Sound the projectile we fire makes
	var/projectile_sound = 'sound/weapons/pierce.ogg'
	/// Time to watch for
	var/overwatch_duration = 3 SECONDS

/datum/action/cooldown/mob_cooldown/watcher_overwatch/New(Target, original)
	. = ..()
	melee_cooldown_time = overwatch_duration

/datum/action/cooldown/mob_cooldown/watcher_overwatch/PreActivate(atom/target)
	if (target == owner)
		return
	if (ismecha(target))
		var/obj/vehicle/sealed/mecha/mech = target
		var/list/drivers = mech.return_drivers()
		if (!length(drivers))
			return
		target = drivers[1]
	if (!isliving(target))
		return
	if (get_dist(owner, target) > max_range)
		return
	return ..()

/datum/action/cooldown/mob_cooldown/watcher_overwatch/Activate(mob/living/target)
	var/mob/living/living_owner = owner
	living_owner.face_atom(target)
	living_owner.Stun(overwatch_duration, ignore_canstun = TRUE)
	target.apply_status_effect(/datum/status_effect/overwatch, overwatch_duration, owner, projectile_type, projectile_sound)
	owner.visible_message(span_warning("[owner]'s eye locks on to [target]!"))
	StartCooldown()
	return TRUE

/// Status effect which tracks whether our overwatched mob moves or acts
/datum/status_effect/overwatch
	id = "watcher_overwatch"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/overwatch
	/// Distance at which we break off the ability
	var/watch_range = 9
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
		COMSIG_MOB_ABILITY_FINISHED,
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_MOB_DROVE_MECH,
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_THROW,
		COMSIG_MOB_USED_MECH_EQUIPMENT,
		COMSIG_MOB_USED_MECH_MELEE,
		COMSIG_MOVABLE_MOVED,
	)

/datum/status_effect/overwatch/on_creation(mob/living/new_owner, set_duration, mob/living/watcher, projectile_type, projectile_sound)
	if (isnull(watcher) || isnull(projectile_type))
		return FALSE
	if (HAS_TRAIT(new_owner, TRAIT_OVERWATCH_IMMUNE))
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
		return FALSE
	owner.add_traits(list(TRAIT_OVERWATCHED, TRAIT_OVERWATCH_IMMUNE), TRAIT_STATUS_EFFECT(id))
	owner.do_alert_animation()
	owner.Immobilize(0.25 SECONDS) // Just long enough that they don't trigger it by mistake
	owner.playsound_local(owner, 'sound/machines/chime.ogg', 50, TRUE)
	var/atom/beam_origin = ismecha(owner.loc) ? owner.loc : owner
	link = beam_origin.Beam(watcher, icon_state = "r_beam", override_target_pixel_x = 0)
	RegisterSignals(owner, forbidden_actions, PROC_REF(opportunity_attack))
	RegisterSignals(owner, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_participant_died))
	RegisterSignals(watcher, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_participant_died))

/datum/status_effect/overwatch/on_remove()
	UnregisterSignal(owner, forbidden_actions + list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	QDEL_NULL(link)
	owner.remove_traits(list(TRAIT_OVERWATCHED, TRAIT_OVERWATCH_IMMUNE), TRAIT_STATUS_EFFECT(id))
	if (!QDELETED(owner))
		owner.apply_status_effect(/datum/status_effect/overwatch_immune)
	return ..()

/datum/status_effect/overwatch/Destroy()
	QDEL_NULL(link)
	if (!isnull(watcher))  // Side effects in Destroy? Well it turns out `on_remove` is also just called on Destroy. But only if the owner isn't deleting.
		INVOKE_ASYNC(src, PROC_REF(unregister_watcher), watcher)
		watcher = null

	return ..()

/// Clean up our association with the caster of this ability.
/datum/status_effect/overwatch/proc/unregister_watcher(mob/living/former_overwatcher)
	if (!overwatch_triggered)
		former_overwatcher.Stun(2 SECONDS, ignore_canstun = TRUE)
	UnregisterSignal(former_overwatcher, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))

/// Uh oh, you did something within my threat radius, now we're going to shoot you
/datum/status_effect/overwatch/proc/opportunity_attack()
	SIGNAL_HANDLER
	if (!can_see(watcher, owner, length = watch_range))
		qdel(src)
		return
	overwatch_triggered = TRUE
	watcher.do_alert_animation()
	INVOKE_ASYNC(watcher, TYPE_PROC_REF(/atom/, fire_projectile), projectile_type, owner, projectile_sound)

/// Can't overwatch you if I don't exist
/datum/status_effect/overwatch/proc/on_participant_died()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/overwatch
	name = "Overwatched"
	desc = "Freeze! You are being watched!"
	icon_state = "aimed"

/// Blocks further applications of the ability for a little while
/datum/status_effect/overwatch_immune
	id = "watcher_overwatch_immunity"
	duration = 10 SECONDS // To stop watcher tendrils spamming the shit out of you
	alert_type = null

/datum/status_effect/overwatch_immune/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_OVERWATCH_IMMUNE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/overwatch_immune/on_remove()
	REMOVE_TRAIT(owner, TRAIT_OVERWATCH_IMMUNE, TRAIT_STATUS_EFFECT(id))
	return ..()
