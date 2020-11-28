/datum/reagent/toxin/plasma
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/toxin/acid
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/plasma/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC)
		C.nutrition = min(C.nutrition + 5, NUTRITION_LEVEL_FULL-1)
	..()
