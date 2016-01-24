/*
//////////////////////////////////////
asthmosthia

	Very very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittability.
BONUS
	Spawns gases
//////////////////////////////////////
*/

/datum/symptom/asthmothia

	name = "Asthmothia"
	stealth = -5
	resistance = -5
	stage_speed = -5
	transmittable = -6
	level = 5
	severity = 5

/datum/symptom/asthmothia/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 3))
		var/turf/simulated/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(5)
				if(prob(16.66))
					A.affected_mob << "<span class='warning'>You huff out some Plasma!.</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 15)
				else
					A.affected_mob << "<span class='warning'>You cough up a plume of Nitrous Oxide!</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_N2O, 20)
			else
				A.affected_mob << "<span class='warning'>Your lungs hurt.</span>"
				T.atmos_spawn_air(SPAWN_20C | SPAWN_OXYGEN, 10)
				A.affected_mob.adjustToxLoss(5.666)
	return