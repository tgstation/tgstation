

// see code/module/crafting/table.dm

////////////////////////////////////////////////DOUGH////////////////////////////////////////////////

//these recipes can also be done with attackby.

/datum/table_recipe/cakebatter
	name = "Cake Batter"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/dough = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cakebatter

/datum/table_recipe/cakebatter/alt
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/dough = 1
	)

/datum/table_recipe/piedough
	name = "Pie Dough"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/flatdough = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/piedough

/datum/table_recipe/piedough/alt
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/flatdough = 1
	)

/datum/table_recipe/rawpastrybase
	name = "Raw Pastry Base"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/doughslice = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/rawpastrybase

/datum/table_recipe/rawpastrybase/alt
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/doughslice = 1
	)




