/datum/map_template/virtual_domain/ash_drake
	name = "Ashen Inferno"
	cost = BITMINING_COST_HIGH
	desc = "Home of the ash drake, a powerful dragon that scours the surface of Lavaland."
	difficulty = BITMINING_DIFFICULTY_HIGH
	filename = "ash_drake.dmm"
	id = "ash_drake"
	reward_points = BITMINING_REWARD_HIGH

/mob/living/simple_animal/hostile/megafauna/dragon/virtual_domain
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
