/datum/lazy_template/virtual_domain/blood_drunk_miner
	name = "Sanguine Excavation"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Few escape the surface of Lavaland without a few scars. Some remain, maddened by the hunt."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/job/miner
	key = "blood_drunk_miner"
	map_name = "blood_drunk_miner"
	map_height = 46
	map_width = 35
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	health = 1100
	maxHealth = 1100
