/*Polyvitiligo
 * Slight reduction to stealth
 * Greatly increases resistance
 * Slightly increases stage speed
 * Increases transmissibility
 * Critical level
 * Bonus: Makes the mob gain a random crayon powder colorful reagent.
*/
/datum/symptom/polyvitiligo
	name = "Polyvitiligo"
	desc = "The virus replaces the melanin in the skin with reactive pigment."
	illness = "Chroma Imbalance"
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 5
	severity = 1
	symptom_delay_min = 7
	symptom_delay_max = 14

/datum/symptom/polyvitiligo/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return
	var/mob/living/victim = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(5)
			var/static/list/banned_reagents = list(/datum/reagent/colorful_reagent/powder/invisible, /datum/reagent/colorful_reagent/powder/white)
			var/color = pick(subtypesof(/datum/reagent/colorful_reagent/powder) - banned_reagents)
			if(victim.reagents.total_volume <= (victim.reagents.maximum_volume/10)) // no flooding humans with 1000 units of colorful reagent
				victim.reagents.add_reagent(color, 5)
		else
			if (prob(50)) // spam
				victim.visible_message(span_warning("[victim] looks rather vibrant..."), span_notice("The colors, man, the colors..."))
