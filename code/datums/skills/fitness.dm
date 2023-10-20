/datum/skill/fitness
	name = "Fitness"
	title = "Fitness"
	desc = "Twinkle twinkle little star, hit the gym and lift the bar."
	/// The skill value modifier effects the max duration that is possible for /datum/status_effect/exercised
	modifiers = list(SKILL_VALUE_MODIFIER = list(2 MINUTES, 3 MINUTES, 4 MINUTES, 5 MINUTES, 6 MINUTES, 7 MINUTES, 10 MINUTES))
	// skill_item_path - your mob sprite gets bigger to showoff so we don't get a special item

/datum/skill/fitness/level_gained(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/size_boost = (new_level == SKILL_LEVEL_LEGENDARY) ? 0.25 : 0.05
	var/gym_size = RESIZE_DEFAULT_SIZE + size_boost
	mind.current.update_transform(gym_size)

/datum/skill/fitness/level_lost(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/size_boost = (new_level == SKILL_LEVEL_LEGENDARY) ? 0.25 : 0.05
	var/gym_size = RESIZE_DEFAULT_SIZE + size_boost
	mind.current.update_transform(RESIZE_DEFAULT_SIZE / gym_size)
