
/*
//////////////////////////////////////
Narcolepsy
	Noticeable.
	Lowers resistance
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.

Bonus
	Causes drowsiness and sleep.

//////////////////////////////////////
*/
/datum/symptom/narcolepsy
	name = "Narcolepsy"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = -4
	level = 6
	symptom_delay_min = 25
	symptom_delay_max = 70
	severity = 4
	var/stamina = FALSE
	threshold_desc = "<b>Transmission 7:</b> Also relaxes the muscles, weakening and slowing the host.<br>\
					  <b>Resistance 10:</b> Causes narcolepsy more often, increasing the chance of the host falling asleep."

/datum/symptom/narcolepsy/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 7) //stamina damage
		stamina = TRUE
	if(A.properties["resistance"] >= 10) //act more often
		symptom_delay_min = 20
		symptom_delay_max = 45

/datum/symptom/narcolepsy/Activate(var/datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(50))
				to_chat(M, "<span class='warning'>You feel tired.</span>")
		if(2)
			if(prob(50))
				to_chat(M, "<span class='warning'>You feel very tired.</span>")
		if(3)
			if(prob(50))
				to_chat(M, "<span class='warning'>You try to focus on staying awake.</span>")
			M.drowsyness += 5
		if(4)
			if(prob(50))
				to_chat(M, "<span class='warning'>You nod off for a moment.</span>")
			M.drowsyness += 10
			if(stamina)
				M.adjustStaminaLoss(20)
		if(5)
			if(prob(50))
				to_chat(M, "<span class='warning'>[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]</span>")
			M.drowsyness = min(M.drowsyness + 40, 200)
			if(stamina)
				M.adjustStaminaLoss(30)
