/*
//////////////////////////////////////
Asthmothia
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
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 8
	severity = 6

/datum/symptom/asthmothia/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/turf/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(2)
				A.affected_mob << "<span class='warning'>You try to cough out excess gases.</span>"
			if(4)
				A.affected_mob << "<span class='warning'>Your lungs hurt.</span>"
				T.atmos_spawn_air("co2=[50];TEMP=[T20C]")
				A.affected_mob.adjustToxLoss(5.666)
			if(5)
				if(prob(33))
					A.affected_mob << "<span class='warning'>You huff out some Plasma!</span>"
					T.atmos_spawn_air("plasma=[25];TEMP=[T20C]")
					A.affected_mob.adjustToxLoss(5.666)
				if(prob(33))
					A.affected_mob << "<span class='warning'>You cough up a plume of Nitrous Oxide!</span>"
					T.atmos_spawn_air("n2o=[50];TEMP=[T20C]")
					A.affected_mob.adjustToxLoss(10)
				else
					A.affected_mob << "<span class='warning'>Your lungs hurt.</span>"
					T.atmos_spawn_air("co2=[75];TEMP=[T20C]")
					A.affected_mob.adjustToxLoss(5.666)
	return

/*
//////////////////////////////////////
Apoptoplast
	Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittability.
BONUS
	Deletes gases harmlessly.
//////////////////////////////////////
*/
/datum/symptom/apoptoplast
	name = "Apotosplast"
	stealth = -1
	resistance = -1
	stage_speed = -4
	transmittable = -4
	level = 7
	severity = 6

/datum/symptom/apoptoplast/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/turf/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(2)
				A.affected_mob << "<span class='warning'>You breath out deeply.</span>"
			if(3)
				A.affected_mob << "<span class='warning'>Your lungs widen.</span>"
			if(4)
				A.affected_mob << "<span class='warning'>You take a huge breath and breath in!</span>"
			if(5)
				T.atmos_spawn_air("co2=-100;plasma=-100;n2o=-100")
	return