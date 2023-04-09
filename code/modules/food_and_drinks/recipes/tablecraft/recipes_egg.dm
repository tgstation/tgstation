
// see code/module/crafting/table.dm

////////////////////////////////////////////////EGG RECIPE's////////////////////////////////////////////////

/datum/crafting_recipe/food/sausageegg
	name = "Egg with sausage"
	reqs = list(
		/obj/item/food/sausage = 1,
		/obj/item/food/friedegg = 1,
	)
	result = /obj/item/food/eggsausage
	category = CAT_EGG

/datum/crafting_recipe/food/omelette
	name = "Omelette"
	reqs = list(
		/obj/item/food/egg = 2,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/omelette
	category = CAT_EGG

/datum/crafting_recipe/food/chocolateegg
	name = "Chocolate egg"
	reqs = list(
		/obj/item/food/boiledegg = 1,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chocolateegg
	category = CAT_EGG

/datum/crafting_recipe/food/eggsbenedict
	name = "Eggs benedict"
	reqs = list(
		/obj/item/food/friedegg = 1,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/breadslice/plain = 1,
	)
	result = /obj/item/food/benedict
	category = CAT_EGG

/datum/crafting_recipe/food/eggbowl
	name = "Egg bowl"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1
	)
	result = /obj/item/food/salad/eggbowl
	category = CAT_EGG

/datum/crafting_recipe/food/wrap
	name = "Egg Wrap"
	reqs = list(/datum/reagent/consumable/soysauce = 10,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/eggwrap
	category = CAT_EGG

/datum/crafting_recipe/food/chawanmushi
	name = "Chawanmushi"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/boiledegg = 2,
		/obj/item/food/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/food/chawanmushi
	category = CAT_EGG

