/datum/disease/adrenal_crisis
	form = "Condition"
	name = "Adrenal Crisis"
	max_stages = 2
	cure_text = "Trauma"
	cures = list(/datum/reagent/determination)
	cure_chance = 10
	agent = "Shitty Adrenal Glands"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	desc = "If left untreated the subject will suffer from lethargy, dizziness and periodic loss of conciousness."
	severity = DISEASE_SEVERITY_MEDIUM
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Organ failure"
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE

/datum/disease/adrenal_crisis/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_warning(pick("You feel lightheaded.", "You feel lethargic.")))
		if(2)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.Unconscious(40)

			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.adjust_slurring(14 SECONDS)

			if(SPT_PROB(7, seconds_per_tick))
				affected_mob.set_dizzy_if_lower(20 SECONDS)

			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_warning(pick("You feel pain shoot down your legs!", "You feel like you are going to pass out at any moment.", "You feel really dizzy.")))
