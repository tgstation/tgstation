/*
//////////////////////////////////////

Temperature Adaptation

	No resistance change.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Heals burn damage over time, and helps stabilize body temperature.

//////////////////////////////////////
*/

/datum/symptom/burnheal
	name = "Temperature Adaptation"
	desc = "The virus quickly balances body heat, while also replacing tissues damaged by external sources."
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/hide_healing = FALSE
	threshold_desc = "<b>Stage Speed 6:</b> Doubles healing speed.<br>\
					  <b>Stage Speed 11:</b> Triples healing speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/burnheal/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4) //invisible healing
		hide_healing = TRUE
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2
	if(A.properties["stage_rate"] >= 11) //even stronger healing
		power = 3

/datum/symptom/burnheal/Activate(datum/disease/advance/A)
	if(!..())
		return
	 //100% chance to activate for slow but consistent healing
	var/mob/living/L = A.affected_mob
	if(!iscarbon(L))
		return
	switch(A.stage)
		if(4, 5)
			var/mob/living/carbon/M = L
			var/heal_amt = 4 * power

			var/list/parts = M.get_damaged_bodyparts(0,1) //burn only

			if(M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (10 * heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))
			else if(M.bodytemperature < 311)
				M.bodytemperature = min(310, M.bodytemperature + (10 * heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))

			if(!parts.len)
				return

			for(var/obj/item/bodypart/L in parts)
				if(L.heal_damage(0, heal_amt/parts.len))
					M.update_damage_overlays()

			if(prob(base_message_chance) && !hide_healing)
				new /obj/effect/temp_visual/heal(get_turf(M), "#CC6600")
			return 1
