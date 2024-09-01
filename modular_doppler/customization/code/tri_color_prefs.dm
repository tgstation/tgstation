/// Tricolor prefs
/datum/preference/tri_color
	abstract_type = /datum/preference/tri_color

/datum/preference/tri_color/deserialize(input, datum/preferences/preferences)
	var/list/input_colors = input
	return list(sanitize_hexcolor(input_colors[1]), sanitize_hexcolor(input_colors[2]), sanitize_hexcolor(input_colors[3]))

/datum/preference/tri_color/create_default_value()
	return list("#[random_color()]", "#[random_color()]", "#[random_color()]")

/datum/preference/tri_color/is_valid(list/value)
	return islist(value) && value.len == 3 && (findtext(value[1], GLOB.is_color) && findtext(value[2], GLOB.is_color) && findtext(value[3], GLOB.is_color))

/datum/preference/tri_color/is_accessible(datum/preferences/preferences)
	return ..()

// Hey, you!
// Wondering how to get the colors from a tri-col pref?
// Look no further: list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))
/datum/preference/tri_color/apply_to_human(mob/living/carbon/human/target, value)
	if (type == abstract_type)
		return ..()





/// Snoot colors!
/datum/preference/tri_color/snout_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "snout_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/snout

/datum/preference/tri_color/snout_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/snout_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout_color_1"] = value[1]
	target.dna.features["snout_color_2"] = value[2]
	target.dna.features["snout_color_3"] = value[3]

/datum/preference/tri_color/snout_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/lizard_snout/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/snout_color::savefile_key

	return data



/// Horn colors!
/datum/preference/tri_color/horns_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "horns_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/horns

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

// Gotta add to the selector too
/datum/preference/choiced/lizard_horns/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/horns_color::savefile_key

	return data



/// Frill colors!
/datum/preference/tri_color/frills_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "frills_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/frills

/datum/preference/tri_color/frills_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/frills_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills_color_1"] = value[1]
	target.dna.features["frills_color_2"] = value[2]
	target.dna.features["frills_color_3"] = value[3]

/datum/preference/tri_color/frills_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/lizard_frills/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/frills_color::savefile_key

	return data



/// Tail colors!
/datum/preference/tri_color/tail_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "tail_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail

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

// Gotta add to the selector too
/datum/preference/choiced/lizard_tail/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/tail_color::savefile_key

	return data



/// Ears colors!
/datum/preference/tri_color/ears_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "ears_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	//TODO: we might need to change this to a different organ type, it's hard to say
	relevant_external_organ = /obj/item/organ/internal/ears

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

// Gotta add to the snoot selector too
/datum/preference/choiced/ears/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/ears_color::savefile_key

	return data



/// Spines colors!
/datum/preference/tri_color/spines_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "spines_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/spines

/datum/preference/tri_color/spines_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/spines_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["spines_color_1"] = value[1]
	target.dna.features["spines_color_2"] = value[2]
	target.dna.features["spines_color_3"] = value[3]

/datum/preference/tri_color/spines_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/lizard_spines/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/spines_color::savefile_key

	return data



/// Caps colors!
/datum/preference/tri_color/caps_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "caps_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail

/datum/preference/tri_color/caps_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/caps_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["caps_color_1"] = value[1]
	target.dna.features["caps_color_2"] = value[2]
	target.dna.features["caps_color_3"] = value[3]

/datum/preference/tri_color/caps_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/mushroom_cap/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/caps_color::savefile_key

	return data



/// Moth marking colors!
/datum/preference/tri_color/moth_markings_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "moth_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/moth

/datum/preference/tri_color/moth_markings_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/moth_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_markings_color_1"] = value[1]
	target.dna.features["moth_markings_color_2"] = value[2]
	target.dna.features["moth_markings_color_3"] = value[3]

/datum/preference/tri_color/moth_markings_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/moth_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/moth_markings_color::savefile_key

	return data



/// Standard marking colors!
/datum/preference/tri_color/body_markings_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/lizard

/datum/preference/tri_color/body_markings_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["body_markings_color_1"] = value[1]
	target.dna.features["body_markings_color_2"] = value[2]
	target.dna.features["body_markings_color_3"] = value[3]

/datum/preference/tri_color/body_markings_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/lizard_body_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/body_markings_color::savefile_key

	return data



/// Wing colors!
/datum/preference/tri_color/wings_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "wings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/wings

/datum/preference/tri_color/wings_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/wings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["wings_color_1"] = value[1]
	target.dna.features["wings_color_2"] = value[2]
	target.dna.features["wings_color_3"] = value[3]

/datum/preference/tri_color/wings_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
// TODO: can we migrate off of moth_wings for this?
/datum/preference/choiced/moth_wings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/wings_color::savefile_key

	return data



/// Moth antennae colors!
/datum/preference/tri_color/moth_antennae_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "moth_antennae_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/wings

/datum/preference/tri_color/moth_antennae_color/create_default_value()
	return list(sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"),
	sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"))

/datum/preference/tri_color/moth_antennae_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_antennae_color_1"] = value[1]
	target.dna.features["moth_antennae_color_2"] = value[2]
	target.dna.features["moth_antennae_color_3"] = value[3]

/datum/preference/tri_color/moth_antennae_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE

// Gotta add to the selector too
/datum/preference/choiced/moth_wings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/tri_color/moth_antennae_color::savefile_key

	return data
