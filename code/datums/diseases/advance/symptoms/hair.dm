/*
//////////////////////////////////////
Alopecia

	Not Noticeable.
	Increases resistance slightly.
	Reduces stage speed slightly.
	Transmittable.
	Intense Level.

BONUS
	Makes the mob lose hair.

//////////////////////////////////////
*/

/datum/symptom/shedding
	name = "Alopecia"
	desc = "The virus causes rapid shedding of head and body hair."
	stealth = 0
	resistance = 1
	stage_speed = -1
	transmittable = 3
	level = 4
	severity = 1
	base_message_chance = 50
	symptom_delay_min = 45
	symptom_delay_max = 90

/datum/symptom/shedding/Activate(datum/disease/advance/A)
	if(!..())
		return

	var/mob/living/M = A.affected_mob
	if(prob(base_message_chance))
		to_chat(M, "<span class='warning'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(3, 4)
				if(!(H.hair_style == "Bald") && !(H.hair_style == "Balding Hair"))
					to_chat(H, "<span class='warning'>Your hair starts to fall out in clumps...</span>")
					addtimer(CALLBACK(src, .proc/Shed, H, FALSE), 50)
			if(5)
				if(!(H.facial_hair_style == "Shaved") || !(H.hair_style == "Bald"))
					to_chat(H, "<span class='warning'>Your hair starts to fall out in clumps...</span>")
					addtimer(CALLBACK(src, .proc/Shed, H, TRUE), 50)

/datum/symptom/shedding/proc/Shed(mob/living/carbon/human/H, fullbald)
	if(fullbald)
		H.facial_hair_style = "Shaved"
		H.hair_style = "Bald"
	else
		H.hair_style = "Balding Hair"
	H.update_hair()

/*
//////////////////////////////////////
Facial Hypertrichosis

	Very very Noticable.
	Decreases resistance slightly.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	stealth = -3
	resistance = -1
	stage_speed = -3
	transmittable = -1
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
