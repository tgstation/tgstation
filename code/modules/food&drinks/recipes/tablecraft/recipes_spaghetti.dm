
// see code/module/crafting/table.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////

/datum/table_recipe/tomatopasta
	name = "Tomato pasta"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato
	category = CAT_FOOD

/datum/table_recipe/copypasta
	name = "Copypasta"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta
	category = CAT_FOOD

/datum/table_recipe/spaghettimeatball
	name = "Spaghetti meatball"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	category = CAT_FOOD

/datum/table_recipe/spesslaw
	name = "Spesslaw"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 4
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw
	category = CAT_FOOD

/datum/table_recipe/beefnoodle
	name = "Beef noodle"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/beefnoodle
	category = CAT_FOOD

/datum/table_recipe/chowmein
	name = "Chowmein"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chowmein
	category = CAT_FOOD