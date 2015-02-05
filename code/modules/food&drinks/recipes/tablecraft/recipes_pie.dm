
// see code/datums/recipe.dm

////////////////////////////////////////////////PIES////////////////////////////////////////////////

/datum/table_recipe/pie/cream
	name = "Banana cream pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		 /obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cream

/datum/table_recipe/pie/meat
	name = "Meat pie"
	reqs = list(
		/datum/reagent/consumable/blackpepper = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/meatpie

/datum/table_recipe/pie/tofu
	name = "Tofu pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/tofupie

/datum/table_recipe/pie/xemeat
	name = "Xeno pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie

/datum/table_recipe/pie/cherry
	name = "Cherry pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		 /obj/item/weapon/reagent_containers/food/snacks/grown/cherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie

/datum/table_recipe/pie/berryclafoutis
	name = "Berry clafoutis"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/berryclafoutis

/datum/table_recipe/pie/amanita
	name = "Amanita pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie

/datum/table_recipe/pie/plump
	name = "Plump pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie

/datum/table_recipe/pie/apple
	name = "Apple pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/applepie

/datum/table_recipe/pie/pumpkin
	name = "Pumpkin pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpie

/datum/table_recipe/pie/appletart
	name = "Golden apple tart"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/appletart

