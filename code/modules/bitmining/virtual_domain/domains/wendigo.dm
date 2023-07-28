/datum/map_template/virtual_domain/wendigo
	name = "Glacial Devourer"
	cost = BITMINING_COST_HIGH
	desc = "Deep within caves of the frozen wastes, the legendary Wendigo is said to lurk."
	difficulty = BITMINING_DIFFICULTY_HIGH
	filename = "wendigo.dmm"
	id = "wendigo"
	reward_points = BITMINING_REWARD_HIGH

/mob/living/simple_animal/hostile/megafauna/wendigo/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
