/*
//////////////////////////////////////

Stimulant

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	The body generates Ephedrine.

//////////////////////////////////////
*/

/datum/symptom/stimulant

	name = "Stimulant"
	stealth = -1
	resistance = -3
	stage_speed = 4
	transmittable = -4
	level = 4

/datum/symptom/stimulant/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				if (M.reagents.get_reagent_amount("ephedrine") < 15)
					M.reagents.add_reagent("ephedrine", 7)
				if (M.reagents.get_reagent_amount("coffee") < 20)
					M.reagents.add_reagent("coffee", 20)
				if (M.reagents.get_reagent_amount("hyperzine") < 15)
					M.reagents.add_reagent("hyperzine", 7)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel restless.", "You feel like running laps around the station.", "You feel like GOING FAST around the station.")]</span>"
	return
