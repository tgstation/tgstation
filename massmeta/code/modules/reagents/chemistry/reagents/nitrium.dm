/datum/reagent/nitrium_high_metabolization/on_mob_metabolize(mob/living/breather)
	. = ..()
	ADD_TRAIT(breather, TRAIT_STUNIMMUNE, type)

/datum/reagent/nitrium_high_metabolization/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	REMOVE_TRAIT(breather, TRAIT_STUNIMMUNE, type)
