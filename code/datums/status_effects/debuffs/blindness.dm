/// Helper macro, for ease of expanding checks for mobs which cannot be blinded
/// There are no reason why these cannot be blinded, it is simply for "design reasons" (these things shouldn't be blinded)
#define CAN_BE_BLIND(mob) (!isanimal_or_basicmob(mob) && !isbrain(mob) && !isrevenant(mob))

/// Nearsighted
/datum/status_effect/grouped/nearsighted
	id = "nearsighted"
	tick_interval = -1
	alert_type = null
	// This is not "remove on fullheal" as in practice,
	// fullheal should instead remove all the sources and in turn cure this

	/// Static list of signals that, when recieved, we force an update to our nearsighted overlay
	var/static/list/update_signals = list(SIGNAL_ADDTRAIT(TRAIT_NEARSIGHTED_CORRECTED), SIGNAL_REMOVETRAIT(TRAIT_NEARSIGHTED_CORRECTED))
	/// How severe is our nearsightedness right now
	var/overlay_severity = 1

/datum/status_effect/grouped/nearsighted/on_apply()
	RegisterSignals(owner, update_signals, PROC_REF(update_nearsightedness))
	update_nearsighted_overlay()
	return ..()

/datum/status_effect/grouped/nearsighted/on_remove()
	UnregisterSignal(owner, update_signals)
	owner.clear_fullscreen(id)
	return ..()

/// Signal proc for when we gain or lose [TRAIT_NEARSIGHTED_CORRECTED] - (temporarily) disable the overlay if we're correcting it
/datum/status_effect/grouped/nearsighted/proc/update_nearsightedness(datum/source)
	SIGNAL_HANDLER

	update_nearsighted_overlay()

/// Checks if we should be nearsighted currently, or if we should clear the overlay
/datum/status_effect/grouped/nearsighted/proc/should_be_nearsighted()
	return !HAS_TRAIT(owner, TRAIT_NEARSIGHTED_CORRECTED)

/// Updates our nearsightd overlay, either removing it if we have the trait or adding it if we don't
/datum/status_effect/grouped/nearsighted/proc/update_nearsighted_overlay()
	if(should_be_nearsighted())
		owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/impaired, overlay_severity)
	else
		owner.clear_fullscreen(id)

/// Sets the severity of our nearsighted overlay
/datum/status_effect/grouped/nearsighted/proc/set_nearsighted_severity(to_value)
	if(!isnum(to_value))
		return
	if(overlay_severity == to_value)
		return

	overlay_severity = to_value
	update_nearsighted_overlay()

/// Blindness
/datum/status_effect/grouped/blindness
	id = "blindness"
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/blind
	// This is not "remove on fullheal" as in practice,
	// fullheal should instead remove all the sources and in turn cure this

/datum/status_effect/grouped/blindness/on_apply()
	if(!CAN_BE_BLIND(owner))
		return FALSE

	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/blind)
	// You are blind - at most, able to make out shapes near you
	owner.add_client_colour(/datum/client_colour/monochrome/blind)
	return ..()

/datum/status_effect/grouped/blindness/on_remove()
	owner.clear_fullscreen(id)
	owner.remove_client_colour(/datum/client_colour/monochrome/blind)
	return ..()

/atom/movable/screen/alert/status_effect/blind
	name = "Blind"
	desc = "You can't see! This may be caused by a genetic defect, eye trauma, being unconscious, or something covering your eyes."
	icon_state = "blind"

/// This status effect handles applying a temporary blind to the mob.
/datum/status_effect/temporary_blindness
	id = "temporary_blindness"
	tick_interval = 2 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/temporary_blindness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/temporary_blindness/on_apply()
	if(!CAN_BE_BLIND(owner))
		return FALSE

	owner.become_blind(id)
	return TRUE

/datum/status_effect/temporary_blindness/on_remove()
	owner.cure_blind(id)

/datum/status_effect/temporary_blindness/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return

	// Temp. blindness heals faster if our eyes are covered
	if(!owner.is_blind_from(EYES_COVERED))
		return

	// Knocks 2 seconds off of our duration
	// If we should be deleted, give a message letting them know
	var/mob/living/stored_owner = owner
	if(remove_duration(2 SECONDS))
		to_chat(stored_owner, span_green("Your eyes start to feel better!"))
		return

	// Otherwise add a chance to let them know that it's working
	else if(SPT_PROB(5, seconds_between_ticks))
		var/obj/item/thing_covering_eyes = owner.is_eyes_covered()
		// "Your blindfold soothes your eyes", for example
		to_chat(owner, span_green("Your [thing_covering_eyes?.name || "eye covering"] soothes your eyes."))

#undef CAN_BE_BLIND
