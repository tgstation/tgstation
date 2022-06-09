/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1

/datum/round_event/mass_hallucination
	fakeable = FALSE

/datum/round_event/mass_hallucination/start()
	var/category_to_pick_from = rand(1, 10)
	var/picked_hallucination
	var/list/extra_args = list()
	switch(category_to_pick_from)
		if(1)
			// Send the same sound to everyone
			picked_hallucination = get_random_valid_subtype(/datum/hallucination/fake_sound/normal)

		if(2)
			// Send the same sound to everyone, but weird
			picked_hallucination = get_random_valid_subtype(/datum/hallucination/fake_sound/weird)

		if(3)
			picked_hallucination = get_random_valid_subtype(/datum/hallucination/station_message)

		if(4)
			// Send the same delusion to everyone.
			picked_hallucination = get_random_valid_subtype(/datum/hallucination/delusion/preset)
			// Delusion will affect everyone BUT the hallucinator.
			extra_args = list(
				/* duration = */30 SECONDS,
				/* skip_nearby = */FALSE,
				/* affects_us = */FALSE,
				/* affects_others = */TRUE,
				/* play_wabbajack = */FALSE,
			)

		if(5)
			// Send the same delusion to everyone
			picked_hallucination = get_random_valid_subtype(/datum/hallucination/delusion/preset)
			// Delusion will affect only the hallucinator.
			extra_args = list(
				/* duration = */45 SECONDS,
				/* skip_nearby = */FALSE,
				/* affects_us = */TRUE,
				/* affects_others = */FALSE,
				/* play_wabbajack = */TRUE,
			)

		if(6 to 10)
			// Send the same generic hallucination type to everyone
			var/static/list/possible_hallucinations = list(
				/datum/hallucination/bolts,
				/datum/hallucination/chat,
				/datum/hallucination/death,
				/datum/hallucination/fake_flood,
				/datum/hallucination/fire,
				/datum/hallucination/message,
				/datum/hallucination/oh_yeah,
				/datum/hallucination/xeno_attack,
			)

			picked_hallucination = pick(possible_hallucinations)

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

/// Gets a random subtype of the passed hallucination type that has a random_hallucination_weight > 0.
/datum/round_event/mass_hallucination/proc/get_random_valid_subtype(passed_type)
	if(!ispath(passed_type, /datum/hallucination))
		CRASH("[type] - get_random_valid_subtype passed not a hallucination subtype.")

	for(var/datum/hallucination/hallucination_type as anything in shuffle(subtypesof(passed_type)))
		if(initial(hallucination_type.random_hallucination_weight) <= 0)
			continue

		return hallucination_type

	return null
