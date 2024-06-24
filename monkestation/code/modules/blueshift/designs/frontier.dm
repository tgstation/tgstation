// Machine categories

#define FABRICATOR_CATEGORY_APPLIANCES "/Appliances"
#define FABRICATOR_SUBCATEGORY_POWER "/Power"
#define FABRICATOR_SUBCATEGORY_ATMOS "/Atmospherics"
#define FABRICATOR_SUBCATEGORY_FLUIDS "/Liquids"
#define FABRICATOR_SUBCATEGORY_MATERIALS "/Materials"
#define FABRICATOR_SUBCATEGORY_SUSTENANCE "/Sustenance"

// Techweb node that shouldnt show up anywhere ever specifically for the fabricator to work with

/datum/techweb_node/colony_fabricator_appliances
	id = "colony_fabricator_appliances"
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

// Really, its just a microwave

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

// Look, I had to make its name start with A so it'd be top of the list, fight me

#define FABRICATOR_SUBCATEGORY_STRUCTURES "/Autofab Structures"

// Techweb node that shouldnt show up anywhere ever specifically for the fabricator to work with

/datum/techweb_node/colony_fabricator_structures
	id = "colony_fabricator_structures"
	display_name = "Colony Fabricator Structure Designs"
	description = "Contains all of the colony fabricator's structure designs."
	design_ids = list(
		"prefab_airlock_kit",
		"prefab_manual_airlock_kit",
		"prefab_shutters_kit",
		"prefab_floor_tile",
		"prefab_cat_floor_tile",
		"colony_fab_plastic_wall_panel",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000000000000000) // God save you
	hidden = TRUE
	show_on_wiki = FALSE
	starting_node = TRUE

// Airlock kit

/datum/design/prefab_airlock_kit
	name = "Prefab Airlock"
	id = "prefab_airlock_kit"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/flatpacked_machine/airlock_kit
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + FABRICATOR_SUBCATEGORY_STRUCTURES,
	)
	construction_time = 10 SECONDS

// Manul Airlock kit

/datum/design/prefab_manual_airlock_kit
	name = "Prefab Manual Airlock"
	id = "prefab_manual_airlock_kit"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/flatpacked_machine/airlock_kit_manual
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + FABRICATOR_SUBCATEGORY_STRUCTURES,
	)
	construction_time = 5 SECONDS

// Shutters kit

/datum/design/prefab_shutters_kit
	name = "Prefab Shutters"
	id = "prefab_shutters_kit"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/flatpacked_machine/shutter_kit
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + FABRICATOR_SUBCATEGORY_STRUCTURES,
	)
	construction_time = 10 SECONDS

// Fancy floor tiles

/datum/design/prefab_floor_tile
	name = "Prefab Floor Tile"
	id = "prefab_floor_tile"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT / 4,
	)
	build_path = /obj/item/stack/tile/iron/colony
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + FABRICATOR_SUBCATEGORY_STRUCTURES,
	)
	construction_time = 0.5 SECONDS

// Fancy catwalk floor tiles

/datum/design/prefab_cat_floor_tile
	name = "Prefab Catwalk Plating"
	id = "prefab_cat_floor_tile"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT / 4,
	)
	build_path = /obj/item/stack/tile/catwalk_tile/colony_lathe
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + FABRICATOR_SUBCATEGORY_STRUCTURES,
	)
	construction_time = 0.5 SECONDS

// Plastic wall panels, twice the wall for the same price in plastic, efficient!

/datum/design/colony_fab_plastic_wall_panel
	name = "Plastic Paneling"
	id = "colony_fab_plastic_wall_panel"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/stack/sheet/plastic_wall_panel/ten
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + FABRICATOR_SUBCATEGORY_STRUCTURES,
	)
	construction_time = 1 SECONDS

#undef FABRICATOR_SUBCATEGORY_STRUCTURES

/datum/design/survival_knife
	name = "Survival Knife"
	id = "survival_knife"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6,
	)
	build_path = /obj/item/knife/combat/survival
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

// Lets colony fabricators make soup pots, removes bluespace crystal requirement.
/datum/design/soup_pot/New()
	build_type |= COLONY_FABRICATOR
	materials -= /datum/material/bluespace
	return ..()

