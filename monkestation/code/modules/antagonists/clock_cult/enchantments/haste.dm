/datum/component/enchantment/haste
	examine_description = "It has been blessed with the ability to warp time around it so that it's user may attack faster with it."
	max_level = 1

/datum/component/enchantment/haste/apply_effect(obj/item/target)
	target.attack_speed = min(CLICK_CD_FAST_MELEE, target.attack_speed)
