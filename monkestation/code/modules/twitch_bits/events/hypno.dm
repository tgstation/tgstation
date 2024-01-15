/datum/twitch_event/hypno
	event_name = "Hypnotize Random Player"
	event_duration = 5 MINUTES
	event_flags = TWITCH_AFFECTS_RANDOM | CLEAR_TARGETS_ON_END_EVENT
	id_tag = T_EVENT_HYPNO_RANDOM
	announce = FALSE //MMMM, ME SEE VALID

/datum/twitch_event/hypno/apply_effects()
	for(var/mob/living/carbon/target in targets)
		if(target.has_trauma_type(/datum/brain_trauma/hypnosis)) //dont hypno if they already have it
			targets -= target
			continue
		to_chat(target, span_hypnophrase(span_big("You feel a trance coming over you!")))
		target.apply_status_effect(/datum/status_effect/trance, 20 SECONDS, FALSE)

/datum/twitch_event/hypno/end_event()
	for(var/mob/living/carbon/target in targets)
		target.cure_trauma_type(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY)
	return ..()

/datum/twitch_event/hypno/ook
	event_name = "Hypnotize Ook"
	event_flags = TWITCH_AFFECTS_STREAMER | CLEAR_TARGETS_ON_END_EVENT
	id_tag = T_EVENT_HYPNO_OOK
	token_cost = 1000

/datum/twitch_event/hypno/everyone
	event_name = "Hypnotize Everyone"
	event_flags = TWITCH_AFFECTS_ALL | CLEAR_TARGETS_ON_END_EVENT
	id_tag = T_EVENT_HYPNO_EVERYONE
