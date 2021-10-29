/datum/species/lizard/ashwalker
	mutanteyes = /obj/item/organ/eyes/night_vision
	burnmod = 0.7
	brutemod = 0.8

/datum/species/lizard/ashwalker/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	ADD_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

/datum/species/lizard/ashwalker/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)
