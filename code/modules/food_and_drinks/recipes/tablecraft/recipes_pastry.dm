
// see code/module/crafting/table.dm

////////////////////////////////////////////////DONUTS////////////////////////////////////////////////

/datum/crafting_recipe/food/chaosdonut
	name = "Chaos donut"
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donut
	time = 15
	name = "Donut"
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/jellydonut
	name = "Jelly donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cherryjellydonut
	name = "Cherry jelly donut"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly/cherryjelly
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/slimejellydonut
	name = "Slime jelly donut"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly/slimejelly
	subcategory = CAT_PASTRY

////////////////////////////////////////////////WAFFLES////////////////////////////////////////////////

/datum/crafting_recipe/food/waffles
	time = 15
	name = "Waffles"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/waffles
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/soylenviridians
	name = "Soylent viridians"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/soylentgreen
	name = "Soylent green"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2,
		/obj/item/weapon/reagent_containers/food/snacks/meat/slab/human = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/rofflewaffles
	name = "Roffle waffles"
	reqs = list(
		/datum/reagent/mushroomhallucinogen = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	subcategory = CAT_PASTRY

////////////////////////////////////////////////DONKPOCCKETS////////////////////////////////////////////////

/datum/crafting_recipe/food/donkpocket
	time = 15
	name = "Donkpocket"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/dankpocket
	time = 15
	name = "Dankpocket"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cannabis = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/dankpocket
	subcategory = CAT_PASTRY

////////////////////////////////////////////////MUFFINS////////////////////////////////////////////////

/datum/crafting_recipe/food/muffin
	time = 15
	name = "Muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/berrymuffin
	name = "Berry muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/booberrymuffin
	name = "Booberry muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = 1,
		/obj/item/weapon/ectoplasm = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/chawanmushi
	name = "Chawanmushi"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	subcategory = CAT_PASTRY

////////////////////////////////////////////OTHER////////////////////////////////////////////

/datum/crafting_recipe/food/hotdog
	name = "Hot dog"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/sausage = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotdog
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/meatbun
	name = "Meat bun"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/khachapuri
	name = "Khachapuri"
	reqs = list(
		/datum/reagent/consumable/eggyolk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/khachapuri
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/sugarcookie
	time = 15
	name = "Sugar cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/fortunecookie
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
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/poppypretzel
	time = 15
	name = "Poppy pretzel"
	reqs = list(
		/obj/item/seeds/poppy = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/plumphelmetbiscuit
	time = 15
	name = "Plumphelmet biscuit"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cracker
	time = 15
	name = "Cracker"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cracker
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/chococornet
	name = "Choco cornet"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chococornet
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oatmealcookie
	name = "Oatmeal cookie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/oatmealcookie

/datum/crafting_recipe/food/raisincookie
	name = "Raisin cookie"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/raisincookie
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cherrycupcake
	name = "Cherry cupcake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cherrycupcake
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/bluecherrycupcake
	name = "Blue cherry cupcake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/bluecherrycupcake
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/honeybun
	name = "Honey bun"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/honeybun
	subcategory = CAT_PASTRY
