

////////////////////////////////////////////////KEBABS////////////////////////////////////////////////

/datum/table_recipe/humankebab
	name = "Human kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain/human = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/kebab/human

/datum/table_recipe/kebab
	name = "Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/kebab/monkey

/datum/table_recipe/tofukebab
	name = "Tofu kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/kebab/tofu

// see code/module/crafting/table.dm

////////////////////////////////////////////////FISH////////////////////////////////////////////////

/datum/table_recipe/cubancarp
	name = "Cuban carp"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubancarp

/datum/table_recipe/fishandchips
	name = "Fish and chips"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries = 1,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishandchips

/datum/table_recipe/fishfingers
	name = "Fish fingers"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishfingers

/datum/table_recipe/sashimi
	name = "Sashimi"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs = 1,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sashimi

////////////////////////////////////////////////MR SPIDER////////////////////////////////////////////////

/datum/table_recipe/spidereggsham
	name = "Spider eggs ham"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet/spider = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spidereggsham

////////////////////////////////////////////////MISC RECIPE's////////////////////////////////////////////////

/datum/table_recipe/cornedbeef
	name = "Corned beef"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cornedbeef

/datum/table_recipe/bearsteak
	name = "Filet migrawr"
	reqs = list(
		/datum/reagent/consumable/ethanol/manly_dorf = 5,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/bear = 1,
		/obj/item/weapon/lighter/grayscale
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/bearsteak

/datum/table_recipe/wingfangchu
	name = "Wingfangchu"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet/xeno = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wingfangchu

/datum/table_recipe/enchiladas
	name = "Enchiladas"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/cutlet = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/enchiladas

/datum/table_recipe/stewedsoymeat
	name = "Stewed soymeat"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat

/datum/table_recipe/sausage
	name = "Sausage"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sausage
