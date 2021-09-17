/datum/disease/decloning
	form = "Virus"
	name = "Cellular Degeneration"
	max_stages = 5
	stage_prob = 0.5
	cure_text = "Rezadone or death."
	agent = "Severe Genetic Damage"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = @"If left untreated the subject will [REDACTED]!"
	severity = "Dangerous!"
	cures = list(/datum/reagent/medicine/rezadone)
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	process_dead = TRUE

/datum/disease/decloning/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	if(affected_mob.stat == DEAD)
		cure()
		return FALSE

	switch(stage)
		if(2)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("itch")
			if(DT_PROB(1, delta_time))
				affected_mob.emote("yawn")
		if(3)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("itch")
			if(DT_PROB(1, delta_time))
				affected_mob.emote("drool")
			if(DT_PROB(1.5, delta_time))
				affected_mob.adjustCloneLoss(1, FALSE)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("Your skin feels strange."))

		if(4)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("itch")
			if(DT_PROB(1, delta_time))
				affected_mob.emote("drool")
			if(DT_PROB(2.5, delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
				affected_mob.adjustCloneLoss(2, FALSE)
			if(DT_PROB(7.5, delta_time))
				affected_mob.stuttering += 3
		if(5)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("itch")
			if(DT_PROB(1, delta_time))
				affected_mob.emote("drool")
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_danger("Your skin starts degrading!"))
			if(DT_PROB(5, delta_time))
				affected_mob.adjustCloneLoss(5, FALSE)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
			if(affected_mob.cloneloss >= 100)
				affected_mob.visible_message(span_danger("[affected_mob] skin turns to dust!"), span_boldwarning("Your skin turns to dust!"))
				affected_mob.dust()
				return FALSE
