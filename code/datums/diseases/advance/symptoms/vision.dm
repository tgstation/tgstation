/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	desc = "The virus causes inflammation of the retina, leading to eye damage and eventually blindness."
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 4
	base_message_chance = 50
	symptom_delay_min = 25
	symptom_delay_max = 80
	var/remove_eyes = FALSE
	threshold_desc = "<b>Resistance 12:</b> Weakens extraocular muscles, eventually leading to complete detachment of the eyes.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/visionloss/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["resistance"] >= 12) //goodbye eyes
		remove_eyes = TRUE

/datum/symptom/visionloss/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/obj/item/organ/eyes/eyes = M.getorganslot("eye_sight")
	if(istype(eyes))
		switch(A.stage)
			if(1, 2)
				if(prob(base_message_chance) && !suppress_warning)
					to_chat(M, "<span class='warning'>Your eyes itch.</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>Your eyes burn!</b></span>")
				M.blur_eyes(10)
				M.adjust_eye_damage(1)
			else
				M.blur_eyes(20)
				M.adjust_eye_damage(5)
				if(eyes.eye_damage >= 10)
					M.become_nearsighted()
				if(prob(eyes.eye_damage - 10 + 1))
					if(!remove_eyes)
						if(M.become_blind())
							to_chat(M, "<span class='userdanger'>You go blind!</span>")
					else
						M.visible_message("<span class='warning'>[M]'s eyes fall off their sockets!</span>", "<span class='userdanger'>Your eyes fall off their sockets!</span>")
						eyes.Remove(M)
						eyes.forceMove(get_turf(M))
				else
					to_chat(M, "<span class='userdanger'>Your eyes burn horrifically!</span>")



/*
//////////////////////////////////////

Ocular Restoration

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	High level.

Bonus
	Restores eyesight.

//////////////////////////////////////
*/

/datum/symptom/visionaid

	name = "Ocular Restoration"
	desc = "The virus stimulates the production and replacement of eye cells, causing the host to regenerate its eyes when damaged."
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -4
	level = 4
	base_message_chance = 7
	symptom_delay_min = 1
	symptom_delay_max = 1

/datum/symptom/visionaid/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/obj/item/organ/eyes/eyes = M.getorganslot("eye_sight")
	if (!eyes)
		return
	switch(A.stage)
		if(4, 5) //basically oculine
			if(M.disabilities & BLIND)
				if(prob(20))
					to_chat(M, "<span class='warning'>Your vision slowly returns...</span>")
					M.cure_blind()
					M.cure_nearsighted()
					M.blur_eyes(35)

				else if(M.disabilities & NEARSIGHT)
					to_chat(M, "<span class='warning'>The blackness in your peripheral vision fades.</span>")
					M.cure_nearsighted()
					M.blur_eyes(10)

				else if(M.eye_blind || M.eye_blurry)
					M.set_blindness(0)
					M.set_blurriness(0)
				else if(eyes.eye_damage > 0)
					M.adjust_eye_damage(-1)
		else
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your eyes feel great.", "You are now blinking manually.", "You don't feel the need to blink.")]</span>")
	return
