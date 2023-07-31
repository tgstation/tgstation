/datum/map_template/virtual_domain/bubblegum
	name = "Blood-Soaked Lair"
	cost = BITMINING_COST_HIGH
	desc = "King of the slaughter demons. Bubblegum is a massive, hulking beast with a penchant for violence."
	difficulty = BITMINING_DIFFICULTY_HIGH
	extra_loot = list(/obj/item/toy/plush/bubbleplush)
	filename = "bubblegum.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "bubblegum"
	reward_points = BITMINING_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
