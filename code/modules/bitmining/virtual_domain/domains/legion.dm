/datum/map_template/virtual_domain/legion
	name = "Chamber of Echoes"
	cost = BITMINING_COST_MEDIUM
	desc = "A chilling realm that houses Legion's necropolis. Those who succumb to it are forever damned."
	difficulty = BITMINING_DIFFICULTY_MEDIUM
	filename = "legion.dmm"
	id = "legion"
	reward_points = BITMINING_REWARD_MEDIUM

/mob/living/simple_animal/hostile/megafauna/legion/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitminer_loot/encrypted)

// You may be thinking, well, what about those mini-legions? They're not part of the created_atoms list
