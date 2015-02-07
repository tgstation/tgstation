
// see code/module/crafting/table.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////

/datum/table_recipe/tomatopasta
	name = "Tomato pasta"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/table_recipe/copypasta
	name = "Copypasta"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta

/datum/table_recipe/spaghettimeatball
	name = "Spaghetti meatball"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti

/datum/table_recipe/spesslaw
	name = "Spesslaw"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 4
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw


