/datum/component/enchantment/sharpness
	max_level = 5

/datum/component/enchantment/sharpness/apply_effect(obj/item/target)
	examine_description = "Он был наделен даром остроты."
	target.force += 2 * level
