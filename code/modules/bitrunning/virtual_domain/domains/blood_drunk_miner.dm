/datum/lazy_template/virtual_domain/blood_drunk_miner
	name = "Sanguine Excavation"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Few escape the surface of Lavaland without a few scars. Some remain, maddened by the hunt."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/job/miner
	key = "blood_drunk_miner"
	map_name = "blood_drunk_miner"
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	health = 1600
	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	maxHealth = 1600
	true_spawn = FALSE
