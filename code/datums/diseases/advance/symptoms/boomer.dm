/*
//////////////////////////////////////
Moonmoon_ow Hair Virus

	Not Noticeable.
	Increases resistance slightly.
	Increases stage speed.
	Transmittable.
	Intense Level.

BONUS
	Makes the mob become a strapping boomer of receding hair.

//////////////////////////////////////
*/

/datum/symptom/boomer
	name = "Boomeritis"
	desc = "The virus causes a receding hair line of LEGENDARY proportions."
	stealth = 0
	resistance = 1
	stage_speed = 2
	transmittable = 2
	level = 3
	severity = 1
	base_message_chance = 50
	symptom_delay_min = 45
	symptom_delay_max = 90

/datum/symptom/boomer/Activate(datum/disease/advance/A)
	if(!..())
		return

	var/mob/living/M = A.affected_mob
	if(prob(base_message_chance))
		to_chat(M, "<span class='warning'>[pick("Your scalp itches.", "Your head feels legendary.")]</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(3, 4)
				if(!(H.hairstyle == "Bald") && !(H.hairstyle == "Balding Hair"))
					to_chat(H, "<span class='warning'>Your hairline starts to recede...</span>")
					addtimer(CALLBACK(src, .proc/Boomshed, H, FALSE), 50)
			if(5)
				if(!(H.facial_hairstyle == "Shaved") || !(H.hairstyle == "Bald"))
					to_chat(H, "<span class='warning'>Your head starts to become LEGENDARY...</span>")
					addtimer(CALLBACK(src, .proc/Boomshed, H, TRUE), 50)

/datum/symptom/boomer/proc/Boomshed(mob/living/carbon/human/H, fullbald)
	if(fullbald)
		H.facial_hairstyle = "Shaved"
		H.hairstyle = "Strapping Boomer"
	else
		H.hairstyle = "Strapping Boomer"
	H.update_hair()
