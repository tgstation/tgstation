//Xenomicrobes

/datum/disease/xeno_transformation
	name = "Xenomorph Transformation"
	max_stages = 5
	spread = "Syringe"
	cure = "None"
	affected_species = list("Human")

/datum/disease/xeno_transformation/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				affected_mob << "Your throat feels scratchy."
				affected_mob.bruteloss += 1
				affected_mob.updatehealth()
			if (prob(9))
				affected_mob << "\red Kill..."
			if (prob(9))
				affected_mob << "\red Kill..."
		if(3)
			if (prob(8))
				affected_mob << "\red Your throat feels very scratchy."
				affected_mob.bruteloss += 1
				affected_mob.updatehealth()
			/*
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			*/
			if (prob(10))
				affected_mob << "Your skin feels tight."
				affected_mob.bruteloss += 5
				affected_mob.updatehealth()
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.paralysis += 2
			if (prob(4))
				affected_mob << "\red You can feel something move...inside."
		if(4)
			if (prob(10))
				affected_mob << pick("\red Your skin feels very tight.", "\red Your blood boils!")
				affected_mob.bruteloss += 8
				affected_mob.updatehealth()
			if (prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))
			if (prob(8))
				affected_mob << "\red You can feel... something...inside you."
		if(5)
			affected_mob <<"\red Your skin feels impossibly calloused..."
			affected_mob.toxloss += 10
			affected_mob.updatehealth()
			if(prob(40))
				var/turf/T = find_loc(affected_mob)
				gibs(T)
				affected_mob:Alienize()
