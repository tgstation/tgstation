/datum/preference/choiced/monkey_tail
	savefile_key = "feature_monkey_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/monkey
	can_randomize = FALSE

/datum/preference/choiced/monkey_tail/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_monkey)

/datum/preference/choiced/monkey_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAIL_MONKEY] = value

/datum/preference/choiced/monkey_tail/create_default_value()
	return /datum/sprite_accessory/tails/monkey/default::name
