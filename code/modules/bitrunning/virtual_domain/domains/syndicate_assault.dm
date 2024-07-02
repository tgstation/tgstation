/datum/lazy_template/virtual_domain/syndicate_assault
	name = "Syndicate Assault"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_MEDIUM
	desc = "Board the enemy ship and recover the stolen cargo."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plush/nukeplushie = 1)
	help_text = "A group of Syndicate operatives have stolen valuable cargo from the station. \
	They have boarded their ship and are attempting to escape. Infiltrate their ship and recover \
	the crate. 	Be careful, they are extremely armed."
	is_modular = TRUE
	key = "syndicate_assault"
	map_name = "syndicate_assault"
	mob_modules = list(/datum/modular_mob_segment/syndicate_team)
	reward_points = BITRUNNER_REWARD_MEDIUM
