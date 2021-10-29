/datum/preference/toggle/allow_mismatched_parts
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "allow_mismatched_parts_toggle"
	default_value = FALSE

/datum/preference/toggle/allow_mismatched_parts/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/tri_color/mutant_colors
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "mutant_colors_color"

/datum/preference/tri_color/mutant_colors/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["mcolor"] = sanitize_hexcolor(value[1])
	target.dna.features["mcolor2"] = sanitize_hexcolor(value[2])
	target.dna.features["mcolor3"] = sanitize_hexcolor(value[3])

/datum/preference/toggle/body_markings
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "body_markings_toggle"
	relevant_mutant_bodypart = "body_markings"
	default_value = FALSE

/datum/preference/toggle/body_markings/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/body_markings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/body_markings
	savefile_key = "feature_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "body_markings"

/datum/preference/choiced/body_markings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/body_markings)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/body_markings/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["body_markings"])

/datum/preference/choiced/body_markings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["body_markings"])
		target.dna.mutant_bodyparts["body_markings"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["body_markings"]["name"] = value

/datum/preference/choiced/body_markings/create_default_value()
	var/datum/sprite_accessory/body_markings/none/default = /datum/sprite_accessory/body_markings/none
	return initial(default.name)

/datum/preference/tri_color/body_markings
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "body_markings_color"
	relevant_mutant_bodypart = "body_markings"

/datum/preference/tri_color/body_markings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/body_markings)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/body_markings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["body_markings"])
		target.dna.mutant_bodyparts["body_markings"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["body_markings"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Tails

/datum/preference/toggle/tail
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tail_toggle"
	relevant_mutant_bodypart = "tail"
	default_value = FALSE

/datum/preference/toggle/tail/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/tail/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/tail
	savefile_key = "feature_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "tail"

/datum/preference/choiced/tail/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/tail)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/tail/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["tail"])

/datum/preference/choiced/tail/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["tail"])
		target.dna.mutant_bodyparts["tail"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["tail"]["name"] = value

/datum/preference/choiced/tail/create_default_value()
	var/datum/sprite_accessory/tails/none/default = /datum/sprite_accessory/tails/none
	return initial(default.name)

/datum/preference/tri_color/tail
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tail_color"
	relevant_mutant_bodypart = "tail"

/datum/preference/tri_color/tail/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/tail)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/tail/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["tail"])
		target.dna.mutant_bodyparts["tail"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["tail"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Snouts

/datum/preference/toggle/snout
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "snout_toggle"
	relevant_mutant_bodypart = "snout"
	default_value = FALSE

/datum/preference/toggle/snout/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/snout/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/snout
	savefile_key = "feature_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "snout"

/datum/preference/choiced/snout/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/snout)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/snout/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["snout"])

/datum/preference/choiced/snout/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["snout"])
		target.dna.mutant_bodyparts["snout"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["snout"]["name"] = value

/datum/preference/choiced/snout/create_default_value()
	var/datum/sprite_accessory/snouts/none/default = /datum/sprite_accessory/snouts/none
	return initial(default.name)

/datum/preference/tri_color/snout
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "snout_color"
	relevant_mutant_bodypart = "snout"

/datum/preference/tri_color/snout/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/snout)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/snout/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["snout"])
		target.dna.mutant_bodyparts["snout"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["snout"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Horns

/datum/preference/toggle/horns
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "horns_toggle"
	relevant_mutant_bodypart = "horns"
	default_value = FALSE

/datum/preference/toggle/horns/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/horns/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/horns
	savefile_key = "feature_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "horns"

/datum/preference/choiced/horns/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/horns)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/horns/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["horns"])

/datum/preference/choiced/horns/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["horns"])
		target.dna.mutant_bodyparts["horns"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["horns"]["name"] = value

/datum/preference/choiced/horns/create_default_value()
	var/datum/sprite_accessory/horns/none/default = /datum/sprite_accessory/horns/none
	return initial(default.name)

/datum/preference/tri_color/horns
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "horns_color"
	relevant_mutant_bodypart = "horns"

/datum/preference/tri_color/horns/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/horns)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/horns/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["horns"])
		target.dna.mutant_bodyparts["horns"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["horns"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Ears

/datum/preference/toggle/ears
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ears_toggle"
	relevant_mutant_bodypart = "ears"
	default_value = FALSE

/datum/preference/toggle/ears/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/ears/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/ears
	savefile_key = "feature_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "ears"

/datum/preference/choiced/ears/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ears)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/ears/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["ears"])

