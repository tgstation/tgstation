/datum/lazy_template/virtual_domain/psyker_zombies
	name = "Infected Domain"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Another neglected corner of the virtual world. This one had to be abandoned due to zombie virus. \
		Warning -- Virtual domain does not support visual display. This mission must be completed using echolocation."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	help_text = "This once-beloved virtual domain has been corrupted by a virus, rendering it unstable, full of holes, and full of ZOMBIES! \
		There should be a Mystery Box nearby to help get you armed. Get armed, and finish what the cyber-police started!"
	key = "psyker_zombies"
	map_name = "psyker_zombies"
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/bathroom
	forced_outfit = /datum/outfit/echolocator
	extra_loot = list(/obj/item/radio/headset/psyker = 1) //Looks cool, might make your local burdened chaplain happy.
