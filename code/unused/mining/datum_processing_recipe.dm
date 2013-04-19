/**********************Ore to material recipes datum**************************/

var/list/AVAILABLE_ORES = typesof(/obj/item/mining/ore)

/datum/material_recipe
	var/name
	var/list/obj/item/mining/ore/recipe
	var/obj/prod_type  //produced material/object type

	New(var/param_name, var/param_recipe, var/param_prod_type)
		name = param_name
		recipe = param_recipe
		prod_type = param_prod_type

var/list/datum/material_recipe/MATERIAL_RECIPES = list(
		new/datum/material_recipe("Metal",list(/obj/item/mining/ore/iron),/obj/item/part/stack/sheet/metal),
		new/datum/material_recipe("Glass",list(/obj/item/mining/ore/glass),/obj/item/part/stack/sheet/glass),
		new/datum/material_recipe("Gold",list(/obj/item/mining/ore/gold),/obj/item/part/stack/sheet/mineral/gold),
		new/datum/material_recipe("Silver",list(/obj/item/mining/ore/silver),/obj/item/part/stack/sheet/mineral/silver),
		new/datum/material_recipe("Diamond",list(/obj/item/mining/ore/diamond),/obj/item/part/stack/sheet/mineral/diamond),
		new/datum/material_recipe("Plasma",list(/obj/item/mining/ore/plasma),/obj/item/part/stack/sheet/mineral/plasma),
		new/datum/material_recipe("Bananium",list(/obj/item/mining/ore/clown),/obj/item/part/stack/sheet/mineral/clown),
	)