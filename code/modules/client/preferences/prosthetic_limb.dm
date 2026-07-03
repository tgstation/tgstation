// // BANDASTATION REMOVAL START - Feat: Augmentations
// /datum/preference/choiced/prosthetic
// 	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
// 	savefile_key = "prosthetic"
// 	savefile_identifier = PREFERENCE_CHARACTER

// /datum/preference/choiced/prosthetic/create_default_value()
// 	return "Random"

// /datum/preference/choiced/prosthetic/init_possible_values()
// 	return list("Random") + GLOB.prosthetic_limb_choice

// /datum/preference/choiced/prosthetic/is_accessible(datum/preferences/preferences)
// 	. = ..()
// 	if (!.)
// 		return FALSE

// 	return "Prosthetic Limb" in preferences.all_quirks

// /datum/preference/choiced/prosthetic/apply_to_human(mob/living/carbon/human/target, value)
// 	return
// // BANDASTATION REMOVAL END - Feat: Augmentations
