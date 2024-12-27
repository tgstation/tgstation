/**
 * # Stun absorption
 *
 * A status effect effectively functions as [TRAIT_STUNIMMUNE], but with additional effects tied to it,
 * such as showing a message on trigger / examine, or only blocking a limited amount of stuns.
 *
 * Apply this via [/mob/living/proc/add_stun_absorption]. If you do not supply a duration,
 * remove this via [/mob/living/proc/remove_stun_absorption].
 */
/datum/status_effect/stun_absorption
	id = "absorb_stun"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE

	/// The string key sourcer of the stun absorption, used for logging
	var/source
	/// The priority of the stun absorption. Used so that multiple sources will not trigger at once.
	/// This number is arbitrary but try to keep in sane / in line with other sources that exist.
	var/priority = -1
	/// How many total seconds of stuns that have been blocked.
	var/seconds_of_stuns_absorbed = 0 SECONDS
	/// The max number of seconds we can block before self-deleting.
	var/max_seconds_of_stuns_blocked = INFINITY
	/// The message shown via visible message to all nearby mobs when the effect triggers.
	var/shown_message
	/// The message shown  to the owner when the effect triggers.
	var/self_message
	/// Message shown on anyone examining the owner.
	var/examine_message
	/// If TRUE, after passing the max seconds of stuns blocked, we will delete ourself.
	/// If FALSE, we will instead recharge after some time.
	var/delete_after_passing_max
	/// If [delete_after_passing_max] is FALSE, this is how long we will wait before recharging.
	var/recharge_time

	/// Static list of all generic "stun received " signals that we will react to and block.
	/// These all have the same arguments sent, so we can handle them all via the same signal handler.
	/// Note though that we can register other signals to block effects outside of these if we want.
	var/static/list/incapacitation_effect_signals = list(
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_INCAPACITATE,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_STUN,
	)

/datum/status_effect/stun_absorption/on_creation(
	mob/living/new_owner,
	source,
	duration,
	priority = -1,
	shown_message,
	self_message,
	examine_message,
	max_seconds_of_stuns_blocked = INFINITY,
	delete_after_passing_max = TRUE,
	recharge_time = 1 MINUTES,
)

	if(isnum(duration))
		src.duration = duration

	src.source = source
	src.priority = priority
	src.shown_message = shown_message
	src.self_message = self_message
	src.examine_message = examine_message
	src.max_seconds_of_stuns_blocked = max_seconds_of_stuns_blocked
	src.delete_after_passing_max = delete_after_passing_max
	src.recharge_time = recharge_time

	return ..()

/datum/status_effect/stun_absorption/on_apply()
	if(owner.mind || owner.client)
		owner.log_message("gained stun absorption (from: [source || "Unknown"])", LOG_ATTACK)

	RegisterSignals(owner, incapacitation_effect_signals, PROC_REF(try_absorb_incapacitating_effect))
	RegisterSignal(owner, COMSIG_LIVING_GENERIC_STUN_CHECK, PROC_REF(try_absorb_generic_effect))
	return TRUE

/datum/status_effect/stun_absorption/on_remove()
	if(owner.mind || owner.client)
		owner.log_message("lost stun absorption (from: [source || "Unknown"])", LOG_ATTACK)

	UnregisterSignal(owner, incapacitation_effect_signals)
	UnregisterSignal(owner, COMSIG_LIVING_GENERIC_STUN_CHECK)

/datum/status_effect/stun_absorption/get_examine_text()
	if(can_absorb_stun())
		return replacetext(examine_message, "%EFFECT_OWNER_THEYRE", owner.p_Theyre())
	return null // no message if we can't absorb stuns, duh.

/**
 * Signal proc for generic stun signals being sent, such as [COMSIG_LIVING_STATUS_STUN] or [COMSIG_LIVING_STATUS_KNOCKDOWN].
 *
 * When we get stunned, we will try to absorb a number of seconds from the stun, and return [COMPONENT_NO_STUN] if we succeed.
 */
/datum/status_effect/stun_absorption/proc/try_absorb_incapacitating_effect(mob/living/source, amount = 0, ignore_canstun = FALSE)
	SIGNAL_HANDLER

	// we blocked a stun this tick that resulting is us qdeling, so stop
	if(QDELING(src))
		return NONE

	// Amount less than (or equal to) zero is removing stuns, so we don't want to block that
	if(amount <= 0 || ignore_canstun)
		return NONE

	if(!absorb_stun(amount))
		return NONE

	return COMPONENT_NO_STUN

/**
 * Signal proc for [COMSIG_LIVING_GENERIC_STUN_CHECK]. (Note, this includes being stamcrit)
 *
 * Whenever a generic stun check is done against us, we'll just try to block it with "0 second" stun.
 * This prevents spam us from showing feedback messages, and is for the generic "can be stunned" check.
 */
/datum/status_effect/stun_absorption/proc/try_absorb_generic_effect(mob/living/source, check_flags)
	SIGNAL_HANDLER

	if(QDELING(src))
		return NONE

	// "0 amount" / "0 seconds of stun" is used so no feedback is sent on success
	if(!absorb_stun(0))
		return NONE

	return COMPONENT_NO_STUN

