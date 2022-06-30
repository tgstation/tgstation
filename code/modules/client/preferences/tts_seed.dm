/datum/preference/choiced/tts_seed
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_seed"
	priority = PREFERENCE_PRIORITY_SPECIES + 1

/datum/preference/choiced/tts_seed/deserialize(input, datum/preferences/preferences)
	//if you figure out how to enter whatever you want than honestly take it idc seeds support that
	return ..(input, preferences)

/datum/preference/choiced/tts_seed/init_possible_values()
	return GLOB.tts_seeds_prefs

/datum/preference/choiced/tts_seed/apply_to_human(mob/living/carbon/human/target, value)
	var/obj/item/organ/internal/tongue/tts_speaker = target.getorganslot(ORGAN_SLOT_TONGUE)
	if(!tts_speaker)
		log_admin("didn't apply tts seed to tongue")
		return
	tts_speaker.tts_seed = value

/datum/preference/choiced/tts_seed/create_default_value()
	return pick(GLOB.tts_seeds_prefs)

/datum/preference/choiced/tts_seed/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return TRUE
