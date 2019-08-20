/datum/species/angel
	name = "Angel"
	id = "angel"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "Angel")
	use_skintones = 1
	no_equip = list(SLOT_BACK)
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	flying_species = TRUE
	wings_icon = "Angel"

/datum/species/angel/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	ADD_TRAIT(H, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/angel/on_species_loss(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_HOLY, SPECIES_TRAIT)
	..()
