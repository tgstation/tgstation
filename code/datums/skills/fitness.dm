/datum/skill/fitness
	name = "Fitness"
	title = "Fitness"
	desc = "Twinkle twinkle little star, hit the gym and lift the bar."
	/// The skill value modifier effects the max duration that is possible for /datum/status_effect/exercised
	modifiers = list(SKILL_VALUE_MODIFIER = list(1 MINUTES, 1.5 MINUTES, 2 MINUTES, 2.5 MINUTES, 3 MINUTES, 3.5 MINUTES, 5 MINUTES))
	// skill_item_path - your mob sprite gets bigger to showoff so we don't get a special item

/datum/skill/fitness/level_gained(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/size_boost = (new_level == SKILL_LEVEL_LEGENDARY) ? 0.25 : 0.05
	var/gym_size = RESIZE_DEFAULT_SIZE + size_boost
	mind.current.update_transform(gym_size)
	// at max legendary fitness, all the hp bonuses combined results in a total of +25 max hp
	mind.current.maxHealth += (size_boost*100)/2 // +2.5 hp per level (and +5 hp on gaining legendary)
	mind.current.health += (size_boost*100)/2
	mind.current.updatehealth()

/datum/skill/fitness/level_lost(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/size_boost = (new_level == SKILL_LEVEL_LEGENDARY) ? 0.25 : 0.05
	var/gym_size = RESIZE_DEFAULT_SIZE + size_boost
	mind.current.update_transform(RESIZE_DEFAULT_SIZE / gym_size)
	mind.current.maxHealth -= (size_boost*100)/2
	mind.current.health -= (size_boost*100)/2
	mind.current.updatehealth()
