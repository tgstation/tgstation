/datum/record
	/// Character's chronological age.
	var/age_chronological

/datum/record/crew
	/// Self-written past general records.
	var/past_general_records
	/// Self-written past medical records.
	var/past_medical_records
	/// Self-written past security records.
	var/past_security_records
	/// Self-written exploitables/vulnerable information intended for antagonists to make use of.
	var/exploitable_records

/// PREFERENCES

/datum/preference/numeric/age
	category = PREFERENCE_CATEGORY_DOPPLER_LORE // moves age to our funny lore page, needs manual inclusion on LorePage.tsx though

/datum/preference/numeric/chronological_age
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "age_chronological"
	minimum = 18
	maximum = 999

/datum/preference/numeric/chronological_age/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["age_chronological"] = value
	target.age_chronological = value

/datum/preference/numeric/chronological_age/create_informed_default_value(datum/preferences/preferences)
	return preferences.read_preference(/datum/preference/numeric/age)

/datum/preference/text/past_general_records
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "past_general_records"
	maximum_value_length = 4096

/datum/preference/text/past_general_records/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/past_medical_records
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "past_medical_records"
	maximum_value_length = 4096

/datum/preference/text/past_medical_records/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/past_security_records
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "past_security_records"
	maximum_value_length = 4096

/datum/preference/text/past_security_records/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/exploitable_records
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "exploitable_records"
	maximum_value_length = 4096

/datum/preference/text/exploitable_records/apply_to_human(mob/living/carbon/human/target, value)
	// lazy lazy LAZY LAZY
	target.dna.features["exploitables"] = value
	return

/datum/preference/text/ooc_notes
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ooc_notes"
	maximum_value_length = 4096

/datum/preference/text/ooc_notes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ooc_notes"] = value
