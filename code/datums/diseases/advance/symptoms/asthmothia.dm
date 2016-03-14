/*
//////////////////////////////////////
asthmothia
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
	stealth = -3
	resistance = -5
	stage_speed = -5
	transmittable = -6
	level = 5
	severity = 5

/datum/symptom/asthmothia/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/turf/simulated/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(2)
				A.affected_mob << "<span class='warning'>You try to cough out excess gases.</span>"
			if(4)
				A.affected_mob << "<span class='warning'>Your lungs hurt.</span>"
				T.atmos_spawn_air(SPAWN_20C | SPAWN_CO2, 100)
				A.affected_mob.adjustToxLoss(5.666)
			if(5)
				if(prob(50))
					A.affected_mob << "<span class='warning'>You huff out some Plasma!.</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 50)
					A.affected_mob.adjustToxLoss(5.666)
				else
					A.affected_mob << "<span class='warning'>You cough up a plume of Nitrous Oxide!</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_N2O, 50)
					A.affected_mob.adjustToxLoss(10)
	return

/*
//////////////////////////////////////
asthmothia traitor
	Very very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittability.
BONUS
	Spawns gases
Special additional bonus:
	Increased Stealth
	Increased resistance
	Increased stage speed
	Increased transmittance
	Increased effects
//////////////////////////////////////
*/
/datum/symptom/severeasthmothia
	name = "Severe Asthmothia"
	stealth = -2
	resistance = -4
	stage_speed = -3
	transmittable = -3
	level = 9 //you cannot get this with plasma.
	severity = 5

/datum/symptom/severeasthmothia/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/turf/simulated/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(1)
				A.affected_mob << "<span class='warning'>You dry heave.</span>"
			if(2)
				A.affected_mob << "<span class='warning'>You try to cough out excess gases.</span>"
			if(4)
				A.affected_mob << "<span class='warning'>Your lungs hurt.</span>"
				T.atmos_spawn_air(SPAWN_20C | SPAWN_CO2, 150)
				A.affected_mob.adjustToxLoss(5.666)
			if(5)
				if(prob(50))
					A.affected_mob << "<span class='warning'>You huff out some Plasma!.</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 50)
					A.affected_mob.adjustToxLoss(10)
				else
					A.affected_mob << "<span class='warning'>You cough up a plume of Nitrous Oxide!</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_N2O, 100)
					A.affected_mob.adjustToxLoss(12)
	return