/datum/disease/flu
	name = "The Flu"
	max_stages = 3
	spread = "Airborne"
	cure = "Rest"

/datum/disease/flu/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.sleeping && prob(20))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()

		if(3)
			if(affected_mob.sleeping && prob(15))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.bruteloss += 1
					affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
