/datum/status_effect/drowsiness
	id = "drowsiness"
	tick_interval = 1 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE
	/// The first trigger is more likely than subsequent ones
	VAR_PRIVATE/triggered = FALSE
	/// Tracks the last time we took stamina damage
	COOLDOWN_DECLARE(last_stam_damage)

/datum/status_effect/drowsiness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/drowsiness/on_apply()
	if(HAS_TRAIT(owner, TRAIT_SLEEPIMMUNE) || !(owner.status_flags & CANUNCONSCIOUS))
		return FALSE
	// Do robots dream of electric sheep?
	if(issilicon(owner))
		return FALSE

	// Assume we recently took stamina damage if our current stamina loss is above the threshold
	if(owner.get_stamina_loss() > stamina_threshold())
		COOLDOWN_START(src, last_stam_damage, owner.stamina_regen_time * 0.75)

	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(on_face_clean))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damaged))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_SLEEPIMMUNE), PROC_REF(now_sleep_immune))
	RegisterSignal(owner, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(owner_sleeping))
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/status_effect/drowsy)
	return TRUE

/datum/status_effect/drowsiness/on_remove()
	UnregisterSignal(owner, list(COMSIG_COMPONENT_CLEAN_FACE_ACT, COMSIG_MOB_APPLY_DAMAGE, SIGNAL_ADDTRAIT(TRAIT_SLEEPIMMUNE), COMSIG_LIVING_STATUS_SLEEP))
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/status_effect/drowsy)

/// Signal proc for [COMSIG_COMPONENT_CLEAN_FACE_ACT]. When we wash our face, reduce drowsiness by a bit.
/datum/status_effect/drowsiness/proc/on_face_clean(datum/source)
	SIGNAL_HANDLER

	remove_duration(rand(4 SECONDS, 6 SECONDS))

/// Signal proc for [COMSIG_LIVING_APPLY_DAMAGE]. When we take stamina damage, start the cooldown
/datum/status_effect/drowsiness/proc/damaged(datum/source, damage_amount, damage_type, ...)
	SIGNAL_HANDLER

	// This is done to try to avoid drowsy into stun baton true combos
	if(damage_type == STAMINA)
		COOLDOWN_START(src, last_stam_damage, owner.stamina_regen_time)

/// Signal proc for [SIGNAL_ADDTRAIT(TRAIT_SLEEPIMMUNE)]. When we gain sleep immunity, remove the drowsiness effect.
/datum/status_effect/drowsiness/proc/now_sleep_immune(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// Signal proc for [COMSIG_LIVING_STATUS_SLEEP]. When the owner falls asleep, reduce duration of our effect
/datum/status_effect/drowsiness/proc/owner_sleeping(datum/source, amount)
	SIGNAL_HANDLER

	remove_duration((amount * 2) / (1 SECONDS))

/datum/status_effect/drowsiness/tick(seconds_between_ticks)
	// You do not feel drowsy while unconscious or in stasis
	if(IS_UNCONSCIOUS(owner) || HAS_TRAIT(owner, TRAIT_STASIS))
		return

	// Resting helps against drowsiness
	// While resting, we lose 4 seconds of duration (2 additional ticks) per tick
	if(is_resting() && remove_duration(2 * seconds_between_ticks))
		return

	owner.set_eye_blur_if_lower(4 SECONDS)

	// Occasionally cause stamina damage if the cooldown is not active or we're below a certain threshold based on remaining drowsiness
	if(SPT_PROB(triggered ? 80 : 50, seconds_between_ticks) && (COOLDOWN_FINISHED(src, last_stam_damage) || owner.get_stamina_loss() < stamina_threshold()))
		owner.adjust_stamina_loss(rand(9, 13))
		if(!triggered)
			to_chat(owner, span_warning("You feel tired..."))
			triggered = TRUE

	var/final_damage = owner.get_stamina_loss()
	if((final_damage > owner.maxHealth || SPT_PROB((final_damage - 50) / 2, seconds_between_ticks)) && !owner.IsSleeping())
		owner.Sleeping(max(owner.stamina_regen_time, rand(9, 13) SECONDS))
		COOLDOWN_START(src, last_stam_damage, owner.stamina_regen_time)

/// Checks if we're considering to be in a restful state for the purposes of reducing drowsiness
/datum/status_effect/drowsiness/proc/is_resting()
	if((owner.buckled || owner.resting) && owner.body_position == LYING_DOWN)
		return TRUE
	if(HAS_TRAIT_FROM(owner, TRAIT_UNDENSE, LEANING_TRAIT))
		return TRUE
	return FALSE

/// Threshold to which we cap stamina damage while the stamina damage cooldown is active
/datum/status_effect/drowsiness/proc/stamina_threshold()
	return round(duration / (1 SECONDS), 1) * 10
