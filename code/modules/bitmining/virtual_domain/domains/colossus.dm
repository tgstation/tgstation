/datum/map_template/virtual_domain/colossus
	name = "Celestial Trial"
	cost = BITMINING_COST_HIGH
	desc = "A massive, ancient beast named the Colossus. Judgment comes."
	difficulty = BITMINING_DIFFICULTY_HIGH
	filename = "colossus.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "colossus"
	reward_points = BITMINING_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/colossus/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
