
// see code/module/crafting/table.dm

////////////////////////////////////////////////SALADS////////////////////////////////////////////////

/datum/table_recipe/herbsalad
	name = "Herb salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/herbsalad

/datum/table_recipe/aesirsalad
	name = "Aesir salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/aesirsalad

/datum/table_recipe/validsalad
	name = "Valid salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/validsalad

/datum/table_recipe/monkeysdelight
	name = "Monkeys delight"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/monkeysdelight

/datum/table_recipe/oatmeal
	name = "Oatmeal"
	reqs = list(
		/datum/reagent/consumable/milk = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/oatmeal

/datum/table_recipe/fruitsalad
	name = "Fruit salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = 1,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = 2

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/fruit

/datum/table_recipe/junglesalad
	name = "Jungle salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 2,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = 2

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/jungle

/datum/table_recipe/citrusdelight
	name = "Citrus delight"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 1

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/citrusdelight

/datum/table_recipe/ricepork
	name = "Rice and pork"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/ricepork

/datum/table_recipe/eggbowl
	name = "Egg bowl"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/eggbowl

/datum/table_recipe/ricepudding
	name = "Rice pudding"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/ricepudding
