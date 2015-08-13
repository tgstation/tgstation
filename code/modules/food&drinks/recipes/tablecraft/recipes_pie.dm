
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIES////////////////////////////////////////////////

/datum/table_recipe/bananacreampie
	name = "Banana cream pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		 /obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cream
	category = CAT_FOOD

/datum/table_recipe/meatpie
	name = "Meat pie"
	reqs = list(
		/datum/reagent/consumable/blackpepper = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/meatpie
	category = CAT_FOOD

/datum/table_recipe/tofupie
	name = "Tofu pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/tofupie
	category = CAT_FOOD

/datum/table_recipe/xenopie
	name = "Xeno pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/xeno = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie
	category = CAT_FOOD

/datum/table_recipe/cherrypie
	name = "Cherry pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		 /obj/item/weapon/reagent_containers/food/snacks/grown/cherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie
	category = CAT_FOOD

/datum/table_recipe/berryclafoutis
	name = "Berry clafoutis"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/berryclafoutis
	category = CAT_FOOD

/datum/table_recipe/bearypie
	name = "Beary Pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/steak/bear = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/bearypie
	category = CAT_FOOD

/datum/table_recipe/amanitapie
	name = "Amanita pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie
	category = CAT_FOOD

/datum/table_recipe/plumppie
	name = "Plump pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	category = CAT_FOOD

/datum/table_recipe/applepie
	name = "Apple pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/applepie
	category = CAT_FOOD

/datum/table_recipe/pumpkinpie
	name = "Pumpkin pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/pumpkinpie
	category = CAT_FOOD

/datum/table_recipe/goldenappletart
	name = "Golden apple tart"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/appletart
	category = CAT_FOOD

/datum/table_recipe/blumpkinpie
	name = "Blumpkin pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/blumpkinpie
	category = CAT_FOOD

/datum/table_recipe/dulcedebatata
	name = "Dulce de batata"
	reqs = list(
		/datum/reagent/consumable/vanilla = 5,
		/datum/reagent/water = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/sweetpotato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/dulcedebatata
	category = CAT_FOOD

/datum/table_recipe/frostypie
	name = "Frosty pie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pie/frostypie
	category = CAT_FOOD