/// Fluff colors!
/datum/preference/tri_color/fluff_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "fluff_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	// TODO: we need fluff organs & selection
	//relevant_external_organ = /obj/item/organ/fluff

/datum/preference/tri_color/fluff_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/fluff_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["fluff_color_1"] = value[1]
	target.dna.features["fluff_color_2"] = value[2]
	target.dna.features["fluff_color_3"] = value[3]

/datum/preference/tri_color/fluff_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
// TODO: we need fluff organs & selection
/datum/preference/choiced/fluff/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/fluff_color::savefile_key
	return data
