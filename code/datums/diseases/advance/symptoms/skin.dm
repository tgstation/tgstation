/*
//////////////////////////////////////
Polyvitiligo

	Noticeable.
	Increases resistance.
	Increases stage speed slightly.
	Increases transmission.
	Critical Level.

BONUS
	Makes the mob gain colorful reagent.

//////////////////////////////////////
*/

/datum/symptom/polyvitiligo
	name = "Polyvitiligo"
	desc = "The virus replaces the melanin in the skin with colorful reagent."
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 5
	severity = 1
	symptom_delay_min = 7
	symptom_delay_max = 14

/datum/symptom/polyvitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(5)
			M.reagents.add_reagent(/datum/reagent/colorful_reagent, 30)
		else
			if (prob(50)) // spam
				M.visible_message("<span class='warning'>[M] looks rather vibrant...</span>", "<span class='notice'>The colors, man, the colors...</span>")
