/obj/modular_map_root/tissstation
	config_file = "strings/modular_maps/TissStation.toml"

/obj/item/paper/fluff/downward_spiral
	name = "The Downward Spiral"
	desc = "A dark slip of paper with text hastily scrawled upon it."
	default_raw_text = @{"<h1>
	you got a head lioke a hole loll"</h1>
	"}
	color = "#2a2a2a"

/mob/living/basic/pet/penguin/emperor/jettin
	name = "Jettin"
	desc = "The Quartermaster's pet penguin. Incapable of learning tricks, and is the master of his own destiny."
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/obj/structure/bed/dogbed/jettin
	desc = "Jettin's bed. I'm sure he'd prefer a steamy bath."
	name = "Jettin's bed"
	anchored = TRUE

/turf/open/floor/wood/bowling
	desc = "Careful! The bowling lane is oiled regularly!"
	name = "Bowling Lane"

/turf/open/floor/wood/bowling/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wet_floor, TURF_WET_LUBE, INFINITY, 0, INFINITY, TRUE)

/obj/effect/spawner/random/food_or_drink/guffin
	name = "mcguffin spawner"
	icon_state = "donut"
	spawn_loot_chance = 90
	loot = list(
		/obj/item/food/burger/mcguffin = 3,
		/obj/item/food/burger/rootguffin = 1,
	)

/turf/closed/wall/mineral/stone
	name = "stone wall"
	desc = "A wall with stone plating. Cold and rough. The kind of thing kingdoms are made of."
	icon = 'troutstation/icons/turf/walls/stone_wall.dmi'
	icon_state = "stone_wall-0"
	base_icon_state = "stone_wall"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	hardness = 45
	explosive_resistance = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS
	custom_materials = list(/datum/material/sandstone = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/stone/wizard
	icon = 'troutstation/icons/turf/walls/stone_wall_wizard.dmi'
	icon_state = "stone_wall_wizard-0"
	base_icon_state = "stone_wall_wizard"
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS_WIZARD + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS_WIZARD

/obj/structure/sink/cauldron
	name = "cauldron"
	icon = 'troutstation/icons/obj/watercloset.dmi'
	icon_state = "cauldron"
	desc = "A mystically shitty cauldron which seems to slowly refill its contents. You don't think you'd be able to actually brew with this..."
	dispensedreagent = /datum/reagent/luminescent_fluid

/// Areas

/area/station/service/kitchen/tisserand
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Kitchen"

/area/station/service/kitchen/tisserand/Initialize(mapload)
	. = ..()
	name = "\improper [pick("Greggs", "Hungry Jack's", "Baker's Delight", "Grill'd", "Guzman y Gomez", "Oporto", "Pancake Parlour", "Red Rooster", "Brodies", "Kingsleys", "Cold Rock Ice Creamery", "Zambrero", "Eagle Boys", "Donut King", "Boost Juice", "Crust", "Hog's Breath Cafe", "Mad Mex", "Sumo Salad", "Salsas", "Zeus Street Greek", "La Porchetta", "Noodle Box", "Wokitup", "Wokinabox", "Roll'd", "Lord of the Fries", "Betty’s Burgers & Concrete Co.", "Sushi Hub", "Breadtop", "Pie Face", "SpudBAR", "Grease Monkey", "Wendy's Milk Bar", "Yatala Pie Shop", "Sizzler", "Sandwich Chefs", "Soul Origin", "Soonta", "The Tuckerbox", "1919 Lanzhou Beef Noodle", "Canteen")]"

/area/station/security/lobby
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Security Lobby"

/area/station/service/hydroponics/apiary
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Apiary"

/area/station/ai/satellite/outlook
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper AI Satellite Outlook"

/area/station/hallway/primary/tram/sciai
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Science Tram"

/area/station/science/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Science Walkway"

/area/station/engineering/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Engineering Walkway"

/area/station/security/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Security Walkway"

/area/station/medical/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Medical Walkway"

/area/station/commons/park
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Park"

/area/station/hallway/tube
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Tube Room"

/area/station/medical/chemistry/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Chemistry Walkway"

/area/station/ai/satellite/garden
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper AI Satellite Garden"

/area/station/medical/virology/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Virology Walkway"

/area/station/commons/fitness/recreation/gambling
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Gambling Den"

/area/station/hallway/fore/starboard
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Fore Starboard Primary Hallway"

/area/station/hallway/fore/port
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Fore Port Primary Hallway"

/area/station/cargo/walkway
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Cargo Walkway"

/area/station/maintenance/department/science/south
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper South Science Maintenance"

/area/station/maintenance/department/science/west
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper West Science Maintenance"

/area/station/commons/fitness/recreation/bowling
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Bowling Alley"

/area/station/maintenance/cocoon
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper The Cocoon"

/area/station/maintenance/rags
	icon = 'troutstation/icons/area/areas_station.dmi'
	icon_state = "tiss"
	name = "\improper Whirling-in-Rags"

