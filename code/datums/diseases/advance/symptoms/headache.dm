/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	stealth = -1
	resistance = 4
	stage_speed = 2
	transmittable = 0
	level = 1
	severity = 1
	base_message_chance = 100
	symptom_delay_min = 15
	symptom_delay_max = 30

/datum/symptom/headache/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 4)
		base_message_chance = 50
	if(A.properties["stage_rate"] >= 6) //severe pain
		power = 2
	if(A.properties["stage_rate"] >= 9) //cluster headaches
		symptom_delay_min = 30
		symptom_delay_max = 60
		power = 3

/datum/symptom/headache/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(power < 2)
		if(prob(base_message_chance))
			to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your head pounds.")]</span>")
	if(power >= 2)
		to_chat(M, "<span class='warning'>[pick("Your head hurts a lot.", "Your head pounds incessantly.")]</span>")
		M.adjustStaminaLoss(25)
	if(power >= 3)
		to_chat(M, "<span class='userdanger'>[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]</span>")
		M.Stun(35)