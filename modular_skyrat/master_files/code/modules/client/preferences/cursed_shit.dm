// 200 dollars is 200 dollars :(

/datum/preference/toggle/penis
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "penis_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "penis"

/datum/preference/toggle/penis/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/penis/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/erp_allowed = preferences.read_preference(/datum/preference/toggle/master_erp_preferences)
	return erp_allowed && (passed_initial_check || allowed)

/datum/preference/choiced/penis
	savefile_key = "feature_penis"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "penis"

/datum/preference/choiced/penis/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/penis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/penis/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["penis"])

/datum/preference/choiced/penis/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["penis"])
		target.dna.mutant_bodyparts["penis"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["penis"]["name"] = value

/datum/preference/choiced/penis/create_default_value()
	var/datum/sprite_accessory/genital/penis/none/default = /datum/sprite_accessory/genital/penis/none
	return initial(default.name)

/datum/preference/numeric/penis_length
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "penis_length"
	relevant_mutant_bodypart = "penis"
	minimum = PENIS_MIN_LENGTH
	maximum = PENIS_MAX_LENGTH

/datum/preference/numeric/penis_length/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/penis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/numeric/penis_length/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["penis_size"] = value

/datum/preference/numeric/penis_length/create_default_value() // if you change from this to PENIS_MAX_LENGTH the game should laugh at you
	return round((PENIS_MIN_LENGTH + PENIS_MAX_LENGTH) / 2)

/datum/preference/numeric/penis_girth
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "penis_girth"
	relevant_mutant_bodypart = "penis"
	minimum = PENIS_MIN_LENGTH
	maximum = PENIS_MAX_GIRTH

/datum/preference/numeric/penis_girth/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/penis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/numeric/penis_girth/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["penis_girth"] = value

/datum/preference/numeric/penis_girth/create_default_value()
	return round((PENIS_MIN_LENGTH + PENIS_MAX_GIRTH) / 2)

/datum/preference/tri_color/penis
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "penis_color"
	relevant_mutant_bodypart = "penis"

/datum/preference/tri_color/penis/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/penis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/penis/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["penis"])
		target.dna.mutant_bodyparts["penis"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["penis"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/datum/preference/toggle/penis_taur_mode
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "penis_taur_mode_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "penis"

/datum/preference/toggle/penis_taur_mode/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["penis_taur"] = value

/datum/preference/toggle/penis_taur_mode/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/penis)
	return part_enabled && (passed_initial_check || allowed)

/datum/preference/choiced/penis_sheath
	savefile_key = "penis_sheath"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "penis"

/datum/preference/choiced/penis_sheath/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/penis)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/penis_sheath/init_possible_values()
	return SHEATH_MODES

/datum/preference/choiced/penis_sheath/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["penis_sheath"] = value

/datum/preference/choiced/penis_sheath/create_default_value()
	return SHEATH_NONE

/datum/preference/toggle/testicles
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "testicles_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "testicles"

/datum/preference/toggle/testicles/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/testicles/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/erp_allowed = preferences.read_preference(/datum/preference/toggle/master_erp_preferences)
	return erp_allowed && (passed_initial_check || allowed)

/datum/preference/choiced/testicles
	savefile_key = "feature_testicles"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "testicles"

/datum/preference/choiced/testicles/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/testicles)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/testicles/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["testicles"])

/datum/preference/choiced/testicles/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["testicles"])
		target.dna.mutant_bodyparts["testicles"] = list("name" = "None", "color" = "#FFFFFF")
	target.dna.mutant_bodyparts["testicles"]["name"] = value

/datum/preference/choiced/testicles/create_default_value()
	var/datum/sprite_accessory/genital/testicles/none/default = /datum/sprite_accessory/genital/testicles/none
	return initial(default.name)

/datum/preference/tri_color/testicles
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "testicles_color"
	relevant_mutant_bodypart = "testicles"

/datum/preference/tri_color/testicles/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/testicles)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/testicles/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["testicles"])
		target.dna.mutant_bodyparts["testicles"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["testicles"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/datum/preference/numeric/balls_size
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "balls_size"
	relevant_mutant_bodypart = "testicles"
	minimum = 0
	maximum = 3

/datum/preference/numeric/balls_size/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/testicles)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/numeric/balls_size/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["balls_size"] = value

/datum/preference/numeric/balls_size/create_default_value()
	return 2

/datum/preference/toggle/vagina
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "vagina_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "vagina"

/datum/preference/toggle/vagina/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/vagina/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/erp_allowed = preferences.read_preference(/datum/preference/toggle/master_erp_preferences)
	return erp_allowed && (passed_initial_check || allowed)

/datum/preference/choiced/vagina
	savefile_key = "feature_vagina"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "vagina"

/datum/preference/choiced/vagina/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/vagina)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/vagina/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["vagina"])

