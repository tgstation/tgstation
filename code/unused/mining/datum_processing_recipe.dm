/**********************Ore to material recipes datum**************************/

var/list/AVAILABLE_ORES = typesof(/obj/item/weapon/ore)

/datum/material_recipe
	var/name
	var/list/obj/item/weapon/ore/recipe
	var/obj/prod_type  //produced material/object type

	New(var/param_name, var/param_recipe, var/param_prod_type)
		name = param_name
		recipe = param_recipe
		prod_type = param_prod_type

var/list/datum/material_recipe/MATERIAL_RECIPES = list(
		new/datum/material_recipe("Metal",list(/obj/item/weapon/ore/iron),/obj/item/stack/sheet/metal),
		new/datum/material_recipe("Glass",list(/obj/item/weapon/ore/glass),/obj/item/stack/sheet/glass),
		new/datum/material_recipe("Gold",list(/obj/item/weapon/ore/gold),/obj/item/stack/sheet/gold),
		new/datum/material_recipe("Silver",list(/obj/item/weapon/ore/silver),/obj/item/stack/sheet/silver),
		new/datum/material_recipe("Diamond",list(/obj/item/weapon/ore/diamond),/obj/item/stack/sheet/diamond),
		new/datum/material_recipe("Plasma",list(/obj/item/weapon/ore/plasma),/obj/item/stack/sheet/plasma),
		new/datum/material_recipe("Bananium",list(/obj/item/weapon/ore/clown),/obj/item/stack/sheet/clown),
	)