/datum/map_template/virtual_domain/wendigo
	name = "Glacial Devourer"
	cost = BITMINING_COST_HIGH
	desc = "Legends speak of the ravenous Wendigo hidden deep within the caves of Icemoon."
	difficulty = BITMINING_DIFFICULTY_HIGH
	filename = "wendigo.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "wendigo"
	reward_points = BITMINING_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/wendigo/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
