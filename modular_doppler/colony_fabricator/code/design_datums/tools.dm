/datum/techweb_node/colony_fabricator_special_tools
	id = TECHWEB_NODE_COLONY_TOOLS
	display_name = "Colony Fabricator Tool Designs"
	description = "Contains all of the colony fabricator's tool designs."
	design_ids = list(
		"colony_crowbar",
		"colony_screwdriver",
		"colony_wrench",
		"colony_wirecutters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 50000000000000) // God save you
	hidden = TRUE
	show_on_wiki = FALSE
	starting_node = TRUE

// red crowbar lmao

/datum/design/colony_crowbar
	name = "Experimental Crowbar"
	id = "colony_crowbar"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/crowbar/red/caravan
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)

// red screwdriver lmao

/datum/design/colony_screwdriver
	name = "Experimental Screwdriver"
	id = "colony_screwdriver"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/screwdriver/caravan
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)

// red wrench lmao

/datum/design/colony_wrench
	name = "Experimental Wrench"
	id = "colony_wrench"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/wrench/caravan
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)

// red wirecutters lmao

/datum/design/colony_wirecutters
	name = "Experimental Wirecutters"
	id = "colony_wirecutters"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/wirecutters/caravan
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)
