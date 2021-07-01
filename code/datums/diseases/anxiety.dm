/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Ethanol"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated subject will regurgitate butterflies."
	severity = DISEASE_SEVERITY_MINOR


/datum/disease/anxiety/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) //also changes say, see say.dm
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel anxious.</span>")
		if(3)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='notice'>Your stomach flutters.</span>")
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel panicky.</span>")
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You're overtaken with panic!</span>")
				affected_mob.add_confusion(rand(2,3))
		if(4)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel butterflies in your stomach.</span>")
			if(DT_PROB(2.5, delta_time))
				affected_mob.visible_message("<span class='danger'>[affected_mob] stumbles around in a panic.</span>", \
												"<span class='userdanger'>You have a panic attack!</span>")
				affected_mob.add_confusion(rand(6,8))
				affected_mob.jitteriness += (rand(6,8))
			if(DT_PROB(1, delta_time))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up butterflies!</span>", \
													"<span class='userdanger'>You cough up butterflies!</span>")
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
