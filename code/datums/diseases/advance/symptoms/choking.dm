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
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -4
	level = 3
	severity = 3

/datum/symptom/choking/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("Your windpipe feels like a straw.", "Your breathing becomes tremendously difficult.")]</span>")
				Choke_stage_3_4(M, A)
				M.emote("gasp")
			else
				to_chat(M, "<span class='userdanger'>[pick("You're choking!", "You can't breathe!")]</span>")
				Choke(M, A)
				M.emote("gasp")
	return

/datum/symptom/choking/proc/Choke_stage_3_4(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrt(21+A.totalStageSpeed()*0.5)+sqrt(max(16+A.totalStealth(),0))
	M.adjustOxyLoss(get_damage)
	return 1

/datum/symptom/choking/proc/Choke(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrt(21+A.totalStageSpeed()*0.5)+sqrt(max(16+A.totalStealth()*5,0))
	M.adjustOxyLoss(get_damage)
	return 1

/*
//////////////////////////////////////

Asphyxiation

	Very very noticable.
	Decreases stage speed.
	Decreases transmittablity.

Bonus
	Inflicts large spikes of oxyloss
	Introduces Asphyxiating drugs to the system
	Causes cardiac arrest on dying victims.

//////////////////////////////////////
*/

/datum/symptom/asphyxiation

	name = "Acute respiratory distress syndrome"
	stealth = -2
	resistance = -0
	stage_speed = -1
	transmittable = -2
	level = 7
	severity = 3

/datum/symptom/asphyxiation/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("Your windpipe feels thin.", "Your lungs feel small.")]</span>")
				Asphyxiate_stage_3_4(M, A)
				M.emote("gasp")
			else
				to_chat(M, "<span class='userdanger'>[pick("Your lungs hurt!", "It hurts to breathe!")]</span>")
				Asphyxiate(M, A)
				M.emote("gasp")
				if(M.getOxyLoss() >= 120)
					M.visible_message("<span class='warning'>[M] stops breathing, as if their lungs have totally collapsed!</span>")
					Asphyxiate_death(M, A)
	return

/datum/symptom/asphyxiation/proc/Asphyxiate_stage_3_4(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrt(abs(21+A.totalStageSpeed()*0.7))+sqrt(abs(16+A.totalStealth()))
	M.adjustOxyLoss(get_damage)
	return 1

/datum/symptom/asphyxiation/proc/Asphyxiate(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrt(abs(21+A.totalStageSpeed()))+sqrt(abs(16+A.totalStealth()*5))
	M.adjustOxyLoss(get_damage)
	M.reagents.add_reagent_list(list("pancuronium" = 2, "sodium_thiopental" = 2))
	return 1

/datum/symptom/asphyxiation/proc/Asphyxiate_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = sqrt(abs(21+A.totalStageSpeed()*1.5))+sqrt(abs(16+A.totalStealth()*7))
	M.adjustOxyLoss(get_damage)
	M.adjustBrainLoss(get_damage/2)
	return 1
