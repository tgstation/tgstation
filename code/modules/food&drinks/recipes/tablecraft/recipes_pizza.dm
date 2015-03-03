
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/table_recipe/margheritapizza
	name = "Margherita pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 4,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/margherita

/datum/table_recipe/meatpizza
	name = "Meat pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet = 4,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/meatpizza

/datum/table_recipe/mushroompizza
	name = "Mushroom pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom = 5
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/mushroompizza

/datum/table_recipe/vegetablepizza
	name = "Vegetable pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/vegetablepizza


