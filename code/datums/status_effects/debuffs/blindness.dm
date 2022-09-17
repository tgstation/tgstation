/// Helper macro, for ease of expanding checks for mobs which cannot be blinded
#define can_be_blind(mob) !isanimal_or_basicmob(mob) && !isbrain(mob)

/datum/status_effect/grouped/visually_impaired
	alert_type = null
	/// A list of sources we remove when we're fullhealed. If no sources remain, we will self-delete.
	var/static/list/sources_removed_on_fullheal = list(EYE_DAMAGE)
	/// What overlay do we give out?
	var/overlay_type = /atom/movable/screen/fullscreen/impaired
	/// What serverity to give to the overlay? Can be null (no severity)
	var/overlay_severity

/datum/status_effect/grouped/visually_impaired/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/on_full_heal)
	apply_fullscreen_overlay()
	return TRUE

/datum/status_effect/grouped/visually_impaired/on_remove()
	owner.clear_fullscreen(id)
	UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)

/datum/status_effect/grouped/visually_impaired/proc/apply_fullscreen_overlay()
	owner.overlay_fullscreen(id, overlay_type, overlay_severity)

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL].
/// Getting fully healed will remove eye damage from sources, and self-delete if we have none
/datum/status_effect/grouped/visually_impaired/proc/on_full_heal(datum/source)
	SIGNAL_HANDLER

	sources -= sources_removed_on_fullheal
	if(!length(sources))
		qdel(src)

/// Nearsighted
/datum/status_effect/grouped/visually_impaired/nearsighted
	id = "nearsighted"
	overlay_severity = 1

/datum/status_effect/grouped/visually_impaired/nearsighted/on_apply()
	. = ..()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NEARSIGHTED_CORRECTED), .proc/stop_nearsightedness)
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NEARSIGHTED_CORRECTED), .proc/resume_nearsightedness)

/datum/status_effect/grouped/visually_impaired/nearsighted/on_remove()
	UnregisterSignal(owner, list(
		SIGNAL_ADDTRAIT(TRAIT_NEARSIGHTED_CORRECTED),
		SIGNAL_REMOVETRAIT(TRAIT_NEARSIGHTED_CORRECTED),
	))
	return ..()

/datum/status_effect/grouped/visually_impaired/nearsighted/apply_fullscreen_overlay()
	if(HAS_TRAIT(owner, TRAIT_NEARSIGHTED_CORRECTED))
		return
	return ..()

/// Signal proc for when we gain [TRAIT_NEARSIGHTED_CORRECTED] - (temporarily) disable the overlay if we're correcting it
/datum/status_effect/grouped/visually_impaired/nearsighted/proc/stop_nearsightedness(datum/source)
	SIGNAL_HANDLER

	apply_fullscreen_overlay()

/// Signal proc for when we gain [TRAIT_NEARSIGHTED_CORRECTED] - re-enable the overlay
/datum/status_effect/grouped/visually_impaired/nearsighted/proc/resume_nearsightedness(datum/source)
	SIGNAL_HANDLER

	owner.clear_fullscreen(id)


/// Blindness
/datum/status_effect/grouped/visually_impaired/blindness
	id = "blindness"
	alert_type = /atom/movable/screen/alert/status_effect/blind
	overlay_type = /atom/movable/screen/fullscreen/blind

/datum/status_effect/grouped/visually_impaired/blindness/on_apply()
	if(!can_be_blind(owner)) // No reason why they can't be blind other than design decisions
		return FALSE

	. = ..()
	// You are blind - at most, able to make out shapes near you
	owner.add_client_colour(/datum/client_colour/monochrome/blind)

/datum/status_effect/grouped/visually_impaired/blindness/on_remove()
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

/datum/status_effect/temporary_blindness/on_apply()
	if(!can_be_blind(owner))
		return FALSE

	owner.become_blind(id)
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/remove_temp_blindness)
	return TRUE

/datum/status_effect/temporary_blindness/on_remove()
	owner.cure_blind(id)
	UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)

/datum/status_effect/temporary_blindness/tick(delta_time, times_fired)
	// Temp. blindness heals faster if our eyes are covered
	if(owner.stat != DEAD && owner.is_blind_from(EYES_COVERED))
		duration -= 2 SECONDS

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL]. When healed, self delete
/datum/status_effect/temporary_blindness/proc/remove_temp_blindness(datum/source)
	SIGNAL_HANDLER

	qdel(src)

#undef can_be_blind
