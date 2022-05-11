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
				to_chat(affected_mob, span_notice("You feel anxious."))
		if(3)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_notice("Your stomach flutters."))
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_notice("You feel panicky."))
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("You're overtaken with panic!"))
				affected_mob.adjust_timed_status_effect(rand(2 SECONDS, 3 SECONDS), /datum/status_effect/confusion)
		if(4)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, span_danger("You feel butterflies in your stomach."))
			if(DT_PROB(2.5, delta_time))
				affected_mob.visible_message(span_danger("[affected_mob] stumbles around in a panic."), \
												span_userdanger("You have a panic attack!"))
				affected_mob.adjust_timed_status_effect(rand(6 SECONDS, 8 SECONDS), /datum/status_effect/confusion)
				affected_mob.adjust_timed_status_effect(rand(12 SECONDS, 16 SECONDS), /datum/status_effect/jitter)
			if(DT_PROB(1, delta_time))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up butterflies!"), \
													span_userdanger("You cough up butterflies!"))
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