/datum/preference/choiced/ears/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ears"])
		target.dna.mutant_bodyparts["ears"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ears"]["name"] = value

/datum/preference/choiced/ears/create_default_value()
	var/datum/sprite_accessory/ears/none/default = /datum/sprite_accessory/ears/none
	return initial(default.name)

/datum/preference/tri_color/ears
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ears_color"
	relevant_mutant_bodypart = "ears"

/datum/preference/tri_color/ears/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ears)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/ears/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ears"])
		target.dna.mutant_bodyparts["ears"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ears"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Wings

/datum/preference/toggle/wings
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "wings_toggle"
	relevant_mutant_bodypart = "wings"
	default_value = FALSE

/datum/preference/toggle/wings/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/wings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/wings
	savefile_key = "feature_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "wings"

/datum/preference/choiced/wings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/wings)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/wings/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["wings"])

/datum/preference/choiced/wings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["wings"])
		target.dna.mutant_bodyparts["wings"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["wings"]["name"] = value

/datum/preference/choiced/wings/create_default_value()
	var/datum/sprite_accessory/wings/none/default = /datum/sprite_accessory/wings/none
	return initial(default.name)

/datum/preference/tri_color/wings
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "wings_color"
	relevant_mutant_bodypart = "wings"

/datum/preference/tri_color/wings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/wings)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/wings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["wings"])
		target.dna.mutant_bodyparts["wings"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["wings"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Frills

/datum/preference/toggle/frills
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "frills_toggle"
	relevant_mutant_bodypart = "frills"
	default_value = FALSE

/datum/preference/toggle/frills/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/frills/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/frills
	savefile_key = "feature_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "frills"

/datum/preference/choiced/frills/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/frills)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/frills/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["frills"])

/datum/preference/choiced/frills/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["frills"])
		target.dna.mutant_bodyparts["frills"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["frills"]["name"] = value

/datum/preference/choiced/frills/create_default_value()
	var/datum/sprite_accessory/frills/none/default = /datum/sprite_accessory/frills/none
	return initial(default.name)

/datum/preference/tri_color/frills
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "frills_color"
	relevant_mutant_bodypart = "frills"

/datum/preference/tri_color/frills/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/frills)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/frills/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["frills"])
		target.dna.mutant_bodyparts["frills"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["frills"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Spines

/datum/preference/toggle/spines
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "spines_toggle"
	relevant_mutant_bodypart = "spines"
	default_value = FALSE

/datum/preference/toggle/spines/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/spines/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/spines
	savefile_key = "feature_spines"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "spines"

/datum/preference/choiced/spines/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/spines)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/spines/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["spines"])

/datum/preference/choiced/spines/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["spines"])
		target.dna.mutant_bodyparts["spines"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["spines"]["name"] = value

/datum/preference/choiced/spines/create_default_value()
	var/datum/sprite_accessory/spines/none/default = /datum/sprite_accessory/spines/none
	return initial(default.name)

/datum/preference/tri_color/spines
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "spines_color"
	relevant_mutant_bodypart = "spines"

/datum/preference/tri_color/spines/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/spines)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/spines/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["spines"])
		target.dna.mutant_bodyparts["spines"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["spines"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Legs

/datum/preference/toggle/legs
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "legs_toggle"
	relevant_mutant_bodypart = "legs"
	default_value = FALSE

/datum/preference/toggle/legs/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/legs/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/legs
	savefile_key = "feature_legs"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "legs"

/datum/preference/choiced/legs/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/legs)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/legs/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["legs"])

/datum/preference/choiced/legs/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["legs"])
		target.dna.mutant_bodyparts["legs"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["legs"]["name"] = value

/datum/preference/choiced/legs/create_default_value()
	var/datum/sprite_accessory/legs/none/default = /datum/sprite_accessory/legs/none
	return initial(default.name)

/datum/preference/tri_color/legs
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "legs_color"
	relevant_mutant_bodypart = "legs"

/datum/preference/tri_color/legs/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/legs)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/legs/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["legs"])
		target.dna.mutant_bodyparts["legs"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["legs"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Caps

/datum/preference/toggle/caps
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "caps_toggle"
	relevant_mutant_bodypart = "caps"
	default_value = FALSE

/datum/preference/toggle/caps/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/caps/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/caps
	savefile_key = "feature_caps"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "caps"

/datum/preference/choiced/caps/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/caps)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/caps/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["caps"])

