/datum/map_template/virtual_domain/ash_drake
	name = "Sanguine Excavation"
	cost = BITMINING_COST_MEDIUM
	desc = "Few escape the surface of Lavaland without a few scars. Some remain, maddened by the hunt."
	difficulty = BITMINING_DIFFICULTY_MEDIUM
	filename = "blood_drunk_miner.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "blood_drunk_miner"
	reward_points = BITMINING_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
