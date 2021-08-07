/datum/disease/cold9
	name = "The Cold"
	max_stages = 3
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Common Cold Anti-bodies & Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "ICE9-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated the subject will slow, as if partly frozen."
	severity = DISEASE_SEVERITY_HARMFUL


/datum/disease/cold9/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			affected_mob.adjust_bodytemperature(-5 * delta_time)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Your throat feels sore."))
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_danger("You feel stiff."))
			if(DT_PROB(0.05, delta_time))
				to_chat(affected_mob, span_notice("You feel better."))
				cure()
				return FALSE
		if(3)
			affected_mob.adjust_bodytemperature(-10 * delta_time)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Your throat feels sore."))
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_danger("You feel stiff."))