/datum/preference/choiced/caps/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["caps"])
		target.dna.mutant_bodyparts["caps"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["caps"]["name"] = value

/datum/preference/choiced/caps/create_default_value()
	var/datum/sprite_accessory/caps/none/default = /datum/sprite_accessory/caps/none
	return initial(default.name)

/datum/preference/tri_color/caps
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "caps_color"
	relevant_mutant_bodypart = "caps"

/datum/preference/tri_color/caps/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/caps)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/caps/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["caps"])
		target.dna.mutant_bodyparts["caps"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["caps"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Moth Antennae

/datum/preference/toggle/moth_antennae
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "moth_antennae_toggle"
	relevant_mutant_bodypart = "moth_antennae"
	default_value = FALSE

/datum/preference/toggle/moth_antennae/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/moth_antennae/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/moth_antennae
	savefile_key = "feature_moth_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "moth_antennae"

/datum/preference/choiced/moth_antennae/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/moth_antennae)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/moth_antennae/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["moth_antennae"])

/datum/preference/choiced/moth_antennae/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["moth_antennae"])
		target.dna.mutant_bodyparts["moth_antennae"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["moth_antennae"]["name"] = value

/datum/preference/choiced/moth_antennae/create_default_value()
	var/datum/sprite_accessory/moth_antennae/none/default = /datum/sprite_accessory/moth_antennae/none
	return initial(default.name)

/datum/preference/tri_color/moth_antennae
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "moth_antennae_color"
	relevant_mutant_bodypart = "moth_antennae"

/datum/preference/tri_color/moth_antennae/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/moth_antennae)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/moth_antennae/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["moth_antennae"])
		target.dna.mutant_bodyparts["moth_antennae"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["moth_antennae"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Moth Markings

/datum/preference/toggle/moth_markings
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "moth_markings_toggle"
	relevant_mutant_bodypart = "moth_markings"
	default_value = FALSE

/datum/preference/toggle/moth_markings/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/moth_markings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/moth_markings
	savefile_key = "feature_moth_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "moth_markings"

/datum/preference/choiced/moth_markings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/moth_markings)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/moth_markings/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["moth_markings"])

/datum/preference/choiced/moth_markings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["moth_markings"])
		target.dna.mutant_bodyparts["moth_markings"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["moth_markings"]["name"] = value

/datum/preference/choiced/moth_markings/create_default_value()
	var/datum/sprite_accessory/moth_markings/none/default = /datum/sprite_accessory/moth_markings/none
	return initial(default.name)

/datum/preference/tri_color/moth_markings
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "moth_markings_color"
	relevant_mutant_bodypart = "moth_markings"

/datum/preference/tri_color/moth_markings/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/moth_markings)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/moth_markings/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["moth_markings"])
		target.dna.mutant_bodyparts["moth_markings"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["moth_markings"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Fluff

/datum/preference/toggle/fluff
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "fluff_toggle"
	relevant_mutant_bodypart = "fluff"
	default_value = FALSE

/datum/preference/toggle/fluff/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/fluff/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/fluff
	savefile_key = "feature_fluff"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "fluff"

/datum/preference/choiced/fluff/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/fluff)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/fluff/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["fluff"])

/datum/preference/choiced/fluff/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["fluff"])
		target.dna.mutant_bodyparts["fluff"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["fluff"]["name"] = value

/datum/preference/choiced/fluff/create_default_value()
	var/datum/sprite_accessory/fluff/moth/none/default = /datum/sprite_accessory/fluff/moth/none
	return initial(default.name)

/datum/preference/tri_color/fluff
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "fluff_color"
	relevant_mutant_bodypart = "fluff"

/datum/preference/tri_color/fluff/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/fluff)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/fluff/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["fluff"])
		target.dna.mutant_bodyparts["fluff"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["fluff"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Head Accessories

/datum/preference/toggle/head_acc
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "head_acc_toggle"
	relevant_mutant_bodypart = "head_acc"
	default_value = FALSE

/datum/preference/toggle/head_acc/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/head_acc/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/head_acc
	savefile_key = "feature_head_acc"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "head_acc"

/datum/preference/choiced/head_acc/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/head_acc)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/head_acc/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["head_acc"])

