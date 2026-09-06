GLOBAL_LIST_INIT(cerulean_respiration_variation, list(
	"Oxygen" = /obj/item/organ/lungs, // i know fish also breathe oxygen
	"Water vapor" = /obj/item/organ/lungs/fish, // but this gets the idea across better
	))

/// Whether or not a Cerulean has air-breathing lungs or water-breathing gills
/datum/preference/choiced/cerulean_lungs
	savefile_key = "feature_cerulean_respiration"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_SPECIES
	randomize_by_default = FALSE

/datum/preference/choiced/cerulean_lungs/has_relevant_feature(datum/preferences/preferences)
	return current_species_has_savekey(preferences)

/datum/preference/choiced/cerulean_lungs/apply_to_human(mob/living/carbon/human/target, value)
	if(iscerulean(target))
		target.dna.species.mutantlungs = GLOB.cerulean_respiration_variation[value]
	target.dna.species.regenerate_organs(target, GLOB.species_prototypes[target.dna.species.type], FALSE, (GLOB.all_body_zones - BODY_ZONE_CHEST))

/datum/preference/choiced/cerulean_lungs/init_possible_values()
	return GLOB.cerulean_respiration_variation

/datum/preference/choiced/cerulean_lungs/create_default_value()
	return "Oxygen"

/// The color given to people with a fish tail, the selection is exclusive to Ceruleans
/datum/preference/color/fish_tail_color
	savefile_key = "feature_fish_tail_color"
	relevant_organ = /obj/item/organ/tail/fish
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/fish_tail_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAIL_FISH_COLOR] = value

/datum/preference/color/fish_tail_color/create_default_value()
	return pick(GLOB.carp_colors - COLOR_CARP_SILVER)

/// cerulean frills. not a choice like lizard frills. just a toggle for yes or no, the accessory is aquatic
/datum/preference/toggle/cerulean_frills
	savefile_key = "feature_cerulean_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_SPECIES
	randomize_by_default = FALSE
	default_value = TRUE

/datum/preference/toggle/cerulean_frills/has_relevant_feature(datum/preferences/preferences)
	return current_species_has_savekey(preferences)

/datum/preference/toggle/cerulean_frills/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(iscerulean(target) && value)
		target.dna.features[FEATURE_FRILLS] = /datum/sprite_accessory/frills/aquatic::name
		target.dna.species.mutant_organs[/obj/item/organ/frills] = /datum/sprite_accessory/frills/aquatic::name
	target.dna.species.regenerate_organs(target, GLOB.species_prototypes[target.dna.species.type], FALSE, (GLOB.all_body_zones - BODY_ZONE_HEAD))
