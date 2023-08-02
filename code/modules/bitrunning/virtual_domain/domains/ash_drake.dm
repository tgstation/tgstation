/datum/map_template/virtual_domain/ash_drake
	name = "Ashen Inferno"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Home of the ash drake, a powerful dragon that scours the surface of Lavaland."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	filename = "ash_drake.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "ash_drake"
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/dragon/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
