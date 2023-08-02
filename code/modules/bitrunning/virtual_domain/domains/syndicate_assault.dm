/datum/map_template/virtual_domain/syndicate_assault
	name = "Syndicate Assault"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Board the enemy ship and recover the stolen cargo."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	extra_loot = list(
		/obj/item/toy/plush/nukeplushie
	)
	filename = "syndicate_assault.dmm"
	help_text = "A group of Syndicate operatives have stolen valuable cargo from the station. \
	They have boarded their ship and are attempting to escape. Infiltrate their ship and recover \
	the crate. 	Be careful, they are extremely armed."
	id = "syndicate_assault"
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/shuttle
