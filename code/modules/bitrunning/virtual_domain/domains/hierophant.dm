/datum/map_template/virtual_domain/hierophant
	name = "Zealot Arena"
	cost = BITRUNNER_COST_HIGH
	desc = "Dance, puppets, dance!"
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	filename = "hierophant.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "hierophant"
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/area/ruin/powered/hierophant
	name = "\improper Hierophant's Arena"

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
