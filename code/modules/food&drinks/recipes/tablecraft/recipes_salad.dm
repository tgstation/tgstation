
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
