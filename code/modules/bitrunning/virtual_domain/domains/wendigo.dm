/datum/lazy_template/virtual_domain/wendigo
	name = "Glacial Devourer"
	cost = BITRUNNER_COST_HIGH
	desc = "Legends speak of the ravenous Wendigo hidden deep within the caves of Icemoon."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/job/miner
	key = "wendigo"
	map_name = "wendigo"
	map_height = 37
	map_width = 33
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/wendigo/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	health = 1400
	maxHealth = 1400
	drop_portal = FALSE
