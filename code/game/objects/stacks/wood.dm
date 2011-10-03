/*
CONTAINS:
WOOD PLANKS
*/

var/global/list/datum/stack_recipe/wood_recipes = list ( \
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/wood, 2), \
	new/datum/stack_recipe("wooden barricade", /obj/station_objects/barricade/wooden, 5, time = 30, one_per_turf = 1, on_floor = 1),\
	)

/obj/item/stack/sheet/wood
	New(var/loc, var/amount=null)
		recipes = wood_recipes
		return ..()