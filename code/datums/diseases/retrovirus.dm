/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread_text = "Contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Rest or an injection of mutadone"
	cure_chance = 3
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	severity = DISEASE_SEVERITY_HARMFUL
	spreading_modifier = 0.4
	stage_prob = 1
	var/restcure = 0
	bypasses_immunity = TRUE

/datum/disease/dna_retrovirus/New()
	..()
	agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	if(prob(40))
		cures = list(/datum/reagent/medicine/mutadone)
	else
		restcure = 1

/datum/disease/dna_retrovirus/Copy()
	var/datum/disease/dna_retrovirus/D = ..()
	D.restcure = restcure
	return D

/datum/disease/dna_retrovirus/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your head hurts."))
			if(SPT_PROB(4.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel a tingling sensation in your chest."))
			if(SPT_PROB(4.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel angry."))
			if(restcure && affected_mob.body_position == LYING_DOWN && SPT_PROB(16, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel better."))
				cure()
				return FALSE
		if(2)
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your skin feels loose."))
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel very strange."))
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head!"))
				affected_mob.Unconscious(40)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your stomach churns."))
			if(restcure && affected_mob.body_position == LYING_DOWN && SPT_PROB(10, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel better."))
				cure()
				return FALSE
		if(3)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your entire body vibrates."))
			if(SPT_PROB(19, seconds_per_tick))
				switch(rand(1,3))
					if(1)
						scramble_dna(affected_mob, 1, 0, 0, rand(15,45))
					if(2)
						scramble_dna(affected_mob, 0, 1, 0, rand(15,45))
					if(3)
						scramble_dna(affected_mob, 0, 0, 1, rand(15,45))
			if(restcure && affected_mob.body_position == LYING_DOWN && SPT_PROB(10, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel better."))
				cure()
				return FALSE
		if(4)
			if(SPT_PROB(37, seconds_per_tick))
				switch(rand(1,3))
					if(1)
						scramble_dna(affected_mob, 1, 0, 0, rand(50,75))
					if(2)
						scramble_dna(affected_mob, 0, 1, 0, rand(50,75))
					if(3)
						scramble_dna(affected_mob, 0, 0, 1, rand(50,75))
			if(restcure && affected_mob.body_position == LYING_DOWN && SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_notice("You feel better."))
				cure()
				return FALSE
