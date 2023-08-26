/datum/disease/decloning
	form = "Virus"
	name = "Cellular Degeneration"
	max_stages = 5
	stage_prob = 0.5
	cure_text = "Rezadone, Mutadone for prolonging, or death."
	agent = "Severe Genetic Damage"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = @"If left untreated the subject will [REDACTED]!"
	severity = "Dangerous!"
	cures = list(/datum/reagent/medicine/rezadone)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Organic meltdown"
	process_dead = TRUE

/datum/disease/decloning/cure()
	affected_mob.remove_status_effect(/datum/status_effect/decloning)
	return ..()

/datum/disease/decloning/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(affected_mob.stat == DEAD)
		cure()
		return FALSE

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("yawn")
		if(3)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(1.5, seconds_per_tick))
				affected_mob.apply_status_effect(/datum/status_effect/decloning)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your skin feels strange."))
		if(4)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.apply_status_effect(/datum/status_effect/decloning)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
			if(SPT_PROB(7.5, seconds_per_tick))
				affected_mob.adjust_stutter(6 SECONDS)
		if(5)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your skin starts degrading!"))
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.apply_status_effect(/datum/status_effect/decloning)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
