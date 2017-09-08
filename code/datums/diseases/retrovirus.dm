/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread_text = "Contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Rest or an injection of mutadone"
	cure_chance = 6
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	severity = DANGEROUS
	permeability_mod = 0.4
	stage_prob = 2
	var/SE
	var/UI
	var/restcure = 0


/datum/disease/dna_retrovirus/New()
	..()
	agent = "Virus class [SSrng.pick_from_list("A","B","C","D","E","F")][SSrng.pick_from_list("A","B","C","D","E","F")]-[SSrng.random(50,300)]"
	if(SSrng.probability(40))
		cures = list("mutadone")
	else
		restcure = 1


/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if(restcure)
				if(affected_mob.lying && SSrng.probability(30))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (SSrng.probability(8))
				to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
			if (SSrng.probability(9))
				to_chat(affected_mob, "You feel a tingling sensation in your chest.")
			if (SSrng.probability(9))
				to_chat(affected_mob, "<span class='danger'>You feel angry.</span>")
		if(2)
			if(restcure)
				if(affected_mob.lying && SSrng.probability(20))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (SSrng.probability(8))
				to_chat(affected_mob, "<span class='danger'>Your skin feels loose.</span>")
			if (SSrng.probability(10))
				to_chat(affected_mob, "You feel very strange.")
			if (SSrng.probability(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head!</span>")
				affected_mob.Unconscious(40)
			if (SSrng.probability(4))
				to_chat(affected_mob, "<span class='danger'>Your stomach churns.</span>")
		if(3)
			if(restcure)
				if(affected_mob.lying && SSrng.probability(20))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (SSrng.probability(10))
				to_chat(affected_mob, "<span class='danger'>Your entire body vibrates.</span>")

			if (SSrng.probability(35))
				if(SSrng.probability(50))
					scramble_dna(affected_mob, 1, 0, SSrng.random(15,45))
				else
					scramble_dna(affected_mob, 0, 1, SSrng.random(15,45))

		if(4)
			if(restcure)
				if(affected_mob.lying && SSrng.probability(5))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (SSrng.probability(60))
				if(SSrng.probability(50))
					scramble_dna(affected_mob, 1, 0, SSrng.random(50,75))
				else
					scramble_dna(affected_mob, 0, 1, SSrng.random(50,75))