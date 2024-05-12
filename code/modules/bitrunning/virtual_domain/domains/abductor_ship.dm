/datum/lazy_template/virtual_domain/abductor_ship
	name = "Abductor Ship"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Board an abductor ship and take their goodies."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plush/abductor/agent = 1)
	help_text = "An abductor mothership unknowingly entered a hostile environment. \
	They are currently preparing to escape the area with their gear and loot including \
	the crate. 	Be careful, they are known for their advanced weaponry."
	is_modular = TRUE
	key = "abductor_ship"
	map_name = "abductor_ship"
	mob_modules = list(/datum/modular_mob_segment/abductor_agents)
	reward_points = BITRUNNER_REWARD_MEDIUM
	forced_outfit = /datum/outfit/bitductor
