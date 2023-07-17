/datum/map_template/virtual_domain/bubblegum
	name = "Bubblegum's Lair"
	cost = BITMINING_COST_HIGH
	desc = "King of the slaughter demons."
	difficulty = BITMINING_DIFFICULTY_HIGH
	filename = "bubblegum.dmm"
	id = "bubblegum"
	reward_points = BITMINING_REWARD_HIGH
	extra_loot = list(
		/obj/item/toy/plush/bubbleplush,
	)

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual_domain
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
