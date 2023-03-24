/datum/component/enchantment/penetration
	max_level = 5

/datum/component/enchantment/penetration/apply_effect(obj/item/target)
	examine_description = "Он был благословлен даром проникновения сквозь броню, что позволяет ему легко пробивать цели."
	target.armour_penetration = 15 * level
