// Gotta add to the selector
/datum/preference/choiced/lizard_horns/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/horns_color::savefile_key
	return data

/// Horn colors!
/datum/preference/tri_color/horns_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "horns_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	//relevant_external_organ = /obj/item/organ/horns

/datum/preference/tri_color/horns_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/horns_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns_color_1"] = value[1]
	target.dna.features["horns_color_2"] = value[2]
	target.dna.features["horns_color_3"] = value[3]

/datum/preference/tri_color/horns_color/is_valid(value)
	if (!..(value))
		return FALSE
	return TRUE
