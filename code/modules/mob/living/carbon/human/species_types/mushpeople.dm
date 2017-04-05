/datum/species/mush //mush mush codecuck
	name = "Mushroomperson"
	id = "mush"
	mutant_bodyparts = list("caps", "tail_human", "ears", "wings")
	default_features = list("mcolor" = "DBBF92", "caps" = "Round", "tail_human" = "None", "ears" = "None", "wings" = "None")


	say_mod = "moops" //what does a mushroom sound like
	species_traits = list(EYECOLOR, MUTCOLORS, SPECIALCOLORS_PARTSONLY)

	punchdamagelow = 5
	punchdamagehigh = 12
	punchstunthreshold = 9 //about 33% chance to stun

	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform)

	burnmod = 1.25
	heatmod = 1.5

	meat = /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice

	mutanteyes = /obj/item/organ/eyes/night_vision
	use_skintones = FALSE



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
