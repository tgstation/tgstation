/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Necrotizing Fasciitis"
	stealth = -3
	resistance = -4
	stage_speed = 0
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(2,3)
				M << "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>"
			if(4,5)
				M << "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>"
				Flesheat(M, A)
	return

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = ((sqrt(16-A.totalStealth()))*5)
	M.adjustBruteLoss(get_damage)
	return 1