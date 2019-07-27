<<<<<<< HEAD
/*
//////////////////////////////////////
Facial Hypertrichosis

	No change to stealth.
	Increases resistance.
	Increases speed.
	Slighlty increases transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	stealth = 0
	resistance = 3
	stage_speed = 2
	transmittable = 1
	level = 4
	severity = 1
	symptom_delay_min = 18
	symptom_delay_max = 36

	var/list/beard_order = list("Beard (Jensen)", "Beard (Full)", "Beard (Dwarf)", "Beard (Very Long)")

/datum/symptom/beard/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/index = min(max(beard_order.Find(H.facial_hair_style)+1, A.stage-1), beard_order.len)
		if(index > 0 && H.facial_hair_style != beard_order[index])
			to_chat(H, "<span class='warning'>Your chin itches.</span>")
			H.facial_hair_style = beard_order[index]
			H.update_hair()

=======
/*
//////////////////////////////////////
Facial Hypertrichosis

	No change to stealth.
	Increases resistance.
	Increases speed.
	Slighlty increases transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	stealth = 0
	resistance = 3
	stage_speed = 2
	transmittable = 1
	level = 4
	severity = 1
	symptom_delay_min = 18
	symptom_delay_max = 36

/datum/symptom/beard/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(1, 2)
				to_chat(H, "<span class='warning'>Your chin itches.</span>")
				if(H.facial_hair_style == "Shaved")
					H.facial_hair_style = "Jensen Beard"
					H.update_hair()
			if(3, 4)
				to_chat(H, "<span class='warning'>You feel tough.</span>")
				if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard") && !(H.facial_hair_style == "Full Beard"))
					H.facial_hair_style = "Full Beard"
					H.update_hair()
			else
				to_chat(H, "<span class='warning'>You feel manly!</span>")
				if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard"))
					H.facial_hair_style = pick("Dwarf Beard", "Very Long Beard")
					H.update_hair()
>>>>>>> Updated this old code to fork
