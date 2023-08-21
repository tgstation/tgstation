/datum/component/enchantment/tiny
	examine_description = "It has been blessed and distorts reality into a tiny space around it."
	max_level = 1

/datum/component/enchantment/tiny/apply_effect(obj/item/target)
	target.w_class = WEIGHT_CLASS_TINY
