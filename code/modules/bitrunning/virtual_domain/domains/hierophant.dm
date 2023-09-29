/datum/lazy_template/virtual_domain/hierophant
	name = "Zealot Arena"
	cost = BITRUNNER_COST_HIGH
	desc = "Dance, puppets, dance!"
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/job/miner
	key = "hierophant"
	map_name = "hierophant"
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	health = 1700
	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	maxHealth = 1700
	true_spawn = FALSE
