/*
//////////////////////////////////////

Itching

	Not noticable or unnoticable.
	Resistant.
	Increases stage speed.
	Little transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/itching

	name = "Itching"
	desc = "The virus irritates the skin, causing itching."
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 1
	level = 1
	severity = 1
	symptom_delay_min = 5
	symptom_delay_max = 25
	var/scratch = FALSE
	threshold_desc = "<b>Transmission 6:</b> Increases frequency of itching.<br>\
					  <b>Stage Speed 7:</b> The host will scrath itself when itching, causing superficial damage."

/datum/symptom/itching/Start(datum/disease/advance/A)
	..()
	if(A.properties["transmittable"] >= 6) //itch more often
		symptom_delay_min = 1
		symptom_delay_max = 4
	if(A.properties["stage_rate"] >= 7) //scratch
		scratch = TRUE

/datum/symptom/itching/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/can_scratch = scratch && !M.incapacitated()
	to_chat(M, "<span class='warning'>Your [pick("back", "arm", "leg", "elbow", "head")] itches. [can_scratch ? " You scratch it." : ""]</span>")
	if(can_scratch)
		M.adjustBruteLoss(0.5)