/datum/dna_block/feature/mutant_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_MUTANT_COLOR

/datum/dna_block/feature/mutant_color/unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.dna.features[feature_key], include_crunch = FALSE)

/datum/dna_block/feature/ethereal_color
	block_length = DNA_BLOCK_SIZE_COLOR
	feature_key = FEATURE_ETHEREAL_COLOR

/datum/dna_block/feature/ethereal_color/unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.dna.features[FEATURE_ETHEREAL_COLOR], include_crunch = FALSE)

/datum/dna_block/feature/ears
	feature_key = FEATURE_EARS

/datum/dna_block/feature/ears/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.ears_list.Find(target.dna.features[feature_key]), length(SSaccessories.ears_list))

// One day, someone should consider merging all tails into one, this is stupid
// No I don't care that it will "Create situations where a felinid grows a lizard tail" that makes it more fun
/datum/dna_block/feature/tail
	feature_key = FEATURE_TAIL

/datum/dna_block/feature/tail/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.tails_list_felinid.Find(target.dna.features[feature_key]), length(SSaccessories.tails_list_felinid))

/datum/dna_block/feature/tail_lizard
	feature_key = FEATURE_TAIL_LIZARD

/datum/dna_block/feature/tail_lizard/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.tails_list_lizard.Find(target.dna.features[feature_key]), length(SSaccessories.tails_list_lizard))

/datum/dna_block/feature/tail_fish
	feature_key = FEATURE_TAIL_FISH

/datum/dna_block/feature/tail_fish/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.tails_list_fish.Find(target.dna.features[feature_key]), length(SSaccessories.tails_list_fish))

/datum/dna_block/feature/snout
	feature_key = FEATURE_SNOUT

/datum/dna_block/feature/snout/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.snouts_list.Find(target.dna.features[feature_key]), length(SSaccessories.snouts_list))

/datum/dna_block/feature/lizard_marking
	feature_key = FEATURE_LIZARD_MARKINGS

/datum/dna_block/feature/lizard_marking/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.lizard_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.lizard_markings_list))

/datum/dna_block/feature/horn
	feature_key = FEATURE_HORNS

/datum/dna_block/feature/horn/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.horns_list.Find(target.dna.features[feature_key]), length(SSaccessories.horns_list))

/datum/dna_block/feature/frill
	feature_key = FEATURE_FRILLS

/datum/dna_block/feature/frill/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.frills_list.Find(target.dna.features[feature_key]), length(SSaccessories.frills_list))

/datum/dna_block/feature/spine
	feature_key = FEATURE_SPINES

/datum/dna_block/feature/spine/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.spines_list.Find(target.dna.features[feature_key]), length(SSaccessories.spines_list))

/datum/dna_block/feature/moth_wing
	feature_key = FEATURE_MOTH_WINGS

/datum/dna_block/feature/moth_wing/unique_block(mob/living/carbon/human/target)
	. = ..()
	if(target.dna.features[feature_key] != "Burnt Off") // Why is this snowflake check a thing. Please find a way to fix this later
		return get_block(target.dna.features)
	return construct_block(SSaccessories.moth_wings_list.Find(target.dna.features[feature_key]), length(SSaccessories.moth_wings_list))

/datum/dna_block/feature/moth_antenna
	feature_key = FEATURE_MOTH_ANTENNAE

/datum/dna_block/feature/moth_antenna/unique_block(mob/living/carbon/human/target)
	. = ..()
	if(target.dna.features[feature_key] != "Burnt Off")
		return get_block(target.dna.features)
	return construct_block(SSaccessories.moth_antennae_list.Find(target.dna.features[feature_key]), length(SSaccessories.moth_antennae_list))

/datum/dna_block/feature/moth_marking
	feature_key = FEATURE_MOTH_MARKINGS

/datum/dna_block/feature/moth_marking/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.moth_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.moth_markings_list))

/datum/dna_block/feature/mush_cap
	feature_key = FEATURE_MUSH_CAP

/datum/dna_block/feature/mush_cap/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.caps_list.Find(target.dna.features[feature_key]), length(SSaccessories.caps_list))

/datum/dna_block/feature/pod_hair
	feature_key = FEATURE_POD_HAIR

/datum/dna_block/feature/pod_hair/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.pod_hair_list.Find(target.dna.features[feature_key]), length(SSaccessories.pod_hair_list))
