
// see code/module/crafting/table.dm

////////////////////////////////////////////////EGG RECIPE's////////////////////////////////////////////////

/datum/table_recipe/friedegg
	name = "Fried egg"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedegg

/datum/table_recipe/omelette
	name = "omelette"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/omelette

/datum/table_recipe/chocolateegg
	name = "Chocolate egg"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolateegg

/datum/table_recipe/eggsbenedict
	name = "Eggs benedict"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/benedict
