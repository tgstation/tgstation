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

/*
//////////////////////////////////////

Viral aggressive metabolism

	Reduced stealth.
	Small resistance boost.
	Increased stage speed.
	Small transmittablity boost.
	Medium Level.

Bonus
	The virus starts at stage 5, but after a certain time will start curing itself.
	Stages still increase naturally with stage speed.

//////////////////////////////////////
*/

/datum/symptom/viralreverse

	name = "Viral aggressive metabolism"
	stealth = -2
	resistance = 1
	stage_speed = 3
	transmittable = 1
	level = 3
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/time_to_cure

/datum/symptom/viralreverse/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(time_to_cure > 0)
		time_to_cure--
	else
		var/mob/living/M = A.affected_mob
		Heal(M, A)

/datum/symptom/viralreverse/proc/Heal(mob/living/M, datum/disease/advance/A)
	A.stage -= 1
	if(A.stage < 2)
		to_chat(M, "<span class='notice'>You suddenly feel healthy.</span>")
		A.cure()

/datum/symptom/viralreverse/Start(datum/disease/advance/A)
	..()
	A.stage = 5
	if(A.properties["stealth"] >= 4) //more time before it's cured
		power = 2
	time_to_cure = max(A.properties["resistance"], A.properties["stage_rate"]) * 10 * power
