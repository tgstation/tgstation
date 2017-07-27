/*
//////////////////////////////////////
Vitiligo

	Extremely Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Reduces transmission.
	Critical Level.

BONUS
	Makes the mob lose skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/vitiligo

	name = "Vitiligo"
	stealth = -3
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 5
	severity = 1
	symptom_delay_min = 25
	symptom_delay_max = 75

/datum/symptom/vitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "albino")
			return
		switch(A.stage)
			if(5)
				H.skin_tone = "albino"
				H.update_body(0)
			else
				H.visible_message("<span class='warning'>[H] looks a bit pale...</span>", "<span class='notice'>Your skin suddenly appears lighter...</span>")


/*
//////////////////////////////////////
Revitiligo

	Extremely Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Reduces transmission.
	Critical Level.

BONUS
	Makes the mob gain skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/revitiligo

	name = "Revitiligo"
	stealth = -3
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 5
	severity = 1
	symptom_delay_min = 7
	symptom_delay_max = 14

/datum/symptom/revitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "african2")
			return
		switch(A.stage)
			if(5)
				H.skin_tone = "african2"
				H.update_body(0)
			else
				H.visible_message("<span class='warning'>[H] looks a bit dark...</span>", "<span class='notice'>Your skin suddenly appears darker...</span>")
