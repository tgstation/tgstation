/// The amount of mutadone we can process for strike recovery at once.
#define MUTADONE_HEAL 1

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
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Organic meltdown"
	process_dead = TRUE
	/// How many strikes our virus holder has left before they are dusted.
	var/strikes_left = 100

/datum/disease/decloning/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(affected_mob.reagents?.has_reagent(/datum/reagent/medicine/mutadone, MUTADONE_HEAL * seconds_per_tick))
		strikes_left = min(strikes_left + MUTADONE_HEAL * seconds_per_tick, 100)
		affected_mob.reagents.remove_reagent(/datum/reagent/medicine/mutadone, MUTADONE_HEAL * seconds_per_tick)

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
				strikes_left -= 5
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your skin feels strange."))

		if(4)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("itch")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
				strikes_left = max(strikes_left - 2, 0)
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
				strikes_left = max(strikes_left - 5, 0)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
			if(strikes_left == 0)
				affected_mob.visible_message(span_danger("[affected_mob] skin turns to dust!"), span_boldwarning("Your skin turns to dust!"))
				affected_mob.dust()
				return FALSE

#undef MUTADONE_HEAL