/datum/preference/choiced/head_acc/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["head_acc"])
		target.dna.mutant_bodyparts["head_acc"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["head_acc"]["name"] = value

/datum/preference/choiced/head_acc/create_default_value()
	var/datum/sprite_accessory/head_accessory/none/default = /datum/sprite_accessory/head_accessory/none
	return initial(default.name)

/datum/preference/tri_color/head_acc
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "head_acc_color"
	relevant_mutant_bodypart = "head_acc"

/datum/preference/tri_color/head_acc/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/head_acc)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/head_acc/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["head_acc"])
		target.dna.mutant_bodyparts["head_acc"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["head_acc"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// IPC Screens

/datum/preference/toggle/ipc_screen
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ipc_screen_toggle"
	relevant_mutant_bodypart = "ipc_screen"
	default_value = FALSE

/datum/preference/toggle/ipc_screen/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/ipc_screen/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/ipc_screen
	savefile_key = "feature_ipc_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "ipc_screen"

/datum/preference/choiced/ipc_screen/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ipc_screen)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/ipc_screen/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["ipc_screen"])

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ipc_screen"])
		target.dna.mutant_bodyparts["ipc_screen"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ipc_screen"]["name"] = value

/datum/preference/choiced/ipc_screen/create_default_value()
	var/datum/sprite_accessory/screen/none/default = /datum/sprite_accessory/screen/none
	return initial(default.name)

/datum/preference/tri_color/ipc_screen
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ipc_screen_color"
	relevant_mutant_bodypart = "ipc_screen"

/datum/preference/tri_color/ipc_screen/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ipc_screen)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ipc_screen"])
		target.dna.mutant_bodyparts["ipc_screen"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ipc_screen"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// IPC Antennas

/datum/preference/toggle/ipc_antenna
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ipc_antenna_toggle"
	relevant_mutant_bodypart = "ipc_antenna"
	default_value = FALSE

/datum/preference/toggle/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/ipc_antenna/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/ipc_antenna
	savefile_key = "feature_ipc_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "ipc_antenna"

/datum/preference/choiced/ipc_antenna/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ipc_antenna)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/ipc_antenna/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["ipc_antenna"])

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ipc_antenna"])
		target.dna.mutant_bodyparts["ipc_antenna"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ipc_antenna"]["name"] = value

/datum/preference/choiced/ipc_antenna/create_default_value()
	var/datum/sprite_accessory/antenna/none/default = /datum/sprite_accessory/antenna/none
	return initial(default.name)

/datum/preference/tri_color/ipc_antenna
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ipc_antenna_color"
	relevant_mutant_bodypart = "ipc_antenna"

/datum/preference/tri_color/ipc_antenna/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ipc_antenna)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ipc_antenna"])
		target.dna.mutant_bodyparts["ipc_antenna"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ipc_antenna"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// IPC Chassis

/datum/preference/toggle/ipc_chassis
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ipc_chassis_toggle"
	relevant_mutant_bodypart = "ipc_chassis"
	default_value = FALSE

/datum/preference/toggle/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/ipc_chassis/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/ipc_chassis
	savefile_key = "feature_ipc_chassis"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "ipc_chassis"

/datum/preference/choiced/ipc_chassis/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ipc_chassis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/ipc_chassis/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["ipc_chassis"])

/datum/preference/choiced/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ipc_chassis"])
		target.dna.mutant_bodyparts["ipc_chassis"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ipc_chassis"]["name"] = value

/datum/preference/choiced/ipc_chassis/create_default_value()
	var/datum/sprite_accessory/ipc_chassis/default = /datum/sprite_accessory/ipc_chassis/none
	return initial(default.name)

/datum/preference/tri_color/ipc_chassis
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "ipc_chassis_color"
	relevant_mutant_bodypart = "ipc_chassis"

/datum/preference/tri_color/ipc_chassis/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/ipc_chassis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["ipc_chassis"])
		target.dna.mutant_bodyparts["ipc_chassis"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["ipc_chassis"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Neck Accessories

/datum/preference/toggle/neck_acc
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "neck_acc_toggle"
	relevant_mutant_bodypart = "neck_acc"
	default_value = FALSE

/datum/preference/toggle/neck_acc/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/neck_acc/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/neck_acc
	savefile_key = "feature_neck_acc"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "neck_acc"

/datum/preference/choiced/neck_acc/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/neck_acc)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/neck_acc/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["neck_acc"])

