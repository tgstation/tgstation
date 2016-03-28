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

/*
//////////////////////////////////////

Fournier's gangrenous necrosis (flesh eating disease with gangrene. Do not google.)

	Very noticable.
	Lowers resistance.
	No changes to stage speed.
	Decreases transmittablity.
	Fatal.

Bonus
	Deals brute damage over time.

Special traitor bonus
	Deals damage at earlier stages.
	Deals 4/5 Brute damage, and 1/5 Clone damage.

//////////////////////////////////////
*/

/datum/symptom/traitor_flesh_eating

	name = "Fournier's gangrenous necrosis" //don't google this
	stealth = -2
	resistance = -2
	stage_speed = 0
	transmittable = -2
	level = 9
	severity = 5

/datum/symptom/traitor_flesh_eating/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3,4)
				M << "<span class='warning'>[pick("You feel a violent pain tear into your nerves.", "Drops of blood appear suddenly on your rotting skin")]</span>"
				FournierGangrene_stage_3_4(M, A)
			if(5)
				M << "<span class='userdanger'>[pick("You violently tear and deform your body!", "Your flesh painfully loosens and sags!", "IT HURTS SO MUCH.!")]</span>"
				FournierGangrene(M, A)
	return

/datum/symptom/traitor_flesh_eating/proc/FournierGangrene_stage_3_4(mob/living/M, datum/disease/advance/A)
	var/get_damage = (sqrt(16-A.totalStealth()))
	M.adjustBruteLoss(get_damage*3)
	return 1

/datum/symptom/traitor_flesh_eating/proc/FournierGangrene(mob/living/M, datum/disease/advance/A)
	var/get_damage = (sqrt(16-A.totalStealth()))
	M.adjustBruteLoss(get_damage*4)
	M.adjustCloneLoss(get_damage)
	return 1