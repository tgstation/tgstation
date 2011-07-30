/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread = "Contact"
	spread_type = CONTACT_GENERAL
	cure = "Mutagen & Spaceacillin"
	cure_id = list("mutagen", "spaceacillin")
	cure_chance = 6
	agent = ""
	affected_species = list("Human")
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	severity = "Severe"
	permeability_mod = 0.4
	stage_prob = 2
	var/SE
	var/UI
	New()
		..()
		agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if (prob(8))
				affected_mob << "\red Your head hurts."
			if (prob(9))
				affected_mob << "You feel a tingling sensation in your chest."
			if (prob(9))
				affected_mob << "\red You feel angry."
		if(2)
			if (prob(8))
				affected_mob << "\red Your skin feels loose."
			if (prob(10))
				affected_mob << "You feel very strange."
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head!"
				affected_mob.paralysis += 2
			if (prob(4))
				affected_mob << "\red Your stomach churns."
		if(3)
			if (prob(10))
				affected_mob << "\red Your entire body vibrates."

			if (prob(35))
				if(prob(50))
					scramble(1, affected_mob, rand(15,45))
				else
					scramble(0, affected_mob, rand(15,45))

		if(4)
			if (prob(60))
				if(prob(50))
					scramble(1, affected_mob, rand(50,75))
				else
					scramble(0, affected_mob, rand(50,75))