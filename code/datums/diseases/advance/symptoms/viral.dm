/*
//////////////////////////////////////
Viral adaptation

	Moderate stealth boost.
	Major Increases to resistance.
	Reduces stage speed.
	No change to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viraladaptation
	name = "Viral self-adaptation"
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmittable = 0
	level = 3

/datum/symptom/viraladaptation/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				M << "<span class='notice'>You feel off, but no different from before.</span>"
			if(5)
				M << "<span class='notice'>You feel better, but nothing interesting happens.</span>"

/*
//////////////////////////////////////
Viral evolution

	Moderate stealth reductopn.
	Major decreases to resistance.
	increases stage speed.
	increase to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viralevolution
	name = "Viral evolutionary acceleration"
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmittable = 3
	level = 3

/datum/symptom/viraladaptation/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				M << "<span class='notice'>You feel better, but no different from before.</span>"
			if(5)
				M << "<span class='notice'>You feel off, but nothing interesting happens.</span>"