/datum/preference/choiced/saiyan_tail
	savefile_key = "feature_saiyan_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/monkey/saiyan

/datum/preference/choiced/saiyan_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_saiyan)

/datum/preference/choiced/saiyan_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_saiyan"] = value

/datum/preference/choiced/saiyan_tail/create_default_value()
	var/datum/sprite_accessory/tails/saiyan/tail = /datum/sprite_accessory/tails/saiyan
	return initial(tail.name)
