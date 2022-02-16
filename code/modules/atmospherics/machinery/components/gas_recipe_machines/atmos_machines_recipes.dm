///Global list of recipes for atmospheric machines to use
GLOBAL_LIST_INIT(gas_recipe_meta, gas_recipes_list())

/*
 * Global proc to build the gas recipe global list
 */
/proc/gas_recipes_list()
	. = list()
	for(var/recipe_path in subtypesof(/datum/gas_recipe))
		var/datum/gas_recipe/recipe = new recipe_path()

		.[recipe.id] = recipe

/datum/gas_recipe
	///Id of the recipe for easy identification in the code
	var/id = ""
	///What machine the recipe is for
	var/machine_type = ""
	///Displayed name of the recipe
	var/name = ""
	///Minimum temperature for the recipe
	var/min_temp = TCMB
	///Maximum temperature for the recipe
	var/max_temp = INFINITY
	/**
	 * Amount of thermal energy released/consumed by the reaction.
	 * Positive numbers make the reaction release energy (exothermic) while negative numbers make the reaction consume energy (endothermic).
	 */
	var/energy_release = 0
	var/dangerous = FALSE
	///Gas required for the recipe to work
	var/list/requirements
	///Products made from the recipe
	var/list/products

/datum/gas_recipe/crystallizer
	machine_type = "Crystallizer"

/datum/gas_recipe/crystallizer/hypern_crystalium
	id = "hyper_crystalium"
	name = "Hypernoblium Crystal"
	min_temp = 3
	max_temp = 250
	energy_release = -250000
	requirements = list(/datum/gas/oxygen = 2000, /datum/gas/hypernoblium = 175)
	products = list(/obj/item/hypernoblium_crystal = 1)

/datum/gas_recipe/crystallizer/metallic_hydrogen
	id = "metal_h"
	name = "Metallic hydrogen"
	min_temp = 50000
	max_temp = 150000
	energy_release = -2500000
	requirements = list(/datum/gas/hydrogen = 300, /datum/gas/bz = 50)
	products = list(/obj/item/stack/sheet/mineral/metal_hydrogen = 1)

/datum/gas_recipe/crystallizer/healium_grenade
	id = "healium_g"
	name = "Healium crystal"
	min_temp = 200
	max_temp = 400
	energy_release = -2000000
	requirements = list(/datum/gas/healium = 100, /datum/gas/oxygen = 120, /datum/gas/plasma = 50)
	products = list(/obj/item/grenade/gas_crystal/healium_crystal = 1)

/datum/gas_recipe/crystallizer/proto_nitrate_grenade
	id = "proto_nitrate_g"
	name = "Proto nitrate crystal"
	min_temp = 200
	max_temp = 400
	energy_release = 1500000
	requirements = list(/datum/gas/proto_nitrate = 100, /datum/gas/nitrogen = 80, /datum/gas/oxygen = 80)
	products = list(/obj/item/grenade/gas_crystal/proto_nitrate_crystal = 1)

/datum/gas_recipe/crystallizer/hot_ice
	id = "hot_ice"
	name = "Hot ice"
	min_temp = 15
	max_temp = 35
	energy_release = -3000000
	requirements = list(/datum/gas/freon = 60, /datum/gas/plasma = 160, /datum/gas/oxygen = 80)
	products = list(/obj/item/stack/sheet/hot_ice = 1)

/datum/gas_recipe/crystallizer/ammonia_crystal
	id = "ammonia_crystal"
	name = "Ammonia crystal"
	min_temp = 200
	max_temp = 240
	energy_release = 950000
	requirements = list(/datum/gas/hydrogen = 50, /datum/gas/nitrogen = 40)
	products = list(/obj/item/stack/ammonia_crystals = 2)

