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
	permeability_mod = 0.4
	stage_prob = 1
	var/restcure = 0

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

/datum/disease/dna_retrovirus/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(DT_PROB(4, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
			if(DT_PROB(4.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a tingling sensation in your chest.</span>")
			if(DT_PROB(4.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel angry.</span>")
			if(restcure && affected_mob.body_position == LYING_DOWN && DT_PROB(16, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return FALSE
		if(2)
			if(DT_PROB(4, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your skin feels loose.</span>")
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel very strange.</span>")
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head!</span>")
				affected_mob.Unconscious(40)
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your stomach churns.</span>")
			if(restcure && affected_mob.body_position == LYING_DOWN && DT_PROB(10, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return FALSE
		if(3)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your entire body vibrates.</span>")
			if(DT_PROB(19, delta_time))
				if(prob(50))
					scramble_dna(affected_mob, 1, 0, rand(15,45))
				else
					scramble_dna(affected_mob, 0, 1, rand(15,45))
			if(restcure && affected_mob.body_position == LYING_DOWN && DT_PROB(10, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return FALSE
		if(4)
			if(DT_PROB(37, delta_time))
				if(prob(50))
					scramble_dna(affected_mob, 1, 0, rand(50,75))
				else
					scramble_dna(affected_mob, 0, 1, rand(50,75))
			if(restcure && affected_mob.body_position == LYING_DOWN && DT_PROB(2.5, delta_time))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return FALSE
