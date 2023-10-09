/datum/lazy_template/virtual_domain/ash_drake
	name = "Ashen Inferno"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Home of the ash drake, a powerful dragon that scours the surface of Lavaland."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/job/miner
	key = "ash_drake"
	map_name = "ash_drake"
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/dragon/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	health = 1600
	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	maxHealth = 1600
	true_spawn = FALSE
