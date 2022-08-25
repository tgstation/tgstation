/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1
	category = EVENT_CATEGORY_HEALTH
	description = "Multiple crewmembers start to hallucinate the same thing."

/datum/round_event/mass_hallucination
	fakeable = FALSE

/datum/round_event/mass_hallucination/start()
	var/category_to_pick_from = rand(1, 10)
	var/picked_hallucination
	var/list/extra_args = list()
	switch(category_to_pick_from)
		if(1)
			// Send the same sound to everyone
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/normal)

		if(2)
			// Send the same sound to everyone, but weird
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/weird)

		if(3)
			// Send the same message to everyone
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/station_message)

		if(4)
			// Send the same delusion to everyone, but...
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
			// The delusion will affect everyone BUT the hallucinator.
			extra_args = list(
				/* duration = */30 SECONDS,
				/* skip_nearby = */FALSE,
				/* affects_us = */FALSE,
				/* affects_others = */TRUE,
				/* play_wabbajack = */FALSE,
			)

		if(5)
			// Send the same delusion to everyone, but...
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
			// The delusion will affect only the hallucinator.
			extra_args = list(
				/* duration = */45 SECONDS,
				/* skip_nearby = */FALSE,
				/* affects_us = */TRUE,
				/* affects_others = */FALSE,
				/* play_wabbajack = */TRUE,
			)

		if(6 to 10)
			// Send the same generic hallucination type to everyone
			var/static/list/generic_hallucinations = list(
				/datum/hallucination/bolts,
				/datum/hallucination/chat,
				/datum/hallucination/death,
				/datum/hallucination/fake_flood,
				/datum/hallucination/fire,
				/datum/hallucination/message,
				/datum/hallucination/oh_yeah,
				/datum/hallucination/xeno_attack,
			)

			picked_hallucination = pick(generic_hallucinations)

	if(!picked_hallucination)
		CRASH("[type] couldn't find a hallucination to play. (Rolled: [category_to_pick_from])")

	// We'll only hallucinate for carbons now, even though livings can hallucinate just fine in most cases.
	for(var/mob/living/carbon/hallucinating as anything in GLOB.carbon_list)
		// If they're on centcom, skip them entirely.
		if(is_centcom_level(hallucinating.z))
			continue
		// We can skip dead carbons as well
		if(hallucinating.stat == DEAD)
			continue
		// Hallucinations can have side effects on mobs, like being stunned,
		// so we'll play the hallucination to clientless mobs as well.
		// Unless the mob is off the station z-level. It's unlikely anyone will notice.
		if(!is_station_level(hallucinating.z) && !hallucinating.client)
			continue

		hallucinating.cause_hallucination(arglist(list(picked_hallucination, "mass hallucination") + extra_args))
