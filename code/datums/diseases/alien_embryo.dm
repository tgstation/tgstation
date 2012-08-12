//affected_mob.contract_disease(new /datum/disease/alien_embryo)

//Our own special process so that dead hosts still chestburst
/datum/disease/alien_embryo/process()
	if(!holder) return
	if(holder == affected_mob)
		stage_act()

	if(affected_mob)
		if(affected_mob.stat == DEAD)
			if(prob(50))
				if(--longevity<=0)
					cure(0)
	else //the virus is in inanimate obj
		cure(0)
	return


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
				var/list/candidates = list() //List of candidate KEYS to assume control of the new larva ~Carn
				for(var/mob/dead/observer/G in player_list)
					if(G.client.be_alien)
						if(((G.client.inactivity/10)/60) <= 5)
							if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
								candidates += G.key

				var/mob/living/carbon/alien/larva/new_xeno = new(affected_mob.loc)
				if(candidates.len)
					new_xeno.key = pick(candidates)
				else
					new_xeno.key = affected_mob.key

				new_xeno << sound('hiss5.ogg',0,0,0,100)	//To get the player's attention
				affected_mob.gib()
				src.cure(0)
				gibbed = 1
				return