/datum/preference/choiced/neck_acc/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["neck_acc"])
		target.dna.mutant_bodyparts["neck_acc"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["neck_acc"]["name"] = value

/datum/preference/choiced/neck_acc/create_default_value()
	var/datum/sprite_accessory/neck_accessory/none/default = /datum/sprite_accessory/neck_accessory/none
	return initial(default.name)

/datum/preference/tri_color/neck_acc
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "neck_acc_color"
	relevant_mutant_bodypart = "neck_acc"

/datum/preference/tri_color/neck_acc/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/neck_acc)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/neck_acc/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["neck_acc"])
		target.dna.mutant_bodyparts["neck_acc"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["neck_acc"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Skrell Hair

/datum/preference/toggle/skrell_hair
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "skrell_hair_toggle"
	relevant_mutant_bodypart = "skrell_hair"
	default_value = FALSE

/datum/preference/toggle/skrell_hair/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/skrell_hair/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/skrell_hair
	savefile_key = "feature_skrell_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "skrell_hair"

/datum/preference/choiced/skrell_hair/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/skrell_hair)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/skrell_hair/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["skrell_hair"])

/datum/preference/choiced/skrell_hair/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["skrell_hair"])
		target.dna.mutant_bodyparts["skrell_hair"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["skrell_hair"]["name"] = value

/datum/preference/choiced/skrell_hair/create_default_value()
	var/datum/sprite_accessory/skrell_hair/none/default = /datum/sprite_accessory/skrell_hair/none
	return initial(default.name)

/datum/preference/tri_color/skrell_hair
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "skrell_hair_color"
	relevant_mutant_bodypart = "skrell_hair"

/datum/preference/tri_color/skrell_hair/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/skrell_hair)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/skrell_hair/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["skrell_hair"])
		target.dna.mutant_bodyparts["skrell_hair"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["skrell_hair"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Taur

/datum/preference/toggle/taur
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "taur_toggle"
	relevant_mutant_bodypart = "taur"
	default_value = FALSE

/datum/preference/toggle/taur/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/taur/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/taur
	savefile_key = "feature_taur"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "taur"

/datum/preference/choiced/taur/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/taur)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/taur/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["taur"])

/datum/preference/choiced/taur/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["taur"])
		target.dna.mutant_bodyparts["taur"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["taur"]["name"] = value

/datum/preference/choiced/taur/create_default_value()
	var/datum/sprite_accessory/taur/none/default = /datum/sprite_accessory/taur/none
	return initial(default.name)

/datum/preference/tri_color/taur
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "taur_color"
	relevant_mutant_bodypart = "taur"

/datum/preference/tri_color/taur/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/taur)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/taur/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["taur"])
		target.dna.mutant_bodyparts["taur"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["taur"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Xenodorsal

/datum/preference/toggle/xenodorsal
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "xenodorsal_toggle"
	relevant_mutant_bodypart = "xenodorsal"
	default_value = FALSE

/datum/preference/toggle/xenodorsal/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/xenodorsal/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/xenodorsal
	savefile_key = "feature_xenodorsal"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "xenodorsal"

/datum/preference/choiced/xenodorsal/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/xenodorsal)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/xenodorsal/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["xenodorsal"])

/datum/preference/choiced/xenodorsal/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["xenodorsal"])
		target.dna.mutant_bodyparts["xenodorsal"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["xenodorsal"]["name"] = value

/datum/preference/choiced/xenodorsal/create_default_value()
	var/datum/sprite_accessory/xenodorsal/none/default = /datum/sprite_accessory/xenodorsal/none
	return initial(default.name)

/datum/preference/tri_color/xenodorsal
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "xenodorsal_color"
	relevant_mutant_bodypart = "xenodorsal"

/datum/preference/tri_color/xenodorsal/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/xenodorsal)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/xenodorsal/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["xenodorsal"])
		target.dna.mutant_bodyparts["xenodorsal"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["xenodorsal"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/// Xeno heads

/datum/preference/toggle/xenohead
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "xenohead_toggle"
	relevant_mutant_bodypart = "xenohead"
	default_value = FALSE

/datum/preference/toggle/xenohead/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/xenohead/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	return passed_initial_check || allowed

/datum/preference/choiced/xenohead
	savefile_key = "feature_xenohead"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "xenohead"

/datum/preference/choiced/xenohead/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/xenohead)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/xenohead/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["xenohead"])

/datum/preference/choiced/xenohead/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["xenohead"])
		target.dna.mutant_bodyparts["xenohead"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["xenohead"]["name"] = value

/datum/preference/choiced/xenohead/create_default_value()
	var/datum/sprite_accessory/xenohead/none/default = /datum/sprite_accessory/xenohead/none
	return initial(default.name)

/datum/preference/tri_color/xenohead
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "xenohead_color"
	relevant_mutant_bodypart = "xenohead"

/datum/preference/tri_color/xenohead/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/xenohead)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/xenohead/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["xenohead"])
		target.dna.mutant_bodyparts["xenohead"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["xenohead"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))
