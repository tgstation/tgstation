/datum/dna_block/feature/mutant_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/feature/mutant_color/unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.dna.features[/datum/dna_block/feature/mutant_color], include_crunch = FALSE)

/datum/dna_block/feature/ethereal_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/feature/ethereal_color/unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.dna.features[/datum/dna_block/feature/ethereal_color], include_crunch = FALSE)

// One day, someone should consider merging all tails into one, this is stupid
// No I don't care that it will "Create situations where a felinid grows a lizard tail" that makes it more fun
/datum/dna_block/feature/tail

/datum/dna_block/feature/tail/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.tails_list_felinid.Find(target.dna.features[/datum/dna_block/feature/tail]), length(SSaccessories.tails_list_felinid))

/datum/dna_block/feature/tail_lizard

/datum/dna_block/feature/tail_lizard/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.tails_list_lizard.Find(target.dna.features[/datum/dna_block/feature/tail_lizard]), length(SSaccessories.tails_list_lizard))

/datum/dna_block/feature/tail_fish

/datum/dna_block/feature/tail_fish/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.tails_list_fish.Find(target.dna.features[/datum/dna_block/feature/tail_fish]), length(SSaccessories.tails_list_fish))

/datum/dna_block/feature/snout

/datum/dna_block/feature/snout/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.snouts_list.Find(target.dna.features[/datum/dna_block/feature/snout]), length(SSaccessories.snouts_list))

/datum/dna_block/feature/lizard_marking

/datum/dna_block/feature/lizard_marking/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.lizard_markings_list.Find(target.dna.features[/datum/dna_block/feature/lizard_marking]), length(SSaccessories.lizard_markings_list))

/datum/dna_block/feature/horn

/datum/dna_block/feature/horn/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.horns_list.Find(target.dna.features[/datum/dna_block/feature/horn]), length(SSaccessories.horns_list))

/datum/dna_block/feature/frill

/datum/dna_block/feature/frill/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.frills_list.Find(target.dna.features[/datum/dna_block/feature/frill]), length(SSaccessories.frills_list))

/datum/dna_block/feature/spine

/datum/dna_block/feature/spine/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.spines_list.Find(target.dna.features[/datum/dna_block/feature/spine]), length(SSaccessories.spines_list))

/datum/dna_block/feature/ears

/datum/dna_block/feature/ears/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.ears_list.Find(target.dna.features[/datum/dna_block/feature/ears]), length(SSaccessories.ears_list))

/datum/dna_block/feature/moth_wing

/datum/dna_block/feature/moth_wing/unique_block(mob/living/carbon/human/target)
	. = ..()
	if(target.dna.features[/datum/dna_block/feature/moth_wing] != "Burnt Off") // Why is this a thing. Please fix this later
		return get_block(target.dna.feature_key)
	return construct_block(SSaccessories.moth_wings_list.Find(target.dna.features[/datum/dna_block/feature/moth_wing]), length(SSaccessories.moth_wings_list))

/datum/dna_block/feature/moth_antenna

/datum/dna_block/feature/moth_antenna/unique_block(mob/living/carbon/human/target)
	. = ..()
	if(target.dna.features[/datum/dna_block/feature/moth_antenna] != "Burnt Off")
		return get_block(target.dna.feature_key)
	return construct_block(SSaccessories.moth_antennae_list.Find(target.dna.features[/datum/dna_block/feature/moth_antenna]), length(SSaccessories.moth_antennae_list))

/datum/dna_block/feature/moth_marking

/datum/dna_block/feature/moth_marking/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.moth_markings_list.Find(target.dna.features[/datum/dna_block/feature/moth_marking]), length(SSaccessories.moth_markings_list))

/datum/dna_block/feature/mush_cap

/datum/dna_block/feature/mush_cap/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.caps_list.Find(target.dna.features[/datum/dna_block/feature/mush_cap]), length(SSaccessories.caps_list))

/datum/dna_block/feature/pod_hair

/datum/dna_block/feature/pod_hair/unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.pod_hair_list.Find(target.dna.features[/datum/dna_block/feature/pod_hair]), length(SSaccessories.pod_hair_list))
