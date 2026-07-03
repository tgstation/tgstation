/datum/preference/choiced/species_feature/skrell_head_tentacle
	savefile_key = "feature_skrell_head_tentacle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Щупальца на голове"
	should_generate_icons = TRUE
	relevant_organ = /obj/item/organ/head_tentacle

/datum/preference/choiced/species_feature/skrell_head_tentacle/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_SKRELL_HEAD_TENTACLE]

/datum/preference/choiced/species_feature/skrell_head_tentacle/icon_for(value)
	var/datum/sprite_accessory/A = get_accessory_for_value(value)
	var/datum/universal_icon/head = uni_icon('icons/bandastation/mob/species/skrell/bodyparts.dmi', "skrell_head")
	var/datum/universal_icon/tentacle_icon = uni_icon(A.icon, "m_skrell_head_tentacle_[A.icon_state]_ADJ")
	tentacle_icon.blend_icon(uni_icon(A.icon, "m_skrell_head_tentacle_[A.icon_state]_FRONT"), ICON_OVERLAY)
	head.blend_icon(tentacle_icon, ICON_OVERLAY)
	head.crop(10, 19, 22, 31)
	head.scale(32, 32)
	return head

/datum/preference/choiced/species_feature/skrell_head_tentacle/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SKRELL_HEAD_TENTACLE] = value

/datum/preference/choiced/species_feature/skrell_head_tentacle/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	return gender == MALE ? /datum/sprite_accessory/skrell_head_tentacle/male::name : /datum/sprite_accessory/skrell_head_tentacle/female::name
