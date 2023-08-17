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
	achievement_type = null
	can_be_cybercop = FALSE
	crusher_achievement_type = null
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	drop_portal = FALSE
	guaranteed_butcher_results = list(/obj/item/wendigo_skull = 1)
	health = 1500
	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	maxHealth = 1500
	score_achievement_type = null
