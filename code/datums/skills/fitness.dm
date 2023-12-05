/datum/skill/fitness
	name = "Fitness"
	title = "Fitness"
	desc = "Twinkle twinkle little star, hit the gym and lift the bar."
	/// The skill value modifier effects the max duration that is possible for /datum/status_effect/exercised
	modifiers = list(SKILL_VALUE_MODIFIER = list(1 MINUTES, 1.5 MINUTES, 2 MINUTES, 2.5 MINUTES, 3 MINUTES, 3.5 MINUTES, 5 MINUTES))
	/// Amount of max hp gained per level
	var/static/health_boost = list(0, 2, 3, 4, 4, 5, 7)
	/// How much bigger your mob becomes per level (these effects don't stack together)
	var/static/size_boost = list(0, 1/16, 1/8, 3/16, 2/8, 3/8, 4/8)
	// skill_item_path - your mob sprite gets bigger to showoff so we don't get a special item

/datum/skill/fitness/level_gained(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/old_gym_size = RESIZE_DEFAULT_SIZE + size_boost[old_level]
	var/new_gym_size = RESIZE_DEFAULT_SIZE + size_boost[new_level]

	// reset the size before applying the new one, otherwise the size boosts will stack
	mind.current.update_transform(RESIZE_DEFAULT_SIZE / old_gym_size)
	mind.current.update_transform(new_gym_size)
	// at max legendary fitness, all the hp bonuses combined results in a total of +25 max hp
	mind.current.maxHealth += health_boost[new_level]
	mind.current.health += health_boost[new_level]
	mind.current.updatehealth()

/datum/skill/fitness/level_lost(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/old_gym_size = RESIZE_DEFAULT_SIZE + size_boost[old_level]
	var/new_gym_size = RESIZE_DEFAULT_SIZE + size_boost[new_level]

	// reset the size before applying the new one, otherwise the size boosts will stack
	mind.current.update_transform(RESIZE_DEFAULT_SIZE / old_gym_size)
	mind.current.update_transform(new_gym_size)

	mind.current.maxHealth -= health_boost[old_level]
	mind.current.health -= health_boost[old_level]
	mind.current.updatehealth()
