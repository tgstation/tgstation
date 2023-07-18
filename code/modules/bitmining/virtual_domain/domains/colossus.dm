/datum/map_template/virtual_domain/colossus
	name = "Celestial Trial"
	cost = BITMINING_COST_HIGH
	desc = "A massive, ancient beast named the Colossus. Judgment comes."
	difficulty = BITMINING_DIFFICULTY_HIGH
	filename = "colossus.dmm"
	id = "colossus"
	reward_points = BITMINING_REWARD_HIGH

/mob/living/simple_animal/hostile/megafauna/colossus/virtual_domain
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
