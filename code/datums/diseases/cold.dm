/datum/disease/cold
	name = "The Cold"
	max_stages = 3
	spread = "Airborne"
	cure = "Rest"
	affected_species = list("Human")

/datum/disease/cold/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.sleeping && prob(40))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
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
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
			if(prob(1) && prob(50))
				affected_mob.contract_disease(new /datum/disease/flu)
