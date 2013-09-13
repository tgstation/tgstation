//Nanomachines!

/datum/disease/robotic_transformation
	name = "Robotic Transformation"
	max_stages = 5
	spread = "Syringe"
	spread_type = SPECIAL
	cure = "An injection of copper."
	cure_id = list("copper")
	cure_chance = 5
	agent = "R2D2 Nanomachines"
	affected_species = list("Human")
	desc = "This disease, actually acute nanomachine infection, converts the victim into a cyborg."
	severity = "Major"
	var/gibbed = 0

/datum/disease/robotic_transformation/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				affected_mob << "Your joints feel stiff."
				affected_mob.take_organ_damage(1)
			if (prob(9))
				affected_mob << "\red Beep...boop.."
			if (prob(9))
				affected_mob << "\red Bop...beeep..."
		if(3)
			if (prob(8))
				affected_mob << "\red Your joints feel very stiff."
				affected_mob.take_organ_damage(1)
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (prob(10))
				affected_mob << "Your skin feels loose."
				affected_mob.take_organ_damage(5)
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.Paralyse(2)
			if (prob(4))
				affected_mob << "\red You can feel something move...inside."
		if(4)
			if (prob(10))
				affected_mob << "\red Your skin feels very loose."
				affected_mob.take_organ_damage(8)
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))
			if (prob(8))
				affected_mob << "\red You can feel... something...inside you."
		if(5)
			affected_mob <<"\red Your skin feels as if it's about to burst off..."
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(40)) //So everyone can feel like robot Seth Brundle
				if(src.gibbed != 0) return 0
				var/turf/T = find_loc(affected_mob)
				gibs(T)
				src.cure(0)
				gibbed = 1
				var/mob/living/carbon/human/H = affected_mob
				if(istype(H) && !jobban_isbanned(affected_mob, "Cyborg"))
					H.Robotize()
				else
					affected_mob.death(1)

