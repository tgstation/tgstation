
// see code/datums/recipe.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////
/*
/datum/table_recipe/spaghetti/boiled
	name = "Boiled spaghetti"
	reqs = list(
		/datum/reagent/water = 5,
		/obj/item/weapon/reagent_containers/food/snacks/spaghetti = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
*/
/datum/table_recipe/spaghetti/pastatomato
	name = "Tomato pasta"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/table_recipe/spaghetti/copypasta
	name = "Copypasta"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta

/datum/table_recipe/spaghetti/meatball
	name = "Spaghetti meatball"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti

/datum/table_recipe/spaghetti/spesslaw
	name = "Spesslaw"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 4
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw


