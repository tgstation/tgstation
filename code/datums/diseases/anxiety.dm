/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Condition"
	max_stages = 4
	spread_text = "Skin contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = /datum/reagent/consumable/ethanol::name + " (Liquid Courage)"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A well documented condition leading to 'butterflies in the stomach' in a literal sense, which are often regurgitated."
	severity = DISEASE_SEVERITY_MINOR


/datum/disease/anxiety/stage_act(seconds_per_tick)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) //also changes say, see say.dm
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel anxious."))
		if(3)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_notice("Your stomach flutters."))
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel panicky."))
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("You're overtaken with panic!"))
				affected_mob.adjust_confusion(rand(2 SECONDS, 3 SECONDS))
		if(4)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel butterflies in your stomach."))
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] stumbles around in a panic."), \
												span_userdanger("You have a panic attack!"))
				affected_mob.adjust_confusion(rand(6 SECONDS, 8 SECONDS))
				affected_mob.adjust_jitter(rand(12 SECONDS, 16 SECONDS))
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up butterflies!"), \
													span_userdanger("You cough up butterflies!"))
				new /mob/living/basic/butterfly(affected_mob.loc)
				new /mob/living/basic/butterfly(affected_mob.loc)
