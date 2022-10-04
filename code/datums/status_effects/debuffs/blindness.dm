/// Helper macro, for ease of expanding checks for mobs which cannot be blinded
/// There are no reason why these cannot be blinded, it is simply for "design reasons" (these things shouldn't be blinded)
#define CAN_BE_BLIND(mob) (!isanimal_or_basicmob(mob) && !isbrain(mob) && !isrevenant(mob))

/// Grouped status effect that applies a visual imparity (a fullscreen overlay)
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
	if(!CAN_BE_BLIND(owner))
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

/datum/status_effect/temporary_blindness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/temporary_blindness/on_apply()
	if(!CAN_BE_BLIND(owner))
		return FALSE

	owner.become_blind(id)
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/remove_temp_blindness)
	return TRUE

/datum/status_effect/temporary_blindness/on_remove()
	owner.cure_blind(id)
	UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)

/datum/status_effect/temporary_blindness/tick(delta_time, times_fired)
	if(owner.stat == DEAD)
		return

	// Temp. blindness heals faster if our eyes are covered
	if(owner.is_blind_from(EYES_COVERED))
		// Knocks 2 seconds off of our duration
		duration -= 2 SECONDS

		// If we should be deleted, give a message letting them know
		if(duration < world.time)
			to_chat(owner, span_green("Your eyes start to feel better!"))
			qdel(src)

		// Otherwise add a chance to let them know that it's working
		else if(DT_PROB(5, delta_time))
			var/obj/item/thing_covering_eyes = owner.is_eyes_covered()
			// "Your blindfold soothes your eyes", for example
			to_chat(owner, span_green("Your [thing_covering_eyes?.name || "eye covering"] soothes your eyes."))

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL]. When healed, self delete
/datum/status_effect/temporary_blindness/proc/remove_temp_blindness(datum/source)
	SIGNAL_HANDLER

	qdel(src)

#undef CAN_BE_BLIND

// I wish these could be macros but an inordinate amount of places
// check for blindness for mobs which are not typecasted to living
// which I don't want to go through and sort out, so here we are for now

/// Checks if this mob is blind.
/mob/proc/is_blind()
	return FALSE

/mob/living/is_blind()
	return !!has_status_effect(/datum/status_effect/grouped/visually_impaired/blindness)

/// Checks if this mob is blind from one or multiple sources.
/// Can be passed a list of sources or a singular non-list source.
/mob/proc/is_blind_from(sources)
	return FALSE

/mob/living/is_blind_from(sources)
	return !!has_status_effect_from_source(/datum/status_effect/grouped/visually_impaired/blindness, sources)

/// Checks if this mob is nearsighted.
/// This will pass on all mobs that are nearsighted, including those which have it disabled temporarily.
/mob/proc/is_nearsighted()
	return FALSE

/mob/living/is_nearsighted()
	return !!has_status_effect(/datum/status_effect/grouped/visually_impaired/nearsighted)

/// Checks if this mob is nearsighted, currently.
/// This will only pass on mobs which are nearsighted but have it disabled temporarily (by glasses).
/mob/proc/is_nearsighted_currently()
	return FALSE

/mob/living/is_nearsighted_currently()
	return !HAS_TRAIT(src, TRAIT_NEARSIGHTED_CORRECTED) && is_nearsighted()

/// Checks if this mob is nearsighted from one or multiple sources.
/// Can be passed a list of sources or a singular non-list source.
/mob/proc/is_nearsighted_from(sources)
	return FALSE

/mob/living/is_nearsighted_from(sources)
	return !!has_status_effect_from_source(/datum/status_effect/grouped/visually_impaired/blindness, sources)
