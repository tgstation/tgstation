/datum/lazy_template/virtual_domain/xeno_nest
	name = "Xeno Infestation"
	cost = BITRUNNER_COST_LOW
	desc = "Our ship scanners have detected lifeforms of unknown origin. Friendly attempts to contact them have failed."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/toy/plush/rouny = 1)
	help_text = "You are on a barren planet filled with hostile creatures. There is a crate here, not hidden, \
	simply protected. Expect resistance."
	is_modular = TRUE
	key = "xeno_nest"
	map_name = "xeno_nest"
	mob_modules = list(/datum/modular_mob_segment/xenos)
	reward_points = BITRUNNER_REWARD_LOW
