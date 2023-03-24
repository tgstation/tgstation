/datum/component/enchantment/blocking
	max_level = 3

/datum/component/enchantment/blocking/apply_effect(obj/item/target)
	examine_description = "Это было благословлено даром блокировки."
	target.block_chance = level * 10
