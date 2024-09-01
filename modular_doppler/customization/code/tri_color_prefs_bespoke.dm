/// Fluff colors!
/datum/preference/tri_color/fluff_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "fluff_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	// TODO: we need fluff organs & selection
	//relevant_external_organ = /obj/item/organ/external/fluff

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
/*/datum/preference/choiced/moth_fluff/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/fluff_color::savefile_key

	return data*/



/// Synth antenna colors!
/datum/preference/tri_color/ipc_antenna_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "ipc_antenna_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	// TODO: we need fluff organs & selection
	//relevant_external_organ = /obj/item/organ/external/fluff

/datum/preference/tri_color/ipc_antenna_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/ipc_antenna_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna_color_1"] = value[1]
	target.dna.features["ipc_antenna_color_2"] = value[2]
	target.dna.features["ipc_antenna_color_3"] = value[3]

/datum/preference/tri_color/ipc_antenna_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
// TODO: we need fluff organs & selection
/*/datum/preference/choiced/moth_fluff/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ipc_antenna_color::savefile_key

	return data*/



/// Taur body colors!
/datum/preference/tri_color/taur_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "taur_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	// TODO: we need fluff organs & selection
	//relevant_external_organ = /obj/item/organ/external/fluff

/datum/preference/tri_color/taur_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/taur_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["taur_color_1"] = value[1]
	target.dna.features["taur_color_2"] = value[2]
	target.dna.features["taur_color_3"] = value[3]

/datum/preference/tri_color/taur_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
// TODO: we need fluff organs & selection
/*/datum/preference/choiced/moth_fluff/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/taur_color::savefile_key

	return data*/



/// Xenomorph dorsal fin colors!
/datum/preference/tri_color/xenodorsal_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "xenodorsal_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	// TODO: we need fluff organs & selection
	//relevant_external_organ = /obj/item/organ/external/fluff

/datum/preference/tri_color/xenodorsal_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/xenodorsal_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["xenodorsal_color_1"] = value[1]
	target.dna.features["xenodorsal_color_2"] = value[2]
	target.dna.features["xenodorsal_color_3"] = value[3]

/datum/preference/tri_color/xenodorsal_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
// TODO: we need fluff organs & selection
/*/datum/preference/choiced/moth_fluff/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/xenodorsal_color::savefile_key

	return data*/



/// Xenomorph head colors!
/datum/preference/tri_color/xenohead_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "xenohead_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	// TODO: we need fluff organs & selection
	//relevant_external_organ = /obj/item/organ/external/fluff

/datum/preference/tri_color/xenohead_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/xenohead_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["xenohead_color_1"] = value[1]
	target.dna.features["xenohead_color_2"] = value[2]
	target.dna.features["xenohead_color_3"] = value[3]

/datum/preference/tri_color/xenohead_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
// TODO: we need fluff organs & selection
/*/datum/preference/choiced/moth_fluff/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/xenohead_color::savefile_key

	return data*/
