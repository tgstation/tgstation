// anteater features

/datum/dna_block/feature/tail_anteater
	feature_key = FEATURE_ANTEATER_TAIL

/datum/dna_block/feature/tail_anteater/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.tails_list_anteater.Find(target.dna.features[feature_key]), length(SSaccessories.tails_list_anteater))

/datum/dna_block/feature/tail_anteater/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.tails_list_anteater[deconstruct_block(get_block(dna_hash), length(SSaccessories.tails_list_anteater))]

/datum/dna_block/feature/anteater_snout
	feature_key = FEATURE_ANTEATER_SNOUT

/datum/dna_block/feature/anteater_snout/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.anteater_snouts_list.Find(target.dna.features[feature_key]), length(SSaccessories.anteater_snouts_list))

/datum/dna_block/feature/anteater_snout/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.anteater_snouts_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.anteater_snouts_list))]

/datum/dna_block/feature/anteater_marking
	feature_key = FEATURE_ANTEATER_MARKINGS

/datum/dna_block/feature/anteater_marking/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.anteater_markings_list.Find(target.dna.features[feature_key]), length(SSaccessories.anteater_markings_list))

/datum/dna_block/feature/anteater_marking/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.anteater_markings_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.anteater_markings_list))]
