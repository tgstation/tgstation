/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	id = "mush"
	mutant_bodyparts = list("caps", "tail_human", "ears", "wings")
	default_features = list("caps" = "Round", "tail_human" = "None", "ears" = "None", "wings" = "None")

	fixed_mut_color = "DBBF92"
	hair_color = "FF4B19" //cap color, spot color uses eye color
	nojumpsuit = 1

	say_mod = "poofs" //what does a mushroom sound like
	species_traits = list(MUTCOLORS, NOEYES, NO_UNDERWEAR, NOBREATH)
	speedmod = 1.5 //faster than golems but not by much

	punchdamagelow = 6
	punchdamagehigh = 14
	punchstunthreshold = 14 //about 44% chance to stun

	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform)

	burnmod = 1.25
	heatmod = 1.5

	mutanteyes = /obj/item/organ/eyes/night_vision/mushroom
	use_skintones = FALSE

/datum/species/mush/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/mushroom) //pomf pomf

/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "mushroom"

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "mushroom"

/datum/species/mush/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "weedkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/mush/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	forced_colour = FALSE
	..()
