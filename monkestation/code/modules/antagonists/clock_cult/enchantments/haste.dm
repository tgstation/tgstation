/datum/component/enchantment/haste
	examine_description = "It has been blessed with the ability to warp time around it so that it's user may attack faster with it."
	max_level = 1

/datum/component/enchantment/haste/apply_effect(obj/item/target)
	target.attack_speed = max(1, target.attack_speed - 2)
