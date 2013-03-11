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
/*
			if(affected_mob.sleeping && prob(40))  //removed until sleeping is fixed
				affected_mob << "\blue You feel better."
				cure()
				return
*/
			if(affected_mob.lying && prob(40))  //changed FROM prob(10) until sleeping is fixed
				affected_mob << "\blue You feel better."
				cure()
				return
			if(prob(1) && prob(5))
				affected_mob << "\blue You feel better."
				cure()
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
/*
			if(affected_mob.sleeping && prob(25))  //removed until sleeping is fixed
				affected_mob << "\blue You feel better."
				cure()
				return
*/
			if(affected_mob.lying && prob(25))  //changed FROM prob(5) until sleeping is fixed
				affected_mob << "\blue You feel better."
				cure()
				return
			if(prob(1) && prob(1))
				affected_mob << "\blue You feel better."
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
			if(prob(1) && prob(50))
				if(!affected_mob.resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu(0)
					affected_mob.contract_disease(Flu,1)
					cure()