// Machine categories

#define FABRICATOR_CATEGORY_FLATPACK_MACHINES "/Flatpacked Machines"
#define FABRICATOR_SUBCATEGORY_MANUFACTURING "/Manufacturing"
#define FABRICATOR_SUBCATEGORY_POWER "/Power"
#define FABRICATOR_SUBCATEGORY_MATERIALS "/Materials"
#define FABRICATOR_SUBCATEGORY_ATMOS "/Atmospherics"

// Techweb node that shouldnt show up anywhere ever specifically for the fabricator to work with

/datum/techweb_node/colony_fabricator_flatpacks
	id = "colony_fabricator_flatpacks"
	display_name = "Colony Fabricator Flatpack Designs"
	description = "Contains all of the colony fabricator's flatpack machine designs."
	design_ids = list(
		"flatpack_solar_panel",
		"flatpack_solar_tracker",
		"flatpack_arc_furnace",
		"flatpack_colony_fab",
		"flatpack_station_battery",
		"flatpack_station_battery_large",
		"flatpack_fuel_generator",
		"flatpack_rtg",
		"flatpack_thermo",
		"flatpack_ore_silo",
		"flatpack_turbine_team_fortress_two",
		"flatpack_bootleg_teg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000000000000000) // God save you
	hidden = TRUE
	show_on_wiki = FALSE
	starting_node = TRUE

// Lets the colony lathe make more colony lathes but at very hihg cost, for fun

/datum/design/flatpack_colony_fabricator
	name = "Flat-Packed Colony Fabricator"
	desc = "A deployable fabricator capable of producing other flat-packed machines and other special equipment tailored for \
		rapidly constructing functional structures given resources and power. While it cannot be upgraded, it can be repacked \
		and moved to any location you see fit."
	id = "flatpack_colony_fab"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_MANUFACTURING,
	)
	construction_time = 2 MINUTES

// Solar panels and trackers

/datum/design/flatpack_solar_panel
	name = "Flat-Packed Solar Panel"
	desc = "A deployable solar panel, able to be repacked after placement for relocation or recycling."
	id = "flatpack_solar_panel"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
	)
	build_path = /obj/item/flatpacked_machine/solar
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 5 SECONDS

/datum/design/flatpack_solar_tracker
	name = "Flat-Packed Solar Tracker"
	desc = "A deployable solar tracker, able to be repacked after placement for relocation or recycling."
	id = "flatpack_solar_tracker"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT * 3.5,
	)
	build_path = /obj/item/flatpacked_machine/solar_tracker
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 7 SECONDS

// Arc furance

/datum/design/flatpack_arc_furnace
	name = "Flat-Packed Arc Furnace"
	desc = "A deployable furnace for refining ores. While slower and less safe than conventional refining methods, \
		it multiplies the output of refined materials enough to still outperform simply recycling ore."
	id = "flatpack_arc_furnace"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
	)
	build_path = /obj/item/flatpacked_machine/arc_furnace
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 15 SECONDS

// Power storage structures

/datum/design/flatpack_power_storage
	name = "Flat-Packed Stationary Battery"
	desc = "A deployable station-scale power cell with an overall low capacity, but high input and output rate."
	id = "flatpack_station_battery"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/station_battery
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 20 SECONDS

/datum/design/flatpack_power_storage_large
	name = "Flat-Packed Large Stationary Battery"
	desc = "A deployable station-scale power cell with an overall extremely high capacity, but low input and output rate."
	id = "flatpack_station_battery_large"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 12,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/large_station_battery
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 40 SECONDS

// PACMAN generator but epic!!

/datum/design/flatpack_solids_generator
	name = "Flat-Packed S.O.F.I.E. Generator"
	desc = "A deployable plasma-burning generator capable of outperforming even upgraded P.A.C.M.A.N. type generators, \
		at expense of creating hot carbon dioxide exhaust."
	id = "flatpack_fuel_generator"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/fuel_generator
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 30 SECONDS

// Buildable RTG that is quite radioactive

/datum/design/flatpack_rtg
	name = "Flat-Packed Radioisotope Thermoelectric Generator"
	desc = "A deployable radioisotope generator capable of producing a practically free trickle of power. \
		Free if you can tolerate the radiation that the machine makes while deployed, that is."
	id = "flatpack_rtg"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/rtg
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 30 SECONDS

