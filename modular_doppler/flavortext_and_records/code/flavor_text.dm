/*
 "Short descs" are a brief one to three sentence written text block that describes the core, immediately-recognizable aspects of a given character. As a general rule

 Example:
 "Standing at roughly five foot ten in height, this grizzled male human sports a great array of old laser scars, poorly healed-over."
*/
/datum/preference/text/flavor_short_desc
	category = PREFERENCE_CATEGORY_DOPPLER_LORE // probably not appropriate, need to make a new lore category one
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "flavor_short_desc"
	maximum_value_length = MAX_FLAVOR_SHORT_DESC_LEN

/datum/preference/text/flavor_short_desc/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["flavor_short_desc"] = value // applying this to DNA for now, probably a better way to do it

/datum/preference/text/flavor_extended_desc
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "flavor_extended_desc"
	maximum_value_length = MAX_FLAVOR_EXTENDED_DESC_LEN

/datum/preference/text/flavor_extended_desc/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["flavor_extended_desc"] = value

/datum/preference/text/custom_species_name
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "custom_species_name"
	maximum_value_length = 128

/datum/preference/text/custom_species_name/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["custom_species_name"] = value

/datum/preference/text/custom_species_desc
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "custom_species_desc"
	maximum_value_length = 4096

/datum/preference/text/custom_species_desc/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["custom_species_desc"] = value

/*
	Silicon specific things
*/

/datum/preference/text/silicon_short_desc
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_flavor_short_desc"
	maximum_value_length = MAX_FLAVOR_SHORT_DESC_LEN

/datum/preference/text/silicon_short_desc/apply_to_human(mob/living/carbon/human/target, value)
	return // we handle this manually via pref lookups in appropriate procs

/datum/preference/text/silicon_extended_desc
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_flavor_extended_desc"
	maximum_value_length = MAX_FLAVOR_EXTENDED_DESC_LEN

/datum/preference/text/silicon_extended_desc/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/silicon_model_name
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_model_name"
	maximum_value_length = 128

/datum/preference/text/silicon_model_name/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/silicon_model_desc
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_model_desc"
	maximum_value_length = 4096

/datum/preference/text/silicon_model_desc/apply_to_human(mob/living/carbon/human/target, value)
	return
