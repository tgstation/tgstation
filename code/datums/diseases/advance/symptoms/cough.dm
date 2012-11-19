/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmittable.
	Low Level.

BONUS
	Will force the affected mob to drop items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 1
	level = 1

/datum/symptom/cough/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				M << "<span notice='notice'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>"
			else
				M.emote("cough")
				var/obj/item/I = M.get_active_hand()
				if(I && I.w_class < 3)
					M.drop_item()
	return