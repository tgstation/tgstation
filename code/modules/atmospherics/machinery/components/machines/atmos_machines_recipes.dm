GLOBAL_LIST_INIT(gas_recipe_meta, gas_recipes_list())
#define META_RECIPE_ID 1
#define META_RECIPE_MACHINE_TYPE 2
#define META_RECIPE_NAME 3
#define META_RECIPE_MIN_TEMP 4
#define META_RECIPE_MAX_TEMP 5
#define META_RECIPE_REACTION_TYPE 6
#define META_RECIPE_ENERGY_RELEASE 7
#define META_RECIPE_REQUIREMENTS 8
#define META_RECIPE_PRODUCTS 9

/proc/gas_recipes_list()
	. = subtypesof(/datum/gas_recipe)
	for(var/recipe_path in .)
		var/list/recipe_info = new(9)
		var/datum/gas_recipe/recipe = new recipe_path()

		recipe_info[META_RECIPE_ID] = initial(recipe.id)
		recipe_info[META_RECIPE_MACHINE_TYPE] = initial(recipe.machine_type)
		recipe_info[META_RECIPE_NAME] = initial(recipe.name)
		recipe_info[META_RECIPE_MIN_TEMP] = initial(recipe.min_temp)
		recipe_info[META_RECIPE_MAX_TEMP] = initial(recipe.max_temp)
		recipe_info[META_RECIPE_REACTION_TYPE] = initial(recipe.reaction_type)
		recipe_info[META_RECIPE_ENERGY_RELEASE] = initial(recipe.energy_release)
		recipe_info[META_RECIPE_REQUIREMENTS] = recipe.requirements
		recipe_info[META_RECIPE_PRODUCTS] = recipe.products

		.[recipe_path] = recipe_info

/proc/recipe_id2path(id)
	var/list/meta_recipe = GLOB.gas_recipe_meta
	if(id in meta_recipe)
		return id
	for(var/path in meta_recipe)
		if(meta_recipe[path][META_RECIPE_ID] == id)
			return path
	return ""

/datum/gas_recipe
	var/id = ""
	var/machine_type = ""
	var/name = ""
	var/min_temp = TCMB
	var/max_temp = INFINITY
	var/reaction_type = ""
	var/energy_release = 0
	var/list/requirements = new/list()
	var/list/products = new/list()

/datum/gas_recipe/crystallizer
	machine_type = "Crystallizer"

/datum/gas_recipe/crystallizer/metallic_hydrogen
	id = "metal_h"
	name = "Metallic Hydrogen"
	min_temp = 50000
	max_temp = INFINITY
	reaction_type = "endothermic"
	energy_release = 250000
	requirements = list(/datum/gas/hydrogen = 600, /datum/gas/bz = 200)
	products = list(/obj/item/stack/sheet/mineral/metal_hydrogen = 2)

/datum/gas_recipe/crystallizer/healium_grenade
	id = "healium_g"
	name = "Healium Grenade"
	min_temp = 200
	max_temp = 400
	reaction_type = "endothermic"
	energy_release = 150000
	requirements = list(/datum/gas/healium = 400, /datum/gas/freon = 800, /datum/gas/plasma = 50)
	products = list(/obj/item/grenade/gas_crystal/healium_crystal = 1)

/datum/gas_recipe/crystallizer/proto_nitrate_grenade
	id = "proto_nitrate_g"
	name = "Proto Nitrate Grenade"
	min_temp = 200
	max_temp = 400
	reaction_type = "endothermic"
	energy_release = 150000
	requirements = list(/datum/gas/proto_nitrate = 400, /datum/gas/nitrogen = 800, /datum/gas/oxygen = 800)
	products = list(/obj/item/grenade/gas_crystal/proto_nitrate_crystal = 1)

/datum/gas_recipe/crystallizer/hot_ice
	id = "hot_ice"
	name = "Hot ice"
	min_temp = 15
	max_temp = 35
	reaction_type = "endothermic"
	energy_release = 300000
	requirements = list(/datum/gas/freon = 500, /datum/gas/plasma = 400, /datum/gas/oxygen = 300)
	products = list(/obj/item/stack/sheet/hot_ice = 3)


/datum/gas_recipe/crystallizer/ammonia_crystal
	id = "ammonia_crystal"
	name = "Ammonia Crystal"
	min_temp = 200
	max_temp = 240
	reaction_type = "exothermic"
	energy_release = 15000
	requirements = list(/datum/gas/hydrogen = 500, /datum/gas/nitrogen = 400)
	products = list(/obj/item/stack/ammonia_crystals = 4)

/datum/gas_recipe/crystallizer/shard
	id = "crystal_shard"
	name = "Supermatter Crystal Shard"
	min_temp = 2
	max_temp = 4
	reaction_type = "exothermic"
	energy_release = 1500000
	requirements = list(/datum/gas/hypernoblium = 15000, /datum/gas/antinoblium = 1500, /datum/gas/plasma = 5000, /datum/gas/oxygen = 4500)
	products = list(/obj/machinery/power/supermatter_crystal/shard = 1)

/datum/gas_recipe/crystallizer/n2o_crystal
	id = "n2o_crystal"
	name = "Nitrous Oxide Crystal"
	min_temp = 50
	max_temp = 350
	reaction_type = "exothermic"
	energy_release = 350000
	requirements = list(/datum/gas/nitrous_oxide = 800, /datum/gas/bz = 50)
	products = list(/obj/item/grenade/gas_crystal/nitrous_oxide_crystal = 1)

/datum/gas_recipe/crystallizer/diamond
	id = "diamond"
	name = "Diamond"
	min_temp = 10000
	max_temp = INFINITY
	reaction_type = "endothermic"
	energy_release = 650000
	requirements = list(/datum/gas/carbon_dioxide = 10000)
	products = list(/obj/item/stack/sheet/mineral/diamond = 1)
