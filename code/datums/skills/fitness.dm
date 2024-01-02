/datum/skill/fitness
	name = "Fitness"
	title = "Fitness"
	desc = "Twinkle twinkle little star, hit the gym and lift the bar."
	/// The skill value modifier effects the max duration that is possible for /datum/status_effect/exercised
	modifiers = list(SKILL_VALUE_MODIFIER = list(1 MINUTES, 1.5 MINUTES, 2 MINUTES, 2.5 MINUTES, 3 MINUTES, 3.5 MINUTES, 5 MINUTES))
	/// How much bigger your mob becomes per level (these effects don't stack together)
	var/static/size_boost = list(0, 1/16, 1/8, 3/16, 2/8, 3/8, 4/8)
	// skill_item_path - your mob sprite gets bigger to showoff so we don't get a special item

/datum/skill/fitness/level_gained(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/old_gym_size = RESIZE_DEFAULT_SIZE + size_boost[old_level]
	var/new_gym_size = RESIZE_DEFAULT_SIZE + size_boost[new_level]

	mind.current.update_transform(new_gym_size / old_gym_size)

/datum/skill/fitness/level_lost(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	var/old_gym_size = RESIZE_DEFAULT_SIZE + size_boost[old_level]
	var/new_gym_size = RESIZE_DEFAULT_SIZE + size_boost[new_level]

	mind.current.update_transform(new_gym_size / old_gym_size)
