//Xenomicrobes

/datum/disease/xeno_transformation
	name = "Xenomorph Transformation"
	max_stages = 5
	spread = "Syringe"
	spread_type = SPECIAL
	cure = "Spaceacillin & Glycerol"
	cure_id = list("spaceacillin", "glycerol")
	cure_chance = 5
	agent = "Rip-LEY Alien Microbes"
	affected_species = list("Human")
	var/gibbed = 0

/datum/disease/xeno_transformation/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				affected_mob << "Your throat feels scratchy."
				affected_mob.take_organ_damage(1)
			if (prob(9))
				affected_mob << "\red Kill..."
			if (prob(9))
				affected_mob << "\red Kill..."
		if(3)
			if (prob(8))
				affected_mob << "\red Your throat feels very scratchy."
				affected_mob.take_organ_damage(1)
			/*
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			*/
			if (prob(10))
				affected_mob << "Your skin feels tight."
				affected_mob.take_organ_damage(5)
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.Paralyse(2)
			if (prob(4))
				affected_mob << "\red You can feel something move...inside."
		if(4)
			if (prob(10))
				affected_mob << pick("\red Your skin feels very tight.", "\red Your blood boils!")
				affected_mob.take_organ_damage(8)
			if (prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))
			if (prob(8))
				affected_mob << "\red You can feel... something...inside you."
		if(5)
			affected_mob <<"\red Your skin feels impossibly calloused..."
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(40))
				if(gibbed != 0) return 0
				var/turf/T = find_loc(affected_mob)
				gibs(T)
				src.cure(0)
				gibbed = 1
				affected_mob:Alienize()

