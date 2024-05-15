/datum/lazy_template/virtual_domain/stairs_and_cliffs
	name = "Glacier Grind"
	cost = BITRUNNER_COST_LOW
	desc = "A treacherous climb few calves can survive. Great cardio though."
	help_text = "Ever heard of 'Snakes and Ladders'? It's like that, but with \
	instead of ladders its stairs and instead of snakes its a steep drop down a \
	cliff into rough rocks or liquid plasma."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/clothing/suit/costume/snowman = 2)
	secondary_loot = list(/obj/item/clothing/shoes/wheelys/skishoes = 2, /obj/item/clothing/head/costume/ushanka/polar = 1)
	forced_outfit = /datum/outfit/job/virtual_domain_iceclimber
	key = "stairs_and_cliffs"
	map_name = "stairs_and_cliffs"
	reward_points = BITRUNNER_REWARD_MEDIUM

/turf/open/cliff/snowrock/virtual_domain
	name = "icy cliff"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/turf/open/lava/plasma/virtual_domain
	name = "plasma lake"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/datum/outfit/job/virtual_domain_iceclimber
	name = "Ice Climber"

	uniform = /obj/item/clothing/under/color/grey
	backpack = /obj/item/storage/backpack/duffelbag
	shoes = /obj/item/clothing/shoes/winterboots
