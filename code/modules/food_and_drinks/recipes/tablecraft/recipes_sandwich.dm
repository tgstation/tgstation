
// see code/datums/recipe.dm


// see code/module/crafting/table.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/crafting_recipe/food/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/grilledcheesesandwich
	name = "Grilled cheese sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	category = CAT_SANDWICH

/datum/crafting_recipe/food/slimesandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cherrysandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	category = CAT_SANDWICH

/datum/crafting_recipe/food/icecreamsandwich
	name = "Icecream sandwich"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/ice = 5,
		/obj/item/weapon/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/notasandwich
	name = "Not a sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich
	category = CAT_SANDWICH