/datum/gas_recipe/crystallizer/shard
	id = "crystal_shard"
	name = "Supermatter crystal shard"
	min_temp = TCMB
	max_temp = 5
	energy_release = 150000000
	dangerous = TRUE
	requirements = list(/datum/gas/hypernoblium = 250, /datum/gas/antinoblium = 250, /datum/gas/bz = 200, /datum/gas/plasma = 5000, /datum/gas/oxygen = 4500)
	products = list(/obj/machinery/power/supermatter_crystal/shard = 1)

/datum/gas_recipe/crystallizer/n2o_crystal
	id = "n2o_crystal"
	name = "Nitrous oxide crystal"
	min_temp = 50
	max_temp = 350
	energy_release = 3500000
	requirements = list(/datum/gas/nitrous_oxide = 150, /datum/gas/bz = 30)
	products = list(/obj/item/grenade/gas_crystal/nitrous_oxide_crystal = 1)

/datum/gas_recipe/crystallizer/diamond
	id = "diamond"
	name = "Diamond"
	min_temp = 10000
	max_temp = 30000
	energy_release = 9500000
	requirements = list(/datum/gas/carbon_dioxide = 1500)
	products = list(/obj/item/stack/sheet/mineral/diamond = 1)

/datum/gas_recipe/crystallizer/plasma_sheet
	id = "plasma_sheet"
	name = "Plasma sheet"
	min_temp = 10
	max_temp = 20
	energy_release = 3500000
	requirements = list(/datum/gas/plasma = 450)
	products = list(/obj/item/stack/sheet/mineral/plasma = 1)

/datum/gas_recipe/crystallizer/crystal_cell
	id = "crystal_cell"
	name = "Crystal Cell"
	min_temp = 50
	max_temp = 90
	energy_release = -800000
	requirements = list(/datum/gas/plasma = 800, /datum/gas/helium = 100, /datum/gas/bz = 50)
	products = list(/obj/item/stock_parts/cell/crystal_cell = 1)

/datum/gas_recipe/crystallizer/zaukerite
	id = "zaukerite"
	name = "Zaukerite sheet"
	min_temp = 5
	max_temp = 20
	energy_release = 2900000
	requirements = list(/datum/gas/antinoblium = 5, /datum/gas/zauker = 20, /datum/gas/bz = 7.5)
	products = list(/obj/item/stack/sheet/mineral/zaukerite = 2)

/datum/gas_recipe/crystallizer/fuel_pellet
	id = "fuel_basic"
	name = "standard fuel pellet"
	energy_release = -6000000
	requirements = list(/datum/gas/oxygen = 50, /datum/gas/plasma = 100)
	products = list(/obj/item/fuel_pellet = 1)

/datum/gas_recipe/crystallizer/fuel_pellet_advanced
	id = "fuel_advanced"
	name = "advanced fuel pellet"
	energy_release = -6000000
	requirements = list(/datum/gas/tritium = 100, /datum/gas/hydrogen = 100)
	products = list(/obj/item/fuel_pellet/advanced = 1)

/datum/gas_recipe/crystallizer/fuel_pellet_exotic
	id = "fuel_exotic"
	name = "exotic fuel pellet"
	energy_release = -6000000
	requirements = list(/datum/gas/hypernoblium = 100, /datum/gas/nitrium = 100)
	products = list(/obj/item/fuel_pellet/exotic = 1)

/datum/gas_recipe/crystallizer/crystal_foam
	id = "crystal_foam"
	name = "Crystal foam grenade"
	energy_release = 140000
	requirements = list(/datum/gas/carbon_dioxide = 150, /datum/gas/nitrous_oxide = 100, /datum/gas/water_vapor = 25)
	products = list(/obj/item/grenade/gas_crystal/crystal_foam = 1)

/datum/gas_recipe/crystallizer/crystallized_nitrium
	id = "crystallized_nitrium"
	name = "Nitrium crystal"
	min_temp = 10
	max_temp = 25
	energy_release = -45000
	requirements = list(/datum/gas/nitrium = 150, /datum/gas/oxygen = 70, /datum/gas/bz = 50)
	products = list(/obj/item/nitrium_crystal = 1)
