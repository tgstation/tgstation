/datum/lazy_template/virtual_domain/stairs_and_cliffs
	name = "Stairs and Cliffs"
	cost = BITRUNNER_COST_LOW
	desc = "A treacherous climb few calves can survive. Great cardio though."
	help_text = "Ever heard of 'Snakes and Ladders'? It's like that, but with \
	instead of ladders its stairs and instead of snakes its a steep drop down a \
	cliff into rough rocks or liquid plasma."
	extra_loot = list(/obj/item/clothing/suit/costume/snowman = 2)
	difficulty = BITRUNNER_DIFFICULTY_LOW
	forced_outfit = /datum/outfit/job/virtual_domain_iceclimber
	key = "stairs_and_cliffs"
	map_name = "stairs_and_cliffs"
	map_height = 75
	map_width = 75
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/ice

/turf/open/cliff/snowrock/virtual_domain
	name = "icy cliff"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/turf/open/lava/plasma/virtual_domain
	name = "plasma lake"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/datum/outfit/job/virtual_domain_iceclimber
	name = "Ice Climber"
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/hooded/wintercoat
	backpack = /obj/item/storage/backpack/duffelbag
	shoes = /obj/item/clothing/shoes/winterboots
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/flashlight/flare
