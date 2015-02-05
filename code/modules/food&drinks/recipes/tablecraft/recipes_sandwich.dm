
// see code/datums/recipe.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/table_recipe/sandwich/plain
	name = "Sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich
/*
/datum/table_recipe/sandwich/toasted
	name = "Toasted sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/sandwich = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
*/
/datum/table_recipe/sandwich/grilledcheese
	name = "Grilled cheese sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese

/datum/table_recipe/sandwich/slime
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/datum/table_recipe/sandwich/cherry
	name = "Cherry jelly sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

/datum/table_recipe/sandwich/icecream
	name = "Icecream sandwich"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/ice = 5,
		/obj/item/weapon/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
