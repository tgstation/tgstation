
// see code/module/crafting/table.dm

////////////////////////////////////////////////SALADS////////////////////////////////////////////////

/datum/crafting_recipe/food/herbsalad
	name = "Herb salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/herbsalad
	category = CAT_SALAD

/datum/crafting_recipe/food/aesirsalad
	name = "Aesir salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/aesirsalad
	category = CAT_SALAD

/datum/crafting_recipe/food/validsalad
	name = "Valid salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/validsalad
	category = CAT_SALAD

/datum/crafting_recipe/food/monkeysdelight
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
	category = CAT_SALAD

/datum/crafting_recipe/food/oatmeal
	name = "Oatmeal"
	reqs = list(
		/datum/reagent/consumable/milk = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/oatmeal
	category = CAT_SALAD

/datum/crafting_recipe/food/fruitsalad
	name = "Fruit salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = 1,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = 2

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/fruit
	category = CAT_SALAD

/datum/crafting_recipe/food/junglesalad
	name = "Jungle salad"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 2,
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = 2

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/jungle
	category = CAT_SALAD

/datum/crafting_recipe/food/citrusdelight
	name = "Citrus delight"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 1

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/citrusdelight
	category = CAT_SALAD

/datum/crafting_recipe/food/ricepork
	name = "Rice and pork"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/ricepork
	category = CAT_SALAD

/datum/crafting_recipe/food/eggbowl
	name = "Egg bowl"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/eggbowl
	category = CAT_SALAD

/datum/crafting_recipe/food/ricepudding
	name = "Rice pudding"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/salad/ricepudding
	category = CAT_SALAD
