/datum/component/enchantment/anti_magic
	examine_description = "It has been blessed with the gift of magic protection, preventing all magic from affecting the wielder."
	max_level = 1

/datum/component/enchantment/anti_magic/apply_effect(obj/item/target)
	target.AddComponent(/datum/component/anti_magic, TRUE, TRUE)
