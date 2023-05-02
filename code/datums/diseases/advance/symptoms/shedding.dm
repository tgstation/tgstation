/*Alopecia
 * No change to stealth
 * Slight increase to resistance
 * Increases stage speed
 * Increases transmissibility
 * Near critcal level
 * Bonus: Makes the mob lose hair.
*/
/datum/symptom/shedding
	name = "Alopecia"
	desc = "The virus causes rapid shedding of head and body hair."
	illness = "Thin Skinned"
	stealth = 0
	resistance = 1
	stage_speed = 2
	transmittable = 2
	level = 4
	severity = 1
	base_message_chance = 50
	symptom_delay_min = 45
	symptom_delay_max = 90

/datum/symptom/shedding/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return

	var/mob/living/M = A.affected_mob
	if(prob(base_message_chance))
		to_chat(M, span_warning("[pick("Your scalp itches.", "Your skin feels flaky.")]"))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(3, 4)
				if(!(H.hairstyle == "Bald") && !(H.hairstyle == "Balding Hair"))
					to_chat(H, span_warning("Your hair starts to fall out in clumps..."))
					addtimer(CALLBACK(src, PROC_REF(Shed), H, FALSE), 50)
			if(5)
				if(!(H.facial_hairstyle == "Shaved") || !(H.hairstyle == "Bald"))
					to_chat(H, span_warning("Your hair starts to fall out in clumps..."))
					addtimer(CALLBACK(src, PROC_REF(Shed), H, TRUE), 50)

/datum/symptom/shedding/proc/Shed(mob/living/carbon/human/H, fullbald)
	if(fullbald)
		H.facial_hairstyle = "Shaved"
		H.hairstyle = "Bald"
	else
		H.hairstyle = "Balding Hair"
	H.update_body_parts()
