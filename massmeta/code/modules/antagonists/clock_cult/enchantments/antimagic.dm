/datum/component/enchantment/anti_magic
	max_level = 1

/datum/component/enchantment/anti_magic/apply_effect(obj/item/target)
	examine_description = "Он был благословлен даром магической защиты, не позволяя магии повлиять на владельца."
	target.AddComponent(/datum/component/anti_magic, TRUE, TRUE)
