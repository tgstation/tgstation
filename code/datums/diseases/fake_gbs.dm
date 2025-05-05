/datum/disease/fake_gbs
	name = "GBS"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Synaptizine & Sulfur"
	cures = list(/datum/reagent/medicine/synaptizine,/datum/reagent/sulfur)
	agent = "Gravitokinetic Bipotential SADS-"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated death will occur."
	severity = DISEASE_SEVERITY_BIOHAZARD


/datum/disease/fake_gbs/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.emote("sneeze")
		if(3)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("cough")
			else if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("gasp")
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You're starting to feel very weak..."))
		if(4)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.emote("cough")

		if(5)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.emote("cough")
