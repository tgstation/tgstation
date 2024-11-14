// Gotta add to the ears selector
/datum/preference/choiced/felinid_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/lizard_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/dog_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/fox_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/bunny_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/mouse_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/bird_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/monkey_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/deer_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/fish_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/bug_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/humanoid_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/synthetic_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data

/datum/preference/choiced/alien_ears/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key
	return data


/// Ears colors!
/datum/preference/tri_color/ears_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "ears_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES

/datum/preference/tri_color/ears_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/ears_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears_color_1"] = value[1]
	target.dna.features["ears_color_2"] = value[2]
	target.dna.features["ears_color_3"] = value[3]

/datum/preference/tri_color/ears_color/is_valid(value)
	if (!..(value))
		return FALSE
	return TRUE
