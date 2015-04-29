/*
//////////////////////////////////////

asthmosthia

////////////
///DANGER///
////////////

TERROR RUN FLEE GO RUN

//////////////////////////////////////
*/

/datum/symptom/asthmothia

	name = "Asthmothia"
	stealth = -3
	resistance = -5
	stage_speed = -5
	transmittable = -5
	level = 5
	severity = 5

/datum/symptom/asthmothia/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 4))
		var/turf/simulated/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(5)
				if(prob(6.66))
					A.affected_mob << "<span class='warning'>You conjure the unholy lords of Atmospherics and emit a cloud of smoke and fire so strong that you cannot help but perish at the sight! Also, you fucking exploded.</span>"
					T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 666.66)
					playsound(A.affected_mob.loc, 'sound/effects/Explosion1.ogg', 50, 1)
					A.affected_mob.gib()
				else
					A.affected_mob << "<span class='warning'>You cough up a plume of Plasma!</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 20)
			else
				A.affected_mob << "<span class='warning'>Something feels wrong, very wrong.</span>"
				T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 10)
				A.affected_mob.adjustToxLoss(5.666)
	return
