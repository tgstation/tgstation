/datum/disease/flu
	name = "The Flu"
	max_stages = 3
	spread = "Airborne"
	cure = "Spaceacillin"
	cure_id = SPACEACILLIN
	cure_chance = 10
	agent = "H13N1 flu virion"
	affected_species = list("Human", "Monkey")
	permeability_mod = 0.75
	desc = "If left untreated the subject will feel quite unwell."
	severity = "Medium"

/datum/disease/flu/stage_act()
	..()
	switch(stage)
		if(2)
/*
			if(affected_mob.sleeping && prob(20))  //removed until sleeping is fixed --Blaank
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
*/
			if(affected_mob.lying && prob(20))  //added until sleeping is fixed --Blaank
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.audible_cough()
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()

		if(3)
/*
			if(affected_mob.sleeping && prob(15))  //removed until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
*/
			if(affected_mob.lying && prob(15))  //added until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.audible_cough()
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
	return
