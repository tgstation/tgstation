/*
//////////////////////////////////////
Stimulant //gotta go fast
	Noticeable.
	Lowers resistance.
	Decreases stage speed moderately.
	Decreases transmittablity.
	Moderate Level.
Bonus
	Increases movement speed.
//////////////////////////////////////
*/

/datum/symptom/stimulant

	name = "Stimulant"
	stealth = -1
	resistance = -1
	stage_speed = -2
	transmittable = -2
	level = 3

/datum/symptom/stimulant/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				if (M.reagents.get_reagent_amount("viral_ephedrine") < 10)
					M.reagents.add_reagent("viral_ephedrine", 10)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel restless.", "You feel like running laps around the station.")]</span>"
	return

/*
//////////////////////////////////////
Adrenaline
	Noticeable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity.
	Moderate Level.
Bonus
	Increases movement speed.
//////////////////////////////////////
*/

/datum/symptom/adrenaline

	name = "Adrenaline"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -2
	level = 5

/datum/symptom/adrenaline/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				if (M.reagents.get_reagent_amount("viral_adrenaline") < 10)
					M.reagents.add_reagent("viral_adrenaline", 10)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel full of energy.", "You feel restless.")]</span>"
	return