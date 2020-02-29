/datum/species/dwarf
	name = "Dwarf"
	id = "dwarf"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "human"
	use_skintones = 1
	inherent_traits = list(TRAIT_CHUNKYFINGERS,TRAIT_NOBREATH)
	species_language_holder = /datum/language_holder/dwarf
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/dwarf/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	C.transform = C.transform.Scale(1, 0.8)
	passtable_on(C, INNATE_TRAIT)
	. = ..()

/datum/species/dwarf/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.transform = C.transform.Scale(1, 1.25)
	passtable_off(C, INNATE_TRAIT)
	. = ..()

