/*
//////////////////////////////////////

Self-Respiration

	Slightly hidden.
	Lowers resistance significantly.
	Decreases stage speed significantly.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates salbutamol.

//////////////////////////////////////
*/

/datum/symptom/oxygen

	name = "Self-Respiration"
	desc = "The virus rapidly synthesizes oxygen, effectively removing the need for breathing."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 6
	base_message_chance = 5
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/regenerate_blood = FALSE
	var/already_NOBREATH = FALSE
	threshold_desc = "<b>Resistance 8:</b>Additionally regenerates lost blood.<br>"

/datum/symptom/oxygen/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 8) //blood regeneration
		regenerate_blood = TRUE
	if(A.affected_mob.has_trait(TRAIT_NOBREATH)) // with inorganic biology one could already have NOBREATH
		already_NOBREATH = TRUE

/datum/symptom/oxygen/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.adjustOxyLoss(-7, 0)
			M.losebreath = max(0, M.losebreath - 4)
			if(regenerate_blood && M.blood_volume < BLOOD_VOLUME_NORMAL)
				M.blood_volume += 1
		else
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]</span>")
	return

/datum/symptom/oxygen/change_stage(new_stage, datum/disease/advance/A)
	if(!..())
		return
	if(already_NOBREATH)
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(3)
			M.remove_trait(TRAIT_NOBREATH)
		if(4)
			M.add_trait(TRAIT_NOBREATH)

/datum/symptom/oxygen/End(datum/disease/advance/A)
	if(!..())
		return
	if(!already_NOBREATH)
		A.affected_mob.remove_trait(TRAIT_NOBREATH)
