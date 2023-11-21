/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Sugar"
	cures = list(/datum/reagent/consumable/sugar)
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated subject will regurgitate bees."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD //bees nesting in corpses


/datum/disease/beesease/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) //also changes say, see say.dm
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_notice("You taste honey in your mouth."))
		if(3)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_notice("Your stomach rumbles."))
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your stomach stings painfully."))
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] buzzes."), \
												span_userdanger("Your stomach buzzes violently!"))
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel something moving in your throat."))
			if(SPT_PROB(0.5, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up a swarm of bees!"), \
													span_userdanger("You cough up a swarm of bees!"))
				new /mob/living/basic/bee(affected_mob.loc)
