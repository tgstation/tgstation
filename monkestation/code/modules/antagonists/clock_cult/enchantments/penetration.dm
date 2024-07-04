/datum/component/enchantment/penetration
	examine_description = "It has been blessed with the gift of armor penetration, allowing it to cut through targets with ease."
	max_level = 5

/datum/component/enchantment/penetration/apply_effect(obj/item/target)
	target.armour_penetration = max(15 * level, target.armour_penetration)
