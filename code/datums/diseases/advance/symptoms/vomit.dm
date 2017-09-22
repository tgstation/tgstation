/*
//////////////////////////////////////

Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmittable.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	desc = "The virus causes nausea and irritates the stomach, causing occasional vomit."
	stealth = -2
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 3
	severity = 4
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	var/vomit_blood = FALSE
	var/proj_vomit = 0
	threshold_desc = "<b>Resistance 7:</b> Host will vomit blood, causing internal damage.<br>\
					  <b>Transmission 7:</b> Host will projectile vomit, increasing vomiting range.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/vomit/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["resistance"] >= 7) //blood vomit
		vomit_blood = TRUE
	if(A.properties["transmittable"] >= 7) //projectile vomit
		proj_vomit = 5

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>")
		else
			vomit(M)

/datum/symptom/vomit/proc/vomit(mob/living/carbon/M)
	M.vomit(20, vomit_blood, distance = proj_vomit)
