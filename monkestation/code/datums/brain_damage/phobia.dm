/datum/brain_trauma/mild/phobia
	/// Whether this phobia is "inactive" or not.
	var/suppressed = FALSE
	/// Whether this phobia is automatically suppressed by the presence of certain antags.
	var/static/list/suppressed_antags = list(
		"heresy" = list(
			"antags" = list(/datum/antagonist/heretic, /datum/antagonist/heretic_monster),
			"suppression_message" = "Due to your connection to the Mansus, you are able to overcome and ignore your mind's fear of it.",
			"unsuppression_message" = "You feel the fear of heresy return to your mind, as you lose your connection to the Mansus."
		),
		"supernatural" = list(
			"antags" = list(
				/datum/antagonist/bloodsucker,
				/datum/antagonist/clock_cultist,
				/datum/antagonist/cult,
				/datum/antagonist/heretic,
				/datum/antagonist/heretic_monster,
				/datum/antagonist/monsterhunter,
				/datum/antagonist/vassal,
				/datum/antagonist/wizard,
				/datum/antagonist/wizard_minion
			),
			"suppression_message" = "Due to your connection to the supernatural, you are able to overcome and ignore your mind's fear of it.",
			"unsuppression_message" = "You feel the fear of the supernatural return to your mind, as you lose your connection to it."
		),
		"blood" = list(
			"antags" = list(/datum/antagonist/cult, /datum/antagonist/bloodsucker, /datum/antagonist/vassal),
			"suppression_message" = "Due to your existence's reliance on blood, you are able to overcome and ignore your mind's fear of it.",
			"unsuppression_message" = "You feel the fear of blood return to your mind, as you lose your reliance on it."
		)
	)

/datum/brain_trauma/mild/phobia/proc/update_suppression()
	SIGNAL_HANDLER
	var/list/suppression_info = src.suppressed_antags[phobia_type]
	if(!suppression_info || QDELETED(owner?.mind))
		return

	var/previous_suppressed = suppressed
	suppressed = FALSE
	for(var/antag_type in suppression_info["antags"])
		if(owner.mind.has_antag_datum(antag_type))
			suppressed = TRUE
			break

	if(suppressed && !previous_suppressed)
		to_chat(owner, span_boldnotice("[suppression_info["suppression_message"]]"))
	else if(!suppressed && previous_suppressed)
		to_chat(owner, span_bolddanger("[suppression_info["unsuppression_message"]]"))

/datum/brain_trauma/mild/phobia/on_gain()
	. = ..()
	if(!QDELETED(owner?.mind))
		update_suppression()
		RegisterSignals(owner.mind, list(COMSIG_ANTAGONIST_GAINED, COMSIG_ANTAGONIST_REMOVED), PROC_REF(update_suppression))

/datum/brain_trauma/mild/phobia/on_lose(silent)
	. = ..()
	if(!QDELETED(owner?.mind))
		update_suppression()
		UnregisterSignal(owner.mind, list(COMSIG_ANTAGONIST_GAINED, COMSIG_ANTAGONIST_REMOVED))

/datum/brain_trauma/mild/phobia/on_life(seconds_per_tick, times_fired)
	if(!suppressed)
		return ..()

/datum/brain_trauma/mild/phobia/is_scary_item(obj/checked)
	if(suppressed)
		return FALSE
	return ..()

/datum/brain_trauma/mild/phobia/handle_hearing(datum/source, list/hearing_args)
	if(!suppressed)
		return ..()

/datum/brain_trauma/mild/phobia/handle_speech(datum/source, list/speech_args)
	if(!suppressed)
		return ..()

/datum/brain_trauma/mild/phobia/freak_out(atom/reason, trigger_word)
	if(!suppressed)
		return ..()
