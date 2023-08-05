/datum/lazy_template/virtual_domain/bubblegum
	name = "Blood-Soaked Lair"
	cost = BITRUNNER_COST_HIGH
	desc = "King of the slaughter demons. Bubblegum is a massive, hulking beast with a penchant for violence."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	extra_loot = list(/obj/item/toy/plush/bubbleplush = 1)
	forced_outfit = /datum/outfit/job/miner
	key = "bubblegum"
	map_name = "bubblegum"
	map_height = 46
	map_width = 35
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	health = 1100
	maxHealth = 1100
