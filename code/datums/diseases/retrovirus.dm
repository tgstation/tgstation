/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread = "Contact"
	spread_type = CONTACT_GENERAL
	cure = "Rest or an injection of ryetalyn"
	cure_chance = 6
	agent = ""
	affected_species = list("Human")
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	severity = "Severe"
	permeability_mod = 0.4
	stage_prob = 2
	var/SE
	var/UI
	var/restcure = 0
	New()
		..()
		agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
		if(prob(40))
			cure_id = list("ryetalyn")
			cure_list = list("ryetalyn")
		else
			restcure = 1




/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(30))  //removed until sleeping is fixed
					affected_mob << "\blue You feel better."
					cure()
					return
*/
				if(affected_mob.lying && prob(30))  //changed FROM prob(20) until sleeping is fixed
					affected_mob << "<span class='notice'>You feel better.</span>"
					cure()
					return
			if (prob(8))
				affected_mob << "<span class='danger'>Your head hurts.</span>"
			if (prob(9))
				affected_mob << "You feel a tingling sensation in your chest."
			if (prob(9))
				affected_mob << "<span class='danger'>You feel angry.</span>"
		if(2)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(20))  //removed until sleeping is fixed
					affected_mob << "\blue You feel better."
					cure()
					return
*/
				if(affected_mob.lying && prob(20))  //changed FROM prob(10) until sleeping is fixed
					affected_mob << "<span class='notice'>You feel better.</span>"
					cure()
					return
			if (prob(8))
				affected_mob << "<span class='danger'>Your skin feels loose.</span>"
			if (prob(10))
				affected_mob << "You feel very strange."
			if (prob(4))
				affected_mob << "<span class='danger'>You feel a stabbing pain in your head!</span>"
				affected_mob.Paralyse(2)
			if (prob(4))
				affected_mob << "<span class='danger'>Your stomach churns.</span>"
		if(3)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(20))  //removed until sleeping is fixed
					affected_mob << "\blue You feel better."
					cure()
					return
*/
				if(affected_mob.lying && prob(20))  //changed FROM prob(10) until sleeping is fixed
					affected_mob << "<span class='notice'>You feel better.</span>"
					cure()
					return
			if (prob(10))
				affected_mob << "<span class='danger'>Your entire body vibrates.</span>"

			if (prob(35))
				if(prob(50))	scramble_dna(affected_mob, 1, 0, rand(15,45))
				else			scramble_dna(affected_mob, 0, 1, rand(15,45))

		if(4)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(10))  //removed until sleeping is fixed
					affected_mob << "\blue You feel better."
					cure()
					return
*/
				if(affected_mob.lying && prob(5))  //changed FROM prob(5) until sleeping is fixed
					affected_mob << "<span class='notice'>You feel better.</span>"
					cure()
					return
			if (prob(60))
				if(prob(50))	scramble_dna(affected_mob, 1, 0, rand(50,75))
				else			scramble_dna(affected_mob, 0, 1, rand(50,75))