/datum/preference/choiced/vagina/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["vagina"])
		target.dna.mutant_bodyparts["vagina"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["vagina"]["name"] = value

/datum/preference/choiced/vagina/create_default_value()
	var/datum/sprite_accessory/genital/vagina/none/default = /datum/sprite_accessory/genital/vagina/none
	return initial(default.name)

/datum/preference/tri_color/vagina
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "vagina_color"
	relevant_mutant_bodypart = "vagina"

/datum/preference/tri_color/vagina/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/vagina)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/vagina/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["vagina"])
		target.dna.mutant_bodyparts["vagina"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["vagina"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/datum/preference/toggle/womb
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "womb_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "womb"

/datum/preference/toggle/womb/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/womb/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/erp_allowed = preferences.read_preference(/datum/preference/toggle/master_erp_preferences)
	return erp_allowed && (passed_initial_check || allowed)

/datum/preference/choiced/womb
	savefile_key = "feature_womb"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "womb"

/datum/preference/choiced/womb/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/womb)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/womb/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["womb"])

/datum/preference/choiced/womb/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["womb"])
		target.dna.mutant_bodyparts["womb"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["womb"]["name"] = value

/datum/preference/choiced/womb/create_default_value()
	var/datum/sprite_accessory/genital/womb/none/default = /datum/sprite_accessory/genital/womb/none
	return initial(default.name)

/datum/preference/toggle/breasts
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "breasts_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "breasts"

/datum/preference/toggle/breasts/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/breasts/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/erp_allowed = preferences.read_preference(/datum/preference/toggle/master_erp_preferences)
	return erp_allowed && (passed_initial_check || allowed)

/datum/preference/choiced/breasts
	savefile_key = "feature_breasts"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "breasts"

/datum/preference/choiced/breasts/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/breasts)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/breasts/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["breasts"])

/datum/preference/choiced/breasts/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["breasts"])
		target.dna.mutant_bodyparts["breasts"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["breasts"]["name"] = value

/datum/preference/choiced/breasts/create_default_value()
	var/datum/sprite_accessory/genital/breasts/none/default = /datum/sprite_accessory/genital/breasts/none
	return initial(default.name)

/datum/preference/tri_color/breasts
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "breasts_color"
	relevant_mutant_bodypart = "breasts"

/datum/preference/tri_color/breasts/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/breasts)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/tri_color/breasts/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["breasts"])
		target.dna.mutant_bodyparts["breasts"] = list("name" = "None", "color" = list("#FFFFFF", "#FFFFFF", "#FFFFFF"))
	target.dna.mutant_bodyparts["breasts"]["color"] = list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))

/datum/preference/toggle/breasts_lactation
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "breasts_lactation_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "breasts"

/datum/preference/toggle/breasts_lactation/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["breasts_lactation"] = value

/datum/preference/toggle/breasts_lactation/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/breasts)
	return part_enabled && (passed_initial_check || allowed)

/datum/preference/numeric/breasts_size
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "breasts_size"
	relevant_mutant_bodypart = "breasts"
	minimum = 0
	maximum = 16

/datum/preference/numeric/breasts_size/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/breasts)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/numeric/breasts_size/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["breasts_size"] = value

/datum/preference/numeric/breasts_size/create_default_value()
	return 4

/datum/preference/numeric/body_size
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "body_size"
	minimum = BODY_SIZE_MIN
	maximum = BODY_SIZE_MAX
	step = 0.01

/datum/preference/numeric/body_size/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	return passed_initial_check

/datum/preference/numeric/body_size/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["body_size"] = value

/datum/preference/numeric/body_size/create_default_value()
	return BODY_SIZE_NORMAL

/datum/preference/toggle/anus
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "anus_toggle"
	default_value = FALSE
	relevant_mutant_bodypart = "anus"

/datum/preference/toggle/anus/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE // we dont actually want this to do anything

/datum/preference/toggle/anus/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/erp_allowed = preferences.read_preference(/datum/preference/toggle/master_erp_preferences)
	return erp_allowed && (passed_initial_check || allowed)

/datum/preference/choiced/anus
	savefile_key = "feature_anus"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "anus"

/datum/preference/choiced/anus/is_accessible(datum/preferences/preferences)
	var/passed_initial_check = ..(preferences)
	var/allowed = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)
	var/part_enabled = preferences.read_preference(/datum/preference/toggle/anus)
	return ((passed_initial_check || allowed) && part_enabled)

/datum/preference/choiced/anus/init_possible_values()
	return assoc_to_keys(GLOB.sprite_accessories["anus"])

/datum/preference/choiced/anus/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.mutant_bodyparts["anus"])
		target.dna.mutant_bodyparts["anus"] = list("name" = "None", "color" = list("FFF", "FFF", "FFF"))
	target.dna.mutant_bodyparts["anus"]["name"] = value

/datum/preference/choiced/anus/create_default_value()
	var/datum/sprite_accessory/genital/anus/none/default = /datum/sprite_accessory/genital/anus/none
	return initial(default.name)

