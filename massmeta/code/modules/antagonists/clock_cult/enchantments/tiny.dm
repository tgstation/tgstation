/datum/component/enchantment/tiny
	max_level = 1

/datum/component/enchantment/tiny/apply_effect(obj/item/target)
	examine_description = "Он был благословлен и искажает реальность в крошечное пространство вокруг него."
	target.w_class = WEIGHT_CLASS_TINY