// Thermomachine with decent temperature change rate, but a limited max/min temperature

/datum/design/flatpack_thermomachine
	name = "Flat-Packed Atmospheric Temperature Regulator"
	desc = "A deployable temperature control device for use with atmospherics pipe systems. \
		Limited in its temperature range, however comes with a higher than normal heat capacity."
	id = "flatpack_thermo"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/thermomachine
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_ATMOS,
	)
	construction_time = 20 SECONDS

// Ore silo except it beeps

/datum/design/flatpack_ore_silo
	name = "Flat-Packed Ore Silo"
	desc = "An all-in-one materials management solution. Connects resource-using machines \
		through a network of distrobution systems."
	id = "flatpack_ore_silo"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
	)
	build_path = /obj/item/flatpacked_machine/ore_silo
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_MATERIALS,
	)
	construction_time = 1 MINUTES

// Wind turbine, produces tiny amounts of power when placed outdoors in an atmosphere, but makes significantly more if there's a storm in that area

/datum/design/flatpack_turbine_team_fortress_two
	name = "Flat-Packed Miniature Wind Turbine"
	desc = "A deployable fabricator capable of producing other flat-packed machines and other special equipment tailored for \
		rapidly constructing functional structures given resources and power. While it cannot be upgraded, it can be repacked \
		and moved to any location you see fit. This one makes specialized engineering designs and tools."
	id = "flatpack_turbine_team_fortress_two"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/flatpacked_machine/wind_turbine
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 30 SECONDS

// Stirling generator, kinda like a TEG but on a smaller scale and producing less insane amounts of power

/datum/design/flatpack_bootleg_teg
	name = "Flat-Packed Stirling Generator"
	desc = "An industrial scale stirling generator. Stirling generators operate by intaking \
		hot gasses through their inlet pipes, and being cooled by the ambient air around them. \
		The cycling compression and expansion that this creates creates power, and this one is made \
		to make power on the scale of small stations and outposts."
	id = "flatpack_bootleg_teg"
	build_type = COLONY_FABRICATOR
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5,
	)
	build_path = /obj/item/flatpacked_machine/stirling_generator
	category = list(
		RND_CATEGORY_INITIAL,
		FABRICATOR_CATEGORY_FLATPACK_MACHINES + FABRICATOR_SUBCATEGORY_POWER,
	)
	construction_time = 2 MINUTES

#undef FABRICATOR_CATEGORY_FLATPACK_MACHINES
#undef FABRICATOR_SUBCATEGORY_MANUFACTURING
#undef FABRICATOR_SUBCATEGORY_POWER
#undef FABRICATOR_SUBCATEGORY_MATERIALS
#undef FABRICATOR_SUBCATEGORY_ATMOS

/datum/techweb_node/colony_fabricator_special_tools
	id = "colony_fabricator_tools"
	display_name = "Colony Fabricator Tool Designs"
	description = "Contains all of the colony fabricator's tool designs."
	design_ids = list(
		"colony_power_drive",
		"colony_prybar",
		"colony_arc_welder",
		"colony_compact_drill",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000000000000000) // God save you
	hidden = TRUE
	show_on_wiki = FALSE
	starting_node = TRUE

// Screw-Wrench-Wirecutter combo machine

/datum/design/colony_power_driver
	name = "Powered Driver"
	id = "colony_power_drive"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/screwdriver/omni_drill
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)

// Crowbar that is completely normal except it can force doors

/datum/design/colony_door_crowbar
	name = "Prybar"
	id = "colony_prybar"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/crowbar/large/doorforcer
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)

// Welder that takes no fuel or power to run but is quite slow, at least it sounds cool as hell

/datum/design/colony_arc_welder
	name = "Arc Welder"
	id = "colony_arc_welder"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/weldingtool/electric/arc_welder
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING_ADVANCED,
	)

// Slightly slower drill that fits in backpacks

/datum/design/colony_compact_drill
	name = "Compact Mining Drill"
	id = "colony_compact_drill"
	build_type = COLONY_FABRICATOR
	build_path = /obj/item/pickaxe/drill/compact
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MINING,
	)
