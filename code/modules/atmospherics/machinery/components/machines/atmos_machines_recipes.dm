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
	requirements = list(/datum/gas_mixture/hydrogen = 100, /datum/gas_mixture/plasma = 100)
	catalyst = list(/datum/gas_mixture/bz = 50)
	products = list(/obj/item/stack/sheet/mineral/metal_hydrogen = 1)
