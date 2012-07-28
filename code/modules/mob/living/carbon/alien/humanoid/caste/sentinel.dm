/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin)
	add_to_mob_list(src)

/mob/living/carbon/alien/humanoid/sentinel

	updatehealth()
		if(nodamage)
			health = 125
			stat = CONSCIOUS
		else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			health = 125 - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()


	handle_regular_hud_updates()

		..() //-Yvarov

		if (healths)
			if (stat != 2)
				switch(health)
					if(125 to INFINITY)
						healths.icon_state = "health0"
					if(100 to 125)
						healths.icon_state = "health1"
					if(75 to 100)
						healths.icon_state = "health2"
					if(25 to 75)
						healths.icon_state = "health3"
					if(0 to 25)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"

	handle_environment()

		//If there are alien weeds on the ground then heal if needed or give some toxins
		if(locate(/obj/effect/alien/weeds) in loc)
			if(health >= 125)
				adjustToxLoss(10)
			else
				adjustBruteLoss(-10)
				adjustFireLoss(-10)
