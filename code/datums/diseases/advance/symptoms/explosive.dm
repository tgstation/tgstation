/*
//////////////////////////////////////

Living Bomb

	Very visible.
	Lowers resistance considerably.
	Increases stage speed.
	Reduced transmittability
	Intense Level.

Bonus
	Turns the affected person into a living bomb.Ishmillah.

//////////////////////////////////////
*/

/datum/symptom/explosive

	name = "Dizziness"
	stealth = -2
	resistance = -2
	stage_speed = 3
	transmittable = -1
	level = 10
	severity = 2

/datum/symptom/explosive/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>[pick("Something snaps inside you.", "You hear a crunching sound coming from your lungs.")]</span>"
			if(3,4)
				M << "<span class='alert'>[pick("Everything feels hot around you!", "You smell sulphur and brimstone!")]</span>"
				T.atmos_spawn_air(SPAWN_HEAT | SPAWN_CO2, 200)
				M.reagents.add_reagent("smoke_powder", 20) //should make some clouds of smoke. Hopefully anyway.
			else
				M << A.affected_mob.say("ALLAHU ACKBAR!")
				explosion(M.loc,1,2,4,7)
				M.Dizzy(5)
	return