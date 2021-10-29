/datum/preference/text/flavor_text
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "flavor_text"

/datum/preference/text/flavor_text/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["flavor_text"] = value

/datum/preference/text/silicon_flavor_text
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_flavor_text"
	// This does not get a apply_to_human proc, this is read directly in silicon/robot/examine.dm

/datum/preference/text/silicon_flavor_text/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE // To prevent the not-implemented runtime

/datum/preference/text/ooc_notes
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ooc_notes"

/datum/preference/text/ooc_notes/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["ooc_notes"] = value

/datum/preference/text/custom_species
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "custom_species"

/datum/preference/text/custom_species/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["custom_species"] = value

/datum/preference/text/custom_species_lore
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "custom_species_lore"

/datum/preference/text/custom_species_lore/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["custom_species_lore"] = value
