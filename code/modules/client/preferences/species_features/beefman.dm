// Color
/datum/preference/choiced/beefman_color
	savefile_key = "feature_beef_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Beefman color"
	should_generate_icons = TRUE

/datum/preference/choiced/beefman_color/init_possible_values()
	var/list/values = list()

	var/icon/beefman_base = icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "beefman_head")
	beefman_base.Blend(icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "beefman_chest"), ICON_OVERLAY)
	beefman_base.Blend(icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "beefman_l_arm"), ICON_OVERLAY)
	beefman_base.Blend(icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "beefman_r_arm"), ICON_OVERLAY)

	var/icon/eyes = icon('icons/mob/species/human/human_face.dmi', "eyes")
	eyes.Blend(COLOR_BLACK, ICON_MULTIPLY)
	beefman_base.Blend(eyes, ICON_OVERLAY)

	beefman_base.Scale(64, 64)
	beefman_base.Crop(15, 64, 15 + 31, 64 - 31)

	for(var/name in GLOB.color_list_beefman)
		var/color = GLOB.color_list_beefman[name]

		var/icon/icon = new(beefman_base)
		icon.Blend("[color]", ICON_MULTIPLY)
		values[name] = icon

	return values

/datum/preference/choiced/beefman_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["beef_color"] = GLOB.color_list_beefman[value]

// Eyes
/datum/preference/choiced/beefman_eyes
	savefile_key = "feature_beef_eyes"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Beefman Eyes"
	should_generate_icons = TRUE

/datum/preference/choiced/beefman_eyes/init_possible_values()
	var/list/values = list()

	var/icon/beef_head = icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "beefman_head")
	beef_head.Blend("#d93356", ICON_MULTIPLY) // Make it red at least

	for(var/eye_name in GLOB.eyes_beefman)
		var/datum/sprite_accessory/eyes = GLOB.eyes_beefman[eye_name]

		var/icon/icon_with_eye = new(beef_head)
		icon_with_eye.Blend(icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "m_beef_eyes_[eyes.icon_state]_ADJ"), ICON_OVERLAY)
		icon_with_eye.Scale(64, 64)
		icon_with_eye.Crop(15, 64, 15 + 31, 64 - 31)

		values[eyes.name] = icon_with_eye

	return values

/datum/preference/choiced/beefman_eyes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["beef_eyes"] = value

// Mouth
/datum/preference/choiced/beefman_mouth
	savefile_key = "feature_beef_mouth"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Beefman Mouth"
	should_generate_icons = TRUE

/datum/preference/choiced/beefman_mouth/init_possible_values()
	var/list/values = list()

	var/icon/beef_head = icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "beefman_head")
	beef_head.Blend("#d93356", ICON_MULTIPLY) // Make it red at least

	for(var/mouth_name in GLOB.mouths_beefman)
		var/datum/sprite_accessory/mouths = GLOB.mouths_beefman[mouth_name]

		var/icon/icon_with_mouth = new(beef_head)
		icon_with_mouth.Blend(icon('icons/mob/species/beefman/beefman_bodyparts.dmi', "m_beef_mouth_[mouths.icon_state]_ADJ"), ICON_OVERLAY)
		icon_with_mouth.Scale(64, 64)
		icon_with_mouth.Crop(15, 64, 15 + 31, 64 - 31)

		values[mouths.name] = icon_with_mouth

	return values

/datum/preference/choiced/beefman_mouth/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["beef_mouth"] = value

//Trauma
/datum/preference/choiced/beefman_trauma
	savefile_key = "feature_beef_trauma"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	randomize_by_default = FALSE
	relevant_mutant_bodypart = "beef_trauma"

/datum/preference/choiced/beefman_trauma/init_possible_values()
	return assoc_to_keys(GLOB.beefmen_traumas)

/datum/preference/choiced/beefman_trauma/apply_to_human(mob/living/carbon/human/target, value)
	var/given_trauma = GLOB.beefmen_traumas[value]
	target.dna.features["beef_trauma"] = given_trauma

/datum/preference/choiced/beefman_trauma/create_default_value()
	return "Strangers"
