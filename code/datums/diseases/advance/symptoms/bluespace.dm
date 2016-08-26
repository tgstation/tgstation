/*
//////////////////////////////////////

Bluespace Instability

	Noticeable.
	Lowers resistance.
	Decreases stage speed.
	Increases transmittablity slightly.
	Fatal Level.

Bonus
	Causes the mob to randomly teleport, as if he crushed a bluespace crystal.

//////////////////////////////////////
*/

/datum/symptom/bluespace

	name = "Bluespace Instability"
	stealth = -2
	resistance = -2
	stage_speed = -1
	transmittable = 1
	level = 7
	severity = 5

/datum/symptom/bluespace/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB/2))
		var/mob/living/M = A.affected_mob
		var/blink_range = 6  //A bluespace crystal is 8, for reference
		switch(A.stage)
			if(5)
				PoolOrNew(/obj/effect/particle_effect/sparks, M.loc)
				playsound(M.loc, "sparks", 50, 1)
				do_teleport(M, get_turf(M), blink_range, asoundin = 'sound/effects/phasein.ogg')
				M << "<span class='userdanger'>[pick("Your body folds into bluespace!", "You teleport!", "You're suddenly somewhere else!")]</span>"

			else
				M << "<span class='warning'>[pick("You feel unstable.", "You feel dizzy.")]</span>"

	return
