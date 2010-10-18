/datum/disease/gbs
	name = "GBS"
	max_stages = 5
	spread = "Airborne"
	cure = "Epilepsy Pills"
	agent = "Gravitokinetic Bipotential SADS+"
	affected_species = list("Human")
	curable = 0

/datum/disease/gbs/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.toxloss += 5
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob.emote("sneeze")
		if(3)
			if(prob(5))
				affected_mob.emote("cough")
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(10))
				affected_mob << "\red You're starting to feel very weak..."
		if(4)
			if(prob(10))
				affected_mob.emote("cough")
			affected_mob.toxloss += 5
			affected_mob.updatehealth()
		if(5)
			affected_mob << "\red Your body feels as if it's trying to rip itself open..."
			if(prob(50))
				affected_mob.gib()
		else
			return