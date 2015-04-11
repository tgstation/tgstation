
// see code/datums/recipe.dm


// see code/module/crafting/table.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/table_recipe/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich

/datum/table_recipe/grilledcheesesandwich
	name = "Grilled cheese sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese

/datum/table_recipe/slimesandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/datum/table_recipe/cherrysandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

/datum/table_recipe/icecreamsandwich
	name = "Icecream sandwich"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/ice = 5,
		/obj/item/weapon/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich

/datum/table_recipe/notasandwich
	name = "Not a sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich



