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


/datum/disease/beesease/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) //also changes say, see say.dm
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='notice'>You taste honey in your mouth.</span>")
		if(3)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='notice'>Your stomach rumbles.</span>")
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your stomach stings painfully.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(DT_PROB(5, delta_time))
				affected_mob.visible_message("<span class='danger'>[affected_mob] buzzes.</span>", \
												"<span class='userdanger'>Your stomach buzzes violently!</span>")
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel something moving in your throat.</span>")
			if(DT_PROB(0.5, delta_time))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a swarm of bees!</span>", \
													"<span class='userdanger'>You cough up a swarm of bees!</span>")
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
