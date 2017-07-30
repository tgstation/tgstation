/*
//////////////////////////////////////

Deafness

	Slightly noticable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness

	name = "Deafness"
	stealth = -1
	resistance = -2
	stage_speed = -1
	transmittable = -3
	level = 4
	severity = 3
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80

/datum/symptom/deafness/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["resistance"] >= 9) //permanent deafness
		power = 2

/datum/symptom/deafness/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>")
		if(5)
			if(power > 2)
				var/obj/item/organ/ears/ears = M.getorganslot("ears")
				if(istype(ears) && ears.ear_damage < UNHEALING_EAR_DAMAGE)
					to_chat(M, "<span class='userdanger'>Your ears pop painfully and start bleeding!</span>")
					ears.ear_damage = max(ears.ear_damage, UNHEALING_EAR_DAMAGE)
					M.emote("scream")
			else
				to_chat(M, "<span class='userdanger'>Your ears pop and begin ringing loudly!</span>")
				M.minimumDeafTicks(20)
