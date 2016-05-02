
// see code/module/crafting/table.dm

////////////////////////////////////////////////DONUTS////////////////////////////////////////////////

/datum/table_recipe/chaosdonut
	name = "Chaos donut"
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	category = CAT_FOOD

/datum/table_recipe/donut
	time = 15
	name = "Donut"
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut
	category = CAT_FOOD

/datum/table_recipe/jellydonut
	name = "Jelly donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	category = CAT_FOOD

/datum/table_recipe/cherryjellydonut
	name = "Cherry jelly donut"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly/cherryjelly
	category = CAT_FOOD

/datum/table_recipe/slimejellydonut
	name = "Slime jelly donut"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly/slimejelly
	category = CAT_FOOD

////////////////////////////////////////////////WAFFLES////////////////////////////////////////////////

/datum/table_recipe/waffles
	time = 15
	name = "Waffles"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/waffles
	category = CAT_FOOD


/datum/table_recipe/soylenviridians
	name = "Soylent viridians"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	category = CAT_FOOD

/datum/table_recipe/soylentgreen
	name = "Soylent green"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2,
		/obj/item/weapon/reagent_containers/food/snacks/meat/slab/human = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	category = CAT_FOOD


/datum/table_recipe/rofflewaffles
	name = "Roffle waffles"
	reqs = list(
		/datum/reagent/mushroomhallucinogen = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	category = CAT_FOOD

////////////////////////////////////////////////DONKPOCCKETS////////////////////////////////////////////////

/datum/table_recipe/donkpocket
	time = 15
	name = "Donkpocket"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket
	category = CAT_FOOD


////////////////////////////////////////////////MUFFINS////////////////////////////////////////////////

/datum/table_recipe/muffin
	time = 15
	name = "Muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin
	category = CAT_FOOD

/datum/table_recipe/berrymuffin
	name = "Berry muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	category = CAT_FOOD

/datum/table_recipe/booberrymuffin
	name = "Booberry muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1,
		/obj/item/weapon/ectoplasm = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	category = CAT_FOOD

/datum/table_recipe/chawanmushi
	name = "Chawanmushi"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	category = CAT_FOOD

////////////////////////////////////////////OTHER////////////////////////////////////////////

/datum/table_recipe/hotdog
	name = "Hot dog"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/sausage = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotdog
	category = CAT_FOOD

/datum/table_recipe/meatbun
	name = "Meat bun"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun
	category = CAT_FOOD

/datum/table_recipe/sugarcookie
	time = 15
	name = "Sugar cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	category = CAT_FOOD

/datum/table_recipe/fortunecookie
	time = 15
	name = "Fortune cookie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/paper = 1
	)
	parts =	list(
		/obj/item/weapon/paper = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	category = CAT_FOOD

/datum/table_recipe/poppypretzel
	time = 15
	name = "Poppy pretzel"
	reqs = list(
		/obj/item/seeds/poppy = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	category = CAT_FOOD

/datum/table_recipe/plumphelmetbiscuit
	time = 15
	name = "Plumphelmet biscuit"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	category = CAT_FOOD

/datum/table_recipe/cracker
	time = 15
	name = "Cracker"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cracker
	category = CAT_FOOD

/datum/table_recipe/chococornet
	name = "Choco cornet"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chococornet
	category = CAT_FOOD

/datum/table_recipe/oatmealcookie
	name = "Oatmeal cookie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/oatmealcookie

/datum/table_recipe/raisincookie
	name = "Raisin cookie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/raisincookie
	category = CAT_FOOD

/datum/table_recipe/cherrycupcake
	name = "Cherry cupcake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cherrycupcake
	category = CAT_FOOD

/datum/table_recipe/bluecherrycupcake
	name = "Blue cherry cupcake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/bluecherrycupcake
	category = CAT_FOOD

/datum/table_recipe/honeybun
	name = "Honey bun"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/honeybun
	category = CAT_FOOD