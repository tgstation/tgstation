/*
//////////////////////////////////////

Choking

	Very very noticable.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	Inflicts spikes of oxyloss

//////////////////////////////////////
*/

/datum/symptom/choking

	name = "Choking"
	desc = "The virus causes inflammation of the host's air conduits, leading to intermittent choking."
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -4
	level = 3
	severity = 3
	base_message_chance = 15
	symptom_delay_min = 10
	symptom_delay_max = 30
	threshold_desc = "<b>Stage Speed 8:</b> Causes choking more frequently.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/choking/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8)
		symptom_delay_min = 7
		symptom_delay_max = 24
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE

/datum/symptom/choking/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]</span>")
		if(3, 4)
			if(!suppress_warning)
				to_chat(M, "<span class='warning'>[pick("Your windpipe feels like a straw.", "Your breathing becomes tremendously difficult.")]</span>")
			else
				to_chat(M, "<span class='warning'>You feel very [pick("dizzy","woozy","faint")].</span>") //fake bloodloss messages
			Choke_stage_3_4(M, A)
			M.emote("gasp")
		else
			to_chat(M, "<span class='userdanger'>[pick("You're choking!", "You can't breathe!")]</span>")
			Choke(M, A)
			M.emote("gasp")

/datum/symptom/choking/proc/Choke_stage_3_4(mob/living/M, datum/disease/advance/A)
	M.adjustOxyLoss(rand(6,13))
	return 1

/datum/symptom/choking/proc/Choke(mob/living/M, datum/disease/advance/A)
	M.adjustOxyLoss(rand(10,18))
	return 1
