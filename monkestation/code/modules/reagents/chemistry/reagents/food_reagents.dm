/datum/reagent/consumable/char/overdose_start(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(!(HAIR in H.dna.species.species_traits)) //No hair? No problem!
		H.dna.species.species_traits += HAIR
	H.hair_style = "Balding Hair"
	H.facial_hair_style = "Shaved"
	H.facial_hair_color = "000"
	H.hair_color = "000"
	if(SKINTONES in H.dna.species.species_traits)
		H.skin_tone = "albino"
	else if(MUTCOLORS in H.dna.species.species_traits)
		H.dna.features["mcolor"] = "fff"
	H.regenerate_icons()
	H.grant_language(/datum/language/sippins, TRUE, TRUE, "spray")
