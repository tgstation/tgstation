/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread = "Contact"
	spread_type = CONTACT_GENERAL
	cure = "Rest"
	cure_chance = 6
	agent = ""
	affected_species = list("Human")
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	var/restcure = 1
	severity = "Severe"
	permeability_mod = 0.4
	stage_prob = 2
	var/SE
	var/UI

/datum/disease/dna_retrovirus/New()
	..()
	agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	if(prob(40))
		cure_id = list(RYETALYN)
		cure_list = list(RYETALYN)
		cure = "Ryetalyn"
		restcure = 0




/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(30))  //removed until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
*/
				if(affected_mob.lying && prob(30))  //changed FROM prob(20) until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (prob(8))
				to_chat(affected_mob, "<span class='warning'>Your head hurts.</span>")
			if (prob(9))
				to_chat(affected_mob, "You feel a tingling sensation in your chest.")
			if (prob(9))
				to_chat(affected_mob, "<span class='warning'>You feel angry.</span>")
		if(2)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(20))  //removed until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
*/
				if(affected_mob.lying && prob(20))  //changed FROM prob(10) until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (prob(8))
				to_chat(affected_mob, "<span class='warning'>Your skin feels loose.</span>")
			if (prob(10))
				to_chat(affected_mob, "You feel very strange.")
			if (prob(4))
				to_chat(affected_mob, "<span class='warning'>You feel a stabbing pain in your head!</span>")
				affected_mob.Paralyse(2)
			if (prob(4))
				to_chat(affected_mob, "<span class='warning'>Your stomach churns.</span>")
		if(3)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(20))  //removed until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
*/
				if(affected_mob.lying && prob(20))  //changed FROM prob(10) until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (prob(10))
				to_chat(affected_mob, "<span class='warning'>Your entire body vibrates.</span>")

			if (prob(35))
				if(prob(50))
					scramble(1, affected_mob, rand(15,45))
				else
					scramble(0, affected_mob, rand(15,45))

		if(4)
			if(restcure)
/*
				if(affected_mob.sleeping && prob(10))  //removed until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
*/
				if(affected_mob.lying && prob(5))  //changed FROM prob(5) until sleeping is fixed
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if (prob(60))
				if(prob(50))
					scramble(1, affected_mob, rand(50,75))
				else
					scramble(0, affected_mob, rand(50,75))