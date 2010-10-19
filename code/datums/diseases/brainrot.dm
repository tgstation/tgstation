/datum/disease/brainrot
	name = "Brainrot"
	max_stages = 4
	spread = "Airborne"
	cure = "Spaceacillin & Alkysine"
	cure_id = list("alkysine","spaceacillin")
	agent = "Cryptococcus Cosmosis"
	affected_species = list("Human")
	curable = 0
	cure_chance = 10

/datum/disease/brainrot/stage_act() //Removed toxloss because damaging diseases are pretty horrible. Last round it killed the entire station because the cure didn't work -- Urist
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("blink")
			if(prob(2))
				affected_mob.emote("yawn")
			if(prob(2))
				affected_mob << "\red Your don't feel like yourself."
			if(prob(5))
				affected_mob.brainloss +=1
				affected_mob.updatehealth()
		if(3)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(10))
				if(affected_mob.brainloss<=98) //shouldn't retard you to death now
					affected_mob.brainloss += 2
				affected_mob.updatehealth()
				if(prob(2))
					affected_mob << "\red Your try to remember something important...but can't."
/*			if(prob(10))
				affected_mob.toxloss +=3
				affected_mob.updatehealth()
				if(prob(2))
					affected_mob << "\red Your head hurts." */
		if(4)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
/*			if(prob(15))
				affected_mob.toxloss +=4
				affected_mob.updatehealth()
				if(prob(2))
					affected_mob << "\red Your head hurts." */
			if(prob(15))
				affected_mob.brainloss +=3
				affected_mob.updatehealth()
				if(prob(2))
					affected_mob << "\red Strange buzzing fills your head, removing all thoughts."
			if(prob(3))
				affected_mob << "\red You lose consciousness..."
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message("[affected_mob] suddenly collapses", 1)
				affected_mob.paralysis = rand(5,10)
				if(prob(1))
					affected_mob.emote("snore")
			if(prob(15))
				affected_mob.stuttering += 3
	return