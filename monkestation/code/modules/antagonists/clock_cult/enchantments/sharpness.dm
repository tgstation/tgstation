/datum/component/enchantment/sharpness
	examine_description = "It has been blessed with the gift of sharpness."
	max_level = 5

/datum/component/enchantment/sharpness/apply_effect(obj/item/target)
	target.force += 2 * level
