/datum/species/troll
	name = "troll"
	id = "troll"
	default_color = "c4c4c4"
	species_traits = list(MUTCOLORS,HAIR,FACEHAIR,LIPS,TROLLHORNS)
	mutant_bodyparts = list("tail_human", "wings")
	default_features = list("mcolor" = "c4c4c4", "tail_human" = "None", "wings" = "None")
	use_skintones = 0
	fixed_mut_color="c4c4c4"
	hair_color="000000"
	limbs_id = "human"
	exotic_bloodtype = "T"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | DAIRY
	liked_food = JUNKFOOD | MEAT


/datum/species/troll/qualifies_for_rank(rank, list/features)
	return TRUE

datum/species/troll/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	if(H.dna.features["ears"] == "Cat")
		mutantears = /obj/item/organ/ears/cat
	if(H.dna.features["tail_human"] == "Cat")
		var/tail = /obj/item/organ/tail/cat
		mutant_organs += tail
	H.blood_color = get_color_from_caste(H.dna.features["troll_caste"])
	..()

/datum/species/troll/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_troll_name()

	return troll_name()
