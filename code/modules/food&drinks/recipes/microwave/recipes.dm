
// see code/datums/recipe.dm

////////////////////////////////////////////////FOOD ADDITTIONS////////////////////////////////////////////////

/datum/recipe/wrap
	reagents = list("soysauce" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/recipe/beans
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/beans

////////////////////////////////////////////////MISC RECIPE's////////////////////////////////////////////////

/datum/recipe/loadedbakedpotato
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/popcorn
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn

/datum/recipe/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("amatoxin")
		return being_cooked

/datum/recipe/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedapple
