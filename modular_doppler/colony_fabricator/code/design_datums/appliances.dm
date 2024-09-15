// Machine categories

#define FABRICATOR_CATEGORY_APPLIANCES "/Appliances"
#define FABRICATOR_SUBCATEGORY_POWER "/Power"
#define FABRICATOR_SUBCATEGORY_ATMOS "/Atmospherics"
#define FABRICATOR_SUBCATEGORY_FLUIDS "/Liquids"
#define FABRICATOR_SUBCATEGORY_MATERIALS "/Materials"
#define FABRICATOR_SUBCATEGORY_SUSTENANCE "/Sustenance"

// Techweb node that shouldnt show up anywhere ever specifically for the fabricator to work with

/datum/techweb_node/colony_fabricator_appliances
	id = TECHWEB_NODE_COLONY_APPLIANCES
	display_name = "Colony Fabricator Appliance Designs"
	description = "Contains all of the colony fabricator's appliance machine designs."
	design_ids = list(
		"wall_multi_cell_rack",
		"portable_lil_pump",
		"portable_scrubbs",
		"survival_knife", // I just don't want to make a whole new node for this one sorry
		"water_synth",
		"hydro_synth",
		"frontier_sustenance_dispenser",
		"co2_cracker",
		"portable_recycler",
		"foodricator",
		"wall_heater",
		"macrowave",
		"frontier_range",
		"tabletop_griddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000000000000000) // God save you
	hidden = TRUE
	show_on_wiki = FALSE
	starting_node = TRUE

// Wall mountable multi cell charger

/datum/design/wall_mounted_multi_charger
	name = "Mounted Multi-Cell Charging Rack"
	id = "wall_multi_cell_rack"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	build_path = /obj/item/wallframe/cell_charger_multi
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 15 SECONDS

// Portable scrubber and pumps for all your construction atmospherics needs

/datum/design/portable_gas_pump
	name = "Portable Air Pump"
	id = "portable_lil_pump"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/machinery/portable_atmospherics/pump
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_ATMOS,
	)
	construction_time = 30 SECONDS

/datum/design/portable_gas_scrubber
	name = "Portable Air Scrubber"
	id = "portable_scrubbs"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/machinery/portable_atmospherics/scrubber
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_ATMOS,
	)
	construction_time = 30 SECONDS

/// Space heater, but it mounts on walls

/datum/design/wall_mounted_space_heater
	name = "Mounted Heater"
	id = "wall_heater"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/wallframe/wall_heater
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_ATMOS,
	)
	construction_time = 15 SECONDS

// Plumbable chem machine that makes nothing but water

/datum/design/water_synthesizer
	name = "Water Synthesizer"
	id = "water_synth"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/water_synth
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_FLUIDS,
	)
	construction_time = 30 SECONDS

// Plumbable chem machine that makes nothing but water

/datum/design/hydro_synthesizer
	name = "Hydroponics Chemical Synthesizer"
	id = "hydro_synth"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/hydro_synth
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_FLUIDS,
	)
	construction_time = 30 SECONDS

// Chem dispenser that dispenses various flavored beverages and nutrislop, yum!

/datum/design/frontier_sustenance_dispenser
	name = "Sustenance Dispenser"
	id = "frontier_sustenance_dispenser"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/sustenance_machine
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_SUSTENANCE,
	)
	construction_time = 30 SECONDS

// CO2 cracker, portable machines that takes CO2 and turns it into oxygen

/datum/design/co2_cracker
	name = "Portable Carbon Dioxide Cracker"
	id = "co2_cracker"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT, // We're gonna pretend plasma is the catalyst for co2 cracking
	)
	build_path = /obj/item/flatpacked_machine/co2_cracker
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_ATMOS,
	)
	construction_time = 30 SECONDS

// A portable recycling machine, use item with materials on it to recycle

/datum/design/portable_recycler
	name = "Portable Recycler"
	id = "portable_recycler"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT, // Titan for the crushing element
	)
	build_path = /obj/item/flatpacked_machine/recycler
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 30 SECONDS

// Rations printer, turns biomass into seeds, some synthesized foods, ingredients, so on

/datum/design/foodricator
	name = "Organic Rations Printer"
	id = "foodricator"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/organics_ration_printer
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_SUSTENANCE,
	)
	construction_time = 30 SECONDS

// Really, it's just a microwave

/datum/design/macrowave
	name = "Microwave Oven"
	id = "macrowave"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/macrowave
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_SUSTENANCE,
	)
	construction_time = 30 SECONDS

// A range, but it looks cool af

/datum/design/frontier_range
	name = "Frontier Range"
	id = "frontier_range"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/frontier_range
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_SUSTENANCE,
	)
	construction_time = 1 MINUTES

// Griddles that fit on top of any regular table

/datum/design/tabletop_griddle
	name = "Tabletop Griddle"
	id = "tabletop_griddle"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/frontier_griddle
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_APPLIANCES + FABRICATOR_SUBCATEGORY_SUSTENANCE,
	)
	construction_time = 1 MINUTES

#undef FABRICATOR_CATEGORY_APPLIANCES
#undef FABRICATOR_SUBCATEGORY_POWER
#undef FABRICATOR_SUBCATEGORY_ATMOS
#undef FABRICATOR_SUBCATEGORY_FLUIDS
#undef FABRICATOR_SUBCATEGORY_MATERIALS
#undef FABRICATOR_SUBCATEGORY_SUSTENANCE
