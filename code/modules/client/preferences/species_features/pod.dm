/datum/preference/choiced/pod_hair
	savefile_key = "feature_pod_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hairstyle"
	should_generate_icons = TRUE

/datum/preference/choiced/pod_hair/init_possible_values()
	var/list/values = list()

	var/icon/pod_head = icon('icons/mob/species/human/bodyparts_greyscale.dmi', "pod_head_m")

	for (var/pod_name in GLOB.pod_hair_list)
		var/datum/sprite_accessory/pod_hair = GLOB.pod_hair_list[pod_name]
		if(pod_hair.locked)
			continue

		var/icon/icon_with_hair = new(pod_head)
		var/icon/icon_adj = icon(pod_hair.icon, "m_pod_hair_[pod_hair.icon_state]_ADJ")
		var/icon/icon_front = icon(pod_hair.icon, "m_pod_hair_[pod_hair.icon_state]_FRONT")
		icon_adj.Blend(icon_front, ICON_OVERLAY)
		icon_with_hair.Blend(icon_adj, ICON_OVERLAY)
		icon_with_hair.Scale(64, 64)
		icon_with_hair.Crop(15, 64, 15 + 31, 64 - 31)
		icon_with_hair.Blend(COLOR_GREEN, ICON_MULTIPLY)

		values[pod_hair.name] = icon_with_hair

	return values

/datum/preference/choiced/pod_hair/create_default_value()
	return pick(assoc_to_keys_features(GLOB.pod_hair_list))

/datum/preference/choiced/pod_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pod_hair"] = value
