
////////////////////////////////////////////////EGG RECIPE's////////////////////////////////////////////////

/datum/table_recipe/egg/fried
	name = "Fried egg"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedegg
/*
/datum/recipe/egg/boiled
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledegg
*/
/datum/table_recipe/egg/omelette
	name = "omelette"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/omelette

/datum/table_recipe/egg/chocolate
	name = "Chocolate egg"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolateegg

/datum/table_recipe/egg/benedict
	name = "Eggs benedict"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/benedict
