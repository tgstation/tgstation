//affected_mob.contract_disease(new /datum/disease/alien_embryo)


/datum/disease/alien_embryo
	name = "Unidentified Foreign Body"
	max_stages = 5
	spread = "None"
	spread_type = SPECIAL
	cure = "Unknown"
	cure_id = list("lexorin","toxin","gargleblaster")
	cure_chance = 20
	affected_species = list("Human", "Monkey")
	permeability_mod = 3//likely to infect
	var/gibbed = 0

/datum/disease/alien_embryo/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(2))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			affected_mob << "\red You feel something tearing its way out of your stomach..."
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(40))
				if(gibbed != 0) return 0
				var/list/candidates = list() // Picks a random ghost in the world to shove in the larva -- TLE
				for(var/mob/dead/observer/G in world)
					if(G.client)
						if(G.client.be_alien)
							if(((G.client.inactivity/10)/60) <= 5)
								if(G.corpse)
									if(G.corpse.stat==2)
										candidates.Add(G)
								if(!G.corpse)
									candidates.Add(G)
				if(candidates.len)
					var/mob/dead/observer/G = pick(candidates)
					var/mob/living/carbon/alien/larva/new_xeno = new(affected_mob.loc)
					new_xeno.mind_initialize(G,"Larva")
					new_xeno.key = G.key
					del(G)
				else
					if(affected_mob.client)
						affected_mob.client.mob = new/mob/living/carbon/alien/larva(affected_mob.loc)
				affected_mob.gib()
				src.cure(0)
				gibbed = 1

			/*
				if(affected_mob.client)
					affected_mob.client.mob = new/mob/living/carbon/alien/larva(affected_mob.loc)
				else
					new/mob/living/carbon/alien/larva(affected_mob.loc)
				affected_mob:gib()
			*/
				return

