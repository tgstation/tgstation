/datum/disease/cold
	name = "The Cold"
	max_stages = 3
	spread = "Airborne"
	cure = "Rest & Spaceacillin"
	cure_id = "spaceacillin"
	agent = "XY-rhinovirus"
	affected_species = list("Human", "Monkey")
	permeability_mod = 0.5
	desc = "If left untreated the subject will contract the flu."
	severity = "Minor"

/datum/disease/cold/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.sleeping && prob(40))
				affected_mob << "\blue You feel better."
				affected_mob.virus.cure()
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.virus.cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(3)
			if(affected_mob.sleeping && prob(25))
				affected_mob << "\blue You feel better."
				affected_mob.virus.cure()
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.virus.cure()
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
			if(prob(1) && prob(50))
				var/datum/disease/Flu = new /datum/disease/flu
				affected_mob.contract_disease(Flu,1)
				del(Flu)
