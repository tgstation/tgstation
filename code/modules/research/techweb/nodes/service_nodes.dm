/datum/techweb_node/office_equip
	id = TECHWEB_NODE_OFFICE_EQUIP
	starting_node = TRUE
	display_name = "Office Equipment"
	description = "Nanotrasen's finest in ergonomic office tech, ensuring station admin stays productive and compliant with corporate policies — because even in space, paperwork never stops."
	design_ids = list(
		"fax",
		"sec_pen",
		"handlabel",
		"roll",
		"universal_scanner",
		"desttagger",
		"packagewrap",
		"sticky_tape",
		"toner_large",
		"toner",
		"boxcutter",
		"bounced_radio",
		"radio_headset",
		"earmuffs",
		"recorder",
		"tape",
		"toy_balloon",
		"pet_carrier",
		"chisel",
		"spraycan",
		"camera_film",
		"camera",
		"razor",
		"bucket",
		"mop",
		"pushbroom",
		"normtrash",
		"wirebrush",
		"flashlight",
	)

/datum/techweb_node/sanitation
	id = TECHWEB_NODE_SANITATION
	display_name = "Advanced Sanitation Technology"
	description = "Nanotrasen's latest in janitorial tech, making sure the station stays spotless and bear-free."
	prereq_ids = list(TECHWEB_NODE_OFFICE_EQUIP)
	design_ids = list(
		"advmop",
		"light_replacer",
		"spraybottle",
		"paint_remover",
		"beartrap",
		"buffer",
		"vacuum",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/janitor_trash = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/toys
	id = TECHWEB_NODE_TOYS
	display_name = "New Toys"
	description = "For new pranks."
	prereq_ids = list(TECHWEB_NODE_OFFICE_EQUIP)
	design_ids = list(
		"smoke_machine",
		"toy_armblade",
		"air_horn",
		"clown_firing_pin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/consoles
	id = TECHWEB_NODE_CONSOLES
	display_name = "Civilian Consoles"
	description = "User-friendly consoles for non-technical crew members, enhancing communication and access to essential station information."
	prereq_ids = list(TECHWEB_NODE_OFFICE_EQUIP)
	design_ids = list(
		"comconsole",
		"automated_announcement",
		"cargo",
		"cargorequest",
		"med_data",
		"crewconsole",
		"bankmachine",
		"account_console",
		"idcard",
		"c-reader",
		"libraryconsole",
		"libraryscanner",
		"bookbinder",
		"barcode_scanner",
		"vendor",
		"custom_vendor_refill",
		"bounty_pad_control",
		"bounty_pad",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/gaming
	id = TECHWEB_NODE_GAMING
	display_name = "Gaming"
	description = "For the slackers on the station."
	prereq_ids = list(TECHWEB_NODE_TOYS, TECHWEB_NODE_CONSOLES)
	design_ids = list(
		"arcade_battle",
		"arcade_orion",
		"slotmachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/physical/arcade_winner = TECHWEB_TIER_2_POINTS)

// Kitchen root node
/datum/techweb_node/cafeteria_equip
	id = TECHWEB_NODE_CAFETERIA_EQUIP
	starting_node = TRUE
	display_name = "Cafeteria Equipment"
	description = "When standard-issue tubed food no longer satisfies the station crew's appetite..."
	design_ids = list(
		"griddle",
		"microwave",
		"bowl",
		"plate",
		"oven_tray",
		"servingtray",
		"tongs",
		"spoon",
		"fork",
		"kitchen_knife",
		"plastic_spoon",
		"plastic_fork",
		"plastic_knife",
		"shaker",
		"drinking_glass",
		"shot_glass",
		"coffee_cartridge",
		"coffeemaker",
		"coffeepot",
		"syrup_bottle",
	)

/datum/techweb_node/food_proc
	id = TECHWEB_NODE_FOOD_PROC
	display_name = "Food Processing"
	description = "Top-tier kitchen appliances from Nanotrasen, designed to keep the crew well-fed and happy."
	prereq_ids = list(TECHWEB_NODE_CAFETERIA_EQUIP)
	design_ids = list(
		"deepfryer",
		"oven",
		"stove",
		"range",
		"souppot",
		"processor",
		"gibber",
		"monkey_recycler",
		"reagentgrinder",
		"microwave_engineering",
		"smartfridge",
		"sheetifier",
		"fat_sucker",
		"dish_drive",
		"roastingstick",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

// Fishing root node
/datum/techweb_node/fishing_equip
	id = TECHWEB_NODE_FISHING_EQUIP
	starting_node = TRUE
	display_name = "Fishing Equipment"
	description = "Basic fishing gear tailored for space station environments, perfect for extraterrestrial aquatic pursuits."
	design_ids = list(
		"fishing_portal_generator",
		"fishing_rod",
		"fish_case",
	)

/datum/techweb_node/fishing_equip_adv
	id = TECHWEB_NODE_FISHING_EQUIP_ADV
	display_name = "Advanced Fishing Tools"
	description = "Continuing advancements in fishing technology, incorporating cutting-edge features in space fishing operations. Just don't try this on space carps..."
	prereq_ids = list(TECHWEB_NODE_FISHING_EQUIP)
	design_ids = list(
		"fishing_rod_tech",
		"stabilized_hook",
		"auto_reel",
		"fish_analyzer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/fish)

/datum/techweb_node/marine_util
	id = TECHWEB_NODE_MARINE_UTIL
	display_name = "Marine Utility"
	description = "Fish are nice to look at and all, but they can be put to use."
	prereq_ids = list(TECHWEB_NODE_FISHING_EQUIP_ADV)
	design_ids = list(
		"bioelec_gen",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	// only available if you've done the first fishing experiment (thus unlocking fishing tech), but not a strict requirement to get the tech
	discount_experiments = list(/datum/experiment/scanning/fish/second = TECHWEB_TIER_3_POINTS)

// Botany root node
/datum/techweb_node/botany_equip
	id = TECHWEB_NODE_BOTANY_EQUIP
	starting_node = TRUE
	display_name = "Botany Equipment"
	description = "Essential tools for maintaining onboard gardens, supporting plant growth in the unique environment of the space station."
	design_ids = list(
		"seed_extractor",
		"plant_analyzer",
		"watering_can",
		"spade",
		"cultivator",
		"secateurs",
		"hatchet",
	)

/datum/techweb_node/hydroponics
	id = TECHWEB_NODE_HYDROPONICS
	display_name = "Hydroponics"
	description = "Research into advanced hydroponic systems for efficient and sustainable plant cultivation."
	prereq_ids = list(TECHWEB_NODE_BOTANY_EQUIP, TECHWEB_NODE_CHEM_SYNTHESIS)
	design_ids = list(
		"biogenerator",
		"hydro_tray",
		"portaseeder",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/selection
	id = TECHWEB_NODE_SELECTION
	display_name = "Artificial Selection"
	description = "Advancement in plant cultivation techniques through artificial selection, enabling precise manipulation of plant DNA."
	prereq_ids = list(TECHWEB_NODE_HYDROPONICS)
	design_ids = list(
		"flora_gun",
		"gene_shears",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/plants/wild)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = TECHWEB_TIER_3_POINTS)
