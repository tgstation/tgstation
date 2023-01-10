/datum/preference/choiced/ethereal_color
	savefile_key = "feature_ethcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ethereal color"
	should_generate_icons = TRUE

/datum/preference/choiced/ethereal_color/init_possible_values()
	var/list/values = list()

	var/icon/ethereal_base = icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_head")
	ethereal_base.Blend(icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_chest"), ICON_OVERLAY)
	ethereal_base.Blend(icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_l_arm"), ICON_OVERLAY)
	ethereal_base.Blend(icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_r_arm"), ICON_OVERLAY)

	var/icon/eyes = icon('icons/mob/species/human/human_face.dmi', "eyes")
	eyes.Blend(COLOR_BLACK, ICON_MULTIPLY)
	ethereal_base.Blend(eyes, ICON_OVERLAY)

	ethereal_base.Scale(64, 64)
	ethereal_base.Crop(15, 64, 15 + 31, 64 - 31)

	for (var/name in GLOB.color_list_ethereal)
		var/color = GLOB.color_list_ethereal[name]

		var/icon/icon = new(ethereal_base)
		icon.Blend(color, ICON_MULTIPLY)
		values[name] = icon

	return values

/datum/preference/choiced/ethereal_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ethcolor"] = GLOB.color_list_ethereal[value]
