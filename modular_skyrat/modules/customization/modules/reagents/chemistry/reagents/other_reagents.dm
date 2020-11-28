/datum/reagent/fuel
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/oil
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/stable_plasma
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/pax
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/water
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/hellwater
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/syndicateadrenals
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC)
		C.nutrition = min(C.nutrition + 5, NUTRITION_LEVEL_FULL-1)
	..()

/datum/reagent/fuel/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC)
		C.nutrition = min(C.nutrition + 5, NUTRITION_LEVEL_FULL-1)
	..()

/datum/reagent/oil/on_mob_life(mob/living/carbon/C)
	if(C.mob_biotypes & MOB_ROBOTIC && C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume += 0.5
	..()
