/datum/species/human
	name = "Human"
	id = "human"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.


/datum/species/human/dwarf
	name = "Dwarf"
	id = "dwarf"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "human"
	use_skintones = 1
	inherent_traits = list(TRAIT_NOBREATH)
	species_language_holder = /datum/language_holder/dwarf

/datum/species/human/dwarf/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	C.transform = C.transform.Scale(1, 0.8)
	passtable_on(C, INNATE_TRAIT)
	. = ..()

