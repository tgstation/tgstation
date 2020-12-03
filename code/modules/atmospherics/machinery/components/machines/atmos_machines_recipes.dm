GLOBAL_LIST_INIT(gas_recipe_meta, gas_recipes_list())
#define META_RECIPE_ID 1
#define META_RECIPE_NAME 2
#define META_RECIPE_MIN_TEMP 3
#define META_RECIPE_MAX_TEMP 4
#define META_RECIPE_REQUIREMENTS 5
#define META_RECIPE_CATALYSTS 6
#define META_RECIPE_PRODUCTS 7

/proc/gas_recipes_list()
	. = subtypesof(/datum/gas_recipe)
	for(var/recipe_path in .)
		var/list/recipe_info = new(7)
		var/datum/gas_recipe/recipe = recipe_path

		recipe_info[META_RECIPE_ID] = initial(recipe.id)
		recipe_info[META_RECIPE_NAME] = initial(recipe.name)
		recipe_info[META_RECIPE_MIN_TEMP] = initial(recipe.min_temp)
		recipe_info[META_RECIPE_MAX_TEMP] = initial(recipe.max_temp)

		recipe_info[META_RECIPE_REQUIREMENTS] = list()
		recipe_info[META_RECIPE_CATALYSTS] = list()
		recipe_info[META_RECIPE_PRODUCTS] = list()

		for(var/datum/gas/gas in initial(recipe.requirements))
			recipe_info[META_RECIPE_REQUIREMENTS] += gas
		for(var/datum/gas/gas in initial(recipe.catalysts))
			recipe_info[META_RECIPE_CATALYSTS] += gas
		for(var/obj/item/item in initial(recipe.products))
			recipe_info[META_RECIPE_PRODUCTS] += item
		.[recipe_path] = recipe_info


/datum/gas_recipe
	var/id = ""
	var/name = ""
	var/min_temp = TCMB
	var/max_temp = INFINITY
	var/list/requirements = new/list()
	var/list/catalysts = new/list()
	var/list/products = new/list()

/datum/gas_recipe/test1
	id = "test1"
	name = "Test1"
	min_temp = 200
	max_temp = 500
	requirements = list(/datum/gas/hydrogen = 100, /datum/gas/plasma = 100)
	catalysts = list(/datum/gas/bz = 50)
	products = list(/obj/item/stack/sheet/mineral/metal_hydrogen = 1)

/datum/gas_recipe/test2
	id = "test2"
	name = "Test2"
	min_temp = 500
	max_temp = 700
	requirements = list(/datum/gas/bz = 100, /datum/gas/oxygen = 100)
	products = list(/obj/item/stack/sheet/animalhide/goliath_hide = 5)
