
// Add the selector to ALL THE TAILS!
/datum/preference/choiced/lizard_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/tail_felinid/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/monkey_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/dog_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/fox_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/bunny_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/mouse_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/bird_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/deer_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/fish_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/bug_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/synth_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/humanoid_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data

/datum/preference/choiced/alien_tail/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key
	return data


/// Tail colors!
/datum/preference/tri_color/tail_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "tail_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	//relevant_external_organ = /obj/item/organ/external/tail

/datum/preference/tri_color/tail_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/tail_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_color_1"] = value[1]
	target.dna.features["tail_color_2"] = value[2]
	target.dna.features["tail_color_3"] = value[3]

/datum/preference/tri_color/tail_color/is_valid(value)
	if (!..(value))
		return FALSE
	return TRUE
