/datum/disease/brainrot
	name = "Brainrot"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Mannitol"
	cures = list(/datum/reagent/medicine/mannitol)
	agent = "Cryptococcus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 7.5 //higher chance to cure, since two reagents are required
	desc = "This disease destroys the brain cells, causing brain fever, brain necrosis and general intoxication."
	required_organ = ORGAN_SLOT_BRAIN
	severity = DISEASE_SEVERITY_HARMFUL
	bypasses_immunity = TRUE

/datum/disease/brainrot/stage_act(seconds_per_tick, times_fired) //Removed toxloss because damaging diseases are pretty horrible. Last round it killed the entire station because the cure didn't work -- Urist -ACTUALLY Removed rather than commented out, I don't see it returning - RR
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("blink")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("yawn")
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("You don't feel like yourself."))
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
		if(3)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("stare")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
				if(prob(2))
					to_chat(affected_mob, span_danger("Your try to remember something important...but can't."))

		if(4)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("stare")
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("drool")
			if(SPT_PROB(7.5, seconds_per_tick))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 170)
				if(prob(2))
					to_chat(affected_mob, span_danger("Strange buzzing fills your head, removing all thoughts."))
			if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You lose consciousness..."))
				affected_mob.visible_message(span_warning("[affected_mob] suddenly collapses!"), \
											span_userdanger("You suddenly collapse!"))
				affected_mob.Unconscious(rand(100, 200))
				if(prob(1))
					affected_mob.emote("snore")
			if(SPT_PROB(7.5, seconds_per_tick))
				affected_mob.adjust_stutter(6 SECONDS)
