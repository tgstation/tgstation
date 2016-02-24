/*
//////////////////////////////////////

Sensory-Restoration

	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates Sensory restorational chemicals.

//////////////////////////////////////
*/

/datum/symptom/sensres

	name = "Sensory Restoration"
	stealth = -3
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 10
	severity = 0

/datum/symptom/sensres/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				if (M.reagents.get_reagent_amount("inacusiate") < 10)
					M.reagents.add_reagent("inacusiate", 10)
			if(2)
				if(M.reagents.get_reagent_amount("imidazoline") < 10)
					M.reagents.add_reagent("imidazoline", 10)
			if(3)
				if(M.reagents.get_reagent_amount("synaptizine") < 15)
					M.reagents.add_reagent("synaptizine", 15)
			if(4, 5)
				if (M.reagents.get_reagent_amount("alkysine") < 15)
					M.reagents.add_reagent("alkysine", 15)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("Your eyes feel great.", "Your ears feel great.", "Your head feel great.")]</span>"
	return
