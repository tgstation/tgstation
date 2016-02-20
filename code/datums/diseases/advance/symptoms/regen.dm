/datum/symptom/regen

	name = "Cellular Regeneration"
	stealth = 1
	resistance = 3
	stage_speed = -2
	transmittable = -4
	level = 10

/datum/symptom/regen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				M.heal_organ_damage(2,2)
				M.adjustToxLoss(-2)
				M.adjustCloneLoss(-2)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel like a new you.", "Your skin feels funny.")]</span>"
	return