/// Simply checks if the owner of the effect is in a valid state to absorb stuns.
/datum/status_effect/stun_absorption/proc/can_absorb_stun()
	if(owner.stat != CONSCIOUS)
		return FALSE
	if(seconds_of_stuns_absorbed > max_seconds_of_stuns_blocked)
		return FALSE
	return TRUE

/**
 * Absorb a number of seconds of stuns.
 * If we hit the max amount of absorption, we will qdel ourself in this proc.
 *
 * * amount - this is the number of deciseconds being absorbed at once.
 *
 * Returns TRUE on successful absorption, or FALSE otherwise.
 */
/datum/status_effect/stun_absorption/proc/absorb_stun(amount)
	if(!can_absorb_stun())
		return FALSE

	// Now we gotta check that no other stun absorption we have is blocking us
	for(var/datum/status_effect/stun_absorption/similar_effect in owner.status_effects)
		if(similar_effect == src)
			continue
		// they blocked a stun this tick that resulted in them qdeling, so disregard
		if(QDELING(similar_effect))
			continue
		// if we have another stun absorption with higher priority,
		// don't do anything, let them handle it instead
		if(similar_effect.priority > priority)
			return FALSE

	// At this point, a stun was successfully absorbed

	// Only do effects if the amount was > 0 seconds
	if(amount > 0 SECONDS)
		// Show the message
		if(shown_message)
			// We do this replacement meme, instead of just setting it up in creation,
			// so that we respect indentity changes done while active
			var/really_shown_message = replacetext(shown_message, "%EFFECT_OWNER", "[owner]")
			owner.visible_message(really_shown_message, ignored_mobs = owner)

		// Send the self message
		if(self_message)
			to_chat(owner, self_message)

		// Count seconds absorbed
		seconds_of_stuns_absorbed += amount
		if(delete_after_passing_max)
			if(seconds_of_stuns_absorbed >= max_seconds_of_stuns_blocked)
				qdel(src)

		else if(recharge_time > 0 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(recharge_absorption), amount), recharge_time)

	return TRUE

/// Used in callbacks to "recharge" the effect after passing the max seconds of stuns blocked.
/datum/status_effect/stun_absorption/proc/recharge_absorption(amount)
	seconds_of_stuns_absorbed = max(seconds_of_stuns_absorbed - amount, 0)

/**
 * [proc/apply_status_effect] wrapper specifically for [/datum/status_effect/stun_absorption],
 * specifically so that it's easier to apply stun absorptions with named arguments.
 *
 * If the mob already has a stun absorption from the same source, will not re-apply the effect,
 * unless the new effect's priority is higher than the old effect's priority.
 *
 * Arguments
 * * source - the source of the stun absorption.
 * * duration - how long does the stun absorption last before it ends? -1 or null (or infinity) = infinite duration
 * * priority - what is this effect's priority to other stun absorptions? higher = more priority
 * * message - optional, "other message" arg of visible message, shown on trigger. Use %EFFECT_OWNER if you want the owner's name to be inserted.
 * * self_message - optional, "self message" arg of visible message, shown on trigger
 * * examine_message - optional, what is shown on examine of the mob.
 * * max_seconds_of_stuns_blocked - optional, how many seconds of stuns can it block before deleting? the stun that breaks over this number is still blocked, even if it is much higher.
 * * delete_after_passing_max - optional, if TRUE, after passing the max seconds of stuns blocked, we will delete ourself.
 * If FALSE, we will instead recharge after some time.
 * * recharge_time - optional, if [delete_after_passing_max] is FALSE, this is how long we will wait before recharging.
 * does nothing if [delete_after_passing_max] is TRUE.
 *
 * Returns an instance of a stun absorption effect, or NULL if failure
 */
/mob/living/proc/add_stun_absorption(
	source,
	duration,
	priority = -1,
	message,
	self_message,
	examine_message,
	max_seconds_of_stuns_blocked = INFINITY,
	delete_after_passing_max = TRUE,
	recharge_time,
	recharge_alert,
)

	// Handle duplicate sources
	for(var/datum/status_effect/stun_absorption/existing_effect in status_effects)
		if(existing_effect.source != source)
			continue

		// If an existing effect's priority is greater or equal to our passed priority...
		if(existing_effect.priority >= priority)
			// don't bother re-applying the effect, and return
			return

		// otherwise, delete existing and replace with new
		qdel(existing_effect)

	return apply_status_effect(
		/datum/status_effect/stun_absorption,
		source,
		duration,
		priority,
		message,
		self_message,
		examine_message,
		max_seconds_of_stuns_blocked,
		delete_after_passing_max,
		recharge_time,
	)

/**
 * Removes all stub absorptions with the passed source.
 *
 * Returns TRUE if an effect was deleted, FALSE otherwise
 */
/mob/living/proc/remove_stun_absorption(source)
	. = FALSE
	for(var/datum/status_effect/stun_absorption/effect in status_effects)
		if(effect.source != source)
			continue

		qdel(effect)
		. = TRUE

	return .
