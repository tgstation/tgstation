/datum/lazy_template/virtual_domain/hierophant
	name = "Zealot Arena"
	cost = BITRUNNER_COST_HIGH
	desc = "Dance, puppets, dance!"
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/job/miner
	key = "hierophant"
	map_name = "hierophant"
	map_height = 38
	map_width = 25
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/area/ruin/powered/hierophant
	name = "\improper Hierophant's Arena"

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	health = 1400
	maxHealth = 1400
