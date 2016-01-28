/*
//////////////////////////////////////

Sensory-Restoration

	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal.

Bonus
	The body generates Sensory restorational chemicals.
	inacusiate for ears
	antihol for removal of alcohol
	synaptizine to purge sensory hallucigens
	mannitol to kickstart the mind

//////////////////////////////////////
*/

/datum/symptom/sensory_restoration

	name = "Sensory Restoration"
	stealth = -5
	resistance = -4
	stage_speed = -4
	transmittable = -5
	level = 6
	severity = 0

/datum/symptom/sensory_restoration/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				if (M.reagents.get_reagent_amount("inacusiate") < 10)
					M.reagents.add_reagent("inacusiate", 10)
			if(2)
				if(M.reagents.get_reagent_amount("antihol") < 10)
					M.reagents.add_reagent("antihol", 10)
			if(3)
				if(M.reagents.get_reagent_amount("synaptizine") < 15)
					M.reagents.add_reagent("synaptizine", 15)
			if(4, 5)
				if (M.reagents.get_reagent_amount("mannitol") < 15)
					M.reagents.add_reagent("mannitol", 15)
			if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You see all colours of the spectrum.", "Your hearing feels clearer and crisp.", "You feel focused.")]</span>"
	return