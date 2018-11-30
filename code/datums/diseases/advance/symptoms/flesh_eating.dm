/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Necrotizing Fasciitis"
	desc = "The virus aggressively attacks body cells, necrotizing tissues and organs."
	stealth = -3
	resistance = -4
	stage_speed = 0
	transmittable = -4
	level = 6
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 10
	symptom_delay_max = 20
	var/internal_ratio = 0.25
	var/pain = FALSE
	threshold_desc = "<b>Resistance 7:</b> Increases the amount of internal damage done by the symptom.<br>\
					  <b>Transmission 8:</b> Causes extreme pain to the host, weakening it."

/datum/symptom/flesh_eating/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 7) //more internal damage
		internal_ratio = 0.75
	if(A.properties["transmittable"] >= 8) //extra stamina damage
		pain = TRUE

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")
		if(4,5)
			if(prob(base_message_chance * 2))
				to_chat(M, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
			Flesheat(M, A)

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(4,7) * power
	var/internal_damage = get_damage * internal_ratio
	get_damage -= internal_damage
	M.take_overall_damage(brute = get_damage, required_status = BODYPART_ORGANIC)
	M.adjustInternalLoss(internal_damage)
	if(pain)
		M.adjustStaminaLoss(get_damage)
	return 1

/*
//////////////////////////////////////

Autophagocytosis (AKA Programmed mass cell death)

	Very noticable.
	Lowers resistance.
	Fast stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_death

	name = "Autophagocytosis Necrosis"
	desc = "The virus rapidly consumes infected cells, leading to heavy and widespread damage."
	stealth = -2
	resistance = -2
	stage_speed = 1
	transmittable = -2
	level = 7
	severity = 6
	base_message_chance = 50
	symptom_delay_min = 3
	symptom_delay_max = 6
	var/internal_ratio = 0.3
	var/chems = FALSE
	var/zombie = FALSE
	threshold_desc = "<b>Stage Speed 7:</b> Synthesizes Heparin and Lipolicide inside the host, causing increased bleeding and hunger.<br>\
					  <b>Stealth 5:</b> The symptom remains hidden until active.<br>\
					  <b>Resistance 8:</b> Increases the amount of internal damage done by the symptom."

/datum/symptom/flesh_death/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 5)
		suppress_warning = TRUE
	if(A.properties["stage_rate"] >= 7) //bleeding and hunger
		chems = TRUE
	if(A.properties["resistance"] >= 8) //more internal damage
		internal_ratio = 0.85
	

/datum/symptom/flesh_death/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You feel your body break apart.", "Your skin rubs off like dust.")]</span>")
		if(4,5)
			if(prob(base_message_chance / 2)) //reduce spam
				to_chat(M, "<span class='userdanger'>[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]</span>")
			Flesh_death(M, A)

/datum/symptom/flesh_death/proc/Flesh_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(3,5)
	M.take_overall_damage(brute = get_damage, required_status = BODYPART_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list("heparin" = 2, "lipolicide" = 2))
	if(zombie)
		M.reagents.add_reagent("romerol", 1)
	return 1