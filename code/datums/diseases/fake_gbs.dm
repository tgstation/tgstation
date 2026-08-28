/datum/disease/fake_gbs
	name = "GBS"
	desc = "An extremely rare and dangerous disease that has been researched little due to its potentially apocalyptic nature."
	max_stages = 5
	spread_text = "Skin contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = /datum/reagent/medicine/synaptizine::name + " & " + /datum/reagent/sulfur::name
	cures = list(/datum/reagent/medicine/synaptizine,/datum/reagent/sulfur)
	agent = "Gravitokinetic Bipotential SADS-"
	viable_mobtypes = list(/mob/living/carbon/human)
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = HIDDEN_BOOK

/datum/disease/fake_gbs/stage_act(seconds_per_tick)
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
