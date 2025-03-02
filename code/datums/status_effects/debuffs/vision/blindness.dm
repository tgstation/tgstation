/// Helper macro, for ease of expanding checks for mobs which cannot be blinded
/// There are no reason why these cannot be blinded, it is simply for "design reasons" (these things shouldn't be blinded)
#define CAN_BE_BLIND(mob) (!isanimal_or_basicmob(mob) && !isbrain(mob) && !isrevenant(mob))

/// Blindness
/datum/status_effect/grouped/blindness
	id = "blindness"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/blind
	var/static/list/update_signals = list(
		SIGNAL_REMOVETRAIT(TRAIT_SIGHT_BYPASS),
		SIGNAL_ADDTRAIT(TRAIT_SIGHT_BYPASS),
	)
	// This is not "remove on fullheal" as in practice,
	// fullheal should instead remove all the sources and in turn cure this

/datum/status_effect/grouped/blindness/on_apply()
	if(!CAN_BE_BLIND(owner))
		return FALSE

	RegisterSignals(owner, update_signals, PROC_REF(update_blindness))

	update_blindness()

	return ..()

/datum/status_effect/grouped/blindness/proc/update_blindness()
	if(!CAN_BE_BLIND(owner)) // future proofing
		qdel(src)
		return

	if(HAS_TRAIT(owner, TRAIT_SIGHT_BYPASS))
		make_unblind()
		return
	make_blind()

/datum/status_effect/grouped/blindness/proc/make_blind()
	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/blind)
	// You are blind - at most, able to make out shapes near you
	owner.add_client_colour(/datum/client_colour/monochrome/blind)

/datum/status_effect/grouped/blindness/proc/make_unblind()
	owner.clear_fullscreen(id)
	owner.remove_client_colour(/datum/client_colour/monochrome/blind)

/datum/status_effect/grouped/blindness/on_remove()
	make_unblind()
	UnregisterSignal(owner, update_signals)
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
