
// see code/module/crafting/table.dm

////////////////////////////////////////////////DONUTS////////////////////////////////////////////////

/datum/crafting_recipe/food/donut
	time = 1.5 SECONDS
	name = "Donut"
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/plain
	added_foodtypes = JUNKFOOD|SUGAR|BREAKFAST|FRIED
	removed_foodtypes = RAW
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/chaos
	name = "Chaos donut"
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/food/pastrybase = 1
	)
	added_foodtypes = JUNKFOOD|BREAKFAST|FRIED
	result = /obj/item/food/donut/chaos

/datum/crafting_recipe/food/donut/meat
	time = 1.5 SECONDS
	name = "Meat donut"
	reqs = list(
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/pastrybase = 1
	)
	added_foodtypes = JUNKFOOD|BREAKFAST|FRIED|GORE
	result = /obj/item/food/donut/meat

/datum/crafting_recipe/food/donut/jelly
	name = "Jelly donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/food/pastrybase = 1
	)
	added_foodtypes = parent_type::added_foodtypes|FRUIT
	result = /obj/item/food/donut/jelly/plain

/datum/crafting_recipe/food/donut/slimejelly
	name = "Slime jelly donut"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/pastrybase = 1
	)
	added_foodtypes = parent_type::added_foodtypes|TOXIC
	result = /obj/item/food/donut/jelly/slimejelly/plain


/datum/crafting_recipe/food/donut/berry
	name = "Berry Donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/plain = 1
	)
	added_foodtypes = parent_type::added_foodtypes|FRUIT
	result = /obj/item/food/donut/berry

/datum/crafting_recipe/food/donut/trumpet
	name = "Spaceman's Donut"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/plain = 1
	)

	result = /obj/item/food/donut/trumpet

/datum/crafting_recipe/food/donut/apple
	name = "Apple Donut"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/plain = 1
	)
	added_foodtypes = parent_type::added_foodtypes|FRUIT
	result = /obj/item/food/donut/apple

/datum/crafting_recipe/food/donut/caramel
	name = "Caramel Donut"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/caramel

/datum/crafting_recipe/food/donut/choco
	name = "Chocolate Donut"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/choco

/datum/crafting_recipe/food/donut/blumpkin
	name = "Blumpkin Donut"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/plain = 1
	)
	added_foodtypes = VEGETABLES
	result = /obj/item/food/donut/blumpkin

/datum/crafting_recipe/food/donut/bungo
	name = "Bungo Donut"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/bungo

/datum/crafting_recipe/food/donut/matcha
	name = "Matcha Donut"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/matcha

/datum/crafting_recipe/food/donut/laugh
	name = "Sweet Pea Donut"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/laugh

////////////////////////////////////////////////////JELLY DONUTS///////////////////////////////////////////////////////

/datum/crafting_recipe/food/donut/jelly/berry
	name = "Berry Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/berry

/datum/crafting_recipe/food/donut/jelly/trumpet
	name = "Spaceman's Jelly Donut"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

	result = /obj/item/food/donut/jelly/trumpet

/datum/crafting_recipe/food/donut/jelly/apple
	name = "Apple Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/apple

/datum/crafting_recipe/food/donut/jelly/caramel
	name = "Caramel Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/caramel

/datum/crafting_recipe/food/donut/jelly/choco
	name = "Chocolate Jelly Donut"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/choco

/datum/crafting_recipe/food/donut/jelly/blumpkin
	name = "Blumpkin Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	added_foodtypes = parent_type::added_foodtypes|VEGETABLES
	result = /obj/item/food/donut/jelly/blumpkin

/datum/crafting_recipe/food/donut/jelly/bungo
	name = "Bungo Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/bungo

/datum/crafting_recipe/food/donut/jelly/matcha
	name = "Matcha Jelly Donut"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/matcha

/datum/crafting_recipe/food/donut/jelly/laugh
	name = "Sweet Pea Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/laugh

////////////////////////////////////////////////////SLIME  DONUTS///////////////////////////////////////////////////////

/datum/crafting_recipe/food/donut/slimejelly/berry
	name = "Berry Slime Donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	added_foodtypes = parent_type::added_foodtypes|FRUIT
	result = /obj/item/food/donut/jelly/slimejelly/berry

/datum/crafting_recipe/food/donut/slimejelly/trumpet
	name = "Spaceman's Slime Donut"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

	result = /obj/item/food/donut/jelly/slimejelly/trumpet

/datum/crafting_recipe/food/donut/slimejelly/apple
	name = "Apple Slime Donut"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	added_foodtypes = parent_type::added_foodtypes|FRUIT
	result = /obj/item/food/donut/jelly/slimejelly/apple

/datum/crafting_recipe/food/donut/slimejelly/caramel
	name = "Caramel Slime Donut"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/caramel

/datum/crafting_recipe/food/donut/slimejelly/choco
	name = "Chocolate Slime Donut"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/choco

/datum/crafting_recipe/food/donut/slimejelly/blumpkin
	name = "Blumpkin Slime Donut"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	added_foodtypes = parent_type::added_foodtypes|VEGETABLES
	result = /obj/item/food/donut/jelly/slimejelly/blumpkin

/datum/crafting_recipe/food/donut/slimejelly/bungo
	name = "Bungo Slime Donut"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/bungo

/datum/crafting_recipe/food/donut/slimejelly/matcha
	name = "Matcha Slime Donut"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/matcha

/datum/crafting_recipe/food/donut/slimejelly/laugh
	name = "Sweet Pea Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/laugh

////////////////////////////////////////////////WAFFLES////////////////////////////////////////////////

/datum/crafting_recipe/food/waffles
	time = 1.5 SECONDS
	name = "Waffles"
	reqs = list(
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/waffles
	added_foodtypes = BREAKFAST
	category = CAT_PASTRY


/datum/crafting_recipe/food/soylenviridians
	name = "Soylent viridians"
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/soylenviridians
	category = CAT_PASTRY

/datum/crafting_recipe/food/soylentgreen
	name = "Soylent green"
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/meat/slab/human = 2
	)
	result = /obj/item/food/soylentgreen
	removed_foodtypes = GORE|RAW
	category = CAT_PASTRY


/datum/crafting_recipe/food/rofflewaffles
	name = "Roffle waffles"
	reqs = list(
		/datum/reagent/drug/mushroomhallucinogen = 5,
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/rofflewaffles
	added_foodtypes = VEGETABLES|BREAKFAST
	category = CAT_PASTRY

////////////////////////////////////////////////DONKPOCCKETS////////////////////////////////////////////////

/datum/crafting_recipe/food/donkpocket
	time = 1.5 SECONDS
	name = "Donk-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/meatball = 1
	)
	result = /obj/item/food/donkpocket/homemade
	category = CAT_PASTRY

/datum/crafting_recipe/food/dankpocket
	time = 1.5 SECONDS
	name = "Dank-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/grown/cannabis = 1
	)
	result = /obj/item/food/donkpocket/dank
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/spicy
	time = 1.5 SECONDS
	name = "Spicy-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/chili = 1
	)
	result = /obj/item/food/donkpocket/spicy/homemade
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/teriyaki
	time = 1.5 SECONDS
	name = "Teriyaki-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/meatball = 1,
		/datum/reagent/consumable/soysauce = 3
	)
	result = /obj/item/food/donkpocket/teriyaki/homemade
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/pizza
	time = 1.5 SECONDS
	name = "Pizza-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/donkpocket/pizza
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/honk
	time = 1.5 SECONDS
	name = "Honk-Pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/grown/banana = 1,
		/datum/reagent/consumable/sugar = 3
	)
	result = /obj/item/food/donkpocket/honk
	added_foodtypes = FRUIT|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/berry
	time = 1.5 SECONDS
	name = "Berry-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/donkpocket/berry
	added_foodtypes = FRUIT|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/gondola
	time = 1.5 SECONDS
	name = "Gondola-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/meatball = 1,
		/datum/reagent/gondola_mutation_toxin = 5
	)
	result = /obj/item/food/donkpocket/gondola
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/deluxe
	time = 1.5 SECONDS
	name = "Deluxe Donk-pocket"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/onion_slice/red = 1
	)
	result = /obj/item/food/donkpocket/deluxe
	category = CAT_PASTRY
	removed_foodtypes = BREAKFAST
	crafting_flags = parent_type::crafting_flags | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/donkpocket/deluxe/nocarb
	time = 1.5 SECONDS
	name = "Deluxe Meat-pocket"
	reqs = list(
		/obj/item/organ/heart = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/meat/slab = 1,
		/obj/item/food/grown/herbs = 1
	)
	result = /obj/item/food/donkpocket/deluxe/nocarb
	removed_foodtypes = VEGETABLES //The herbs are only to enhance the flavor
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/deluxe/vegan
	time = 1.5 SECONDS
	name = "Deluxe Donk-roll"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/bell_pepper = 1,
		/obj/item/food/tofu = 2,
	)
	result = /obj/item/food/donkpocket/deluxe/vegan
	removed_foodtypes = BREAKFAST
	category = CAT_PASTRY

////////////////////////////////////////////////MUFFINS////////////////////////////////////////////////

/datum/crafting_recipe/food/muffin
	time = 1.5 SECONDS
	name = "Muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1
	)
	added_foodtypes = BREAKFAST|SUGAR|DAIRY
	result = /obj/item/food/muffin
	category = CAT_PASTRY

/datum/crafting_recipe/food/berrymuffin
	name = "Berry muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/muffin/berry
	added_foodtypes = BREAKFAST|SUGAR|FRUIT|DAIRY
	category = CAT_PASTRY

/datum/crafting_recipe/food/booberrymuffin
	name = "Booberry muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/ectoplasm = 1
	)
	result = /obj/item/food/muffin/booberry
	added_foodtypes = BREAKFAST|SUGAR|DAIRY
	category = CAT_PASTRY

////////////////////////////////////////////OTHER////////////////////////////////////////////


/datum/crafting_recipe/food/khachapuri
	name = "Khachapuri"
	reqs = list(
		/datum/reagent/consumable/eggyolk = 2,
		/datum/reagent/consumable/eggwhite = 4,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/bread/plain = 1
	)
	result = /obj/item/food/khachapuri
	added_foodtypes = MEAT
	category = CAT_PASTRY

/datum/crafting_recipe/food/sugarcookie
	time = 1.5 SECONDS
	name = "Sugar cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/cookie/sugar
	added_foodtypes = JUNKFOOD|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/spookyskull
	time = 1.5 SECONDS
	name = "Skull cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/food/cookie/sugar/spookyskull
	added_foodtypes = JUNKFOOD|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/spookycoffin
	time = 1.5 SECONDS
	name = "Coffin cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/coffee = 5
	)
	result = /obj/item/food/cookie/sugar/spookycoffin
	added_foodtypes = JUNKFOOD|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/fortunecookie
	time = 1.5 SECONDS
	name = "Fortune cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/paper = 1
	)
	parts = list(
		/obj/item/paper = 1
	)
	result = /obj/item/food/fortunecookie
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/poppypretzel
	time = 1.5 SECONDS
	name = "Poppy pretzel"
	reqs = list(
		/obj/item/seeds/poppy = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/poppypretzel
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/plumphelmetbiscuit
	time = 1.5 SECONDS
	name = "Plumphelmet biscuit"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/food/plumphelmetbiscuit
	category = CAT_PASTRY

/datum/crafting_recipe/food/cracker
	time = 1.5 SECONDS
	name = "Cracker"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/doughslice = 1,
	)
	result = /obj/item/food/cracker
	category = CAT_PASTRY

/datum/crafting_recipe/food/chococornet
	name = "Choco cornet"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chococornet
	category = CAT_PASTRY

/datum/crafting_recipe/food/oatmealcookie
	name = "Oatmeal cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/cookie/oatmeal
	category = CAT_PASTRY

/datum/crafting_recipe/food/raisincookie
	name = "Raisin cookie"
	reqs = list(
		/obj/item/food/no_raisin = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/cookie/raisin
	removed_foodtypes = JUNKFOOD
	category = CAT_PASTRY

/datum/crafting_recipe/food/cherrycupcake
	name = "Cherry cupcake"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cherries = 1
	)
	result = /obj/item/food/cherrycupcake
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/bluecherrycupcake
	name = "Blue cherry cupcake"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/bluecherries = 1
	)
	result = /obj/item/food/cherrycupcake/blue
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/jupitercupcake
	name = "Jupiter-cup-cake"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1,
		/datum/reagent/consumable/caramel = 3,
	)
	result = /obj/item/food/jupitercupcake
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/honeybun
	name = "Honey bun"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/honeybun
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/cannoli
	name = "Cannoli"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/sugar = 3
	)
	result = /obj/item/food/cannoli
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/peanut_butter_cookie
	name = "Peanut butter cookie"
	reqs = list(
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/cookie/peanut_butter
	added_foodtypes = JUNKFOOD|NUTS
	category = CAT_PASTRY

/datum/crafting_recipe/food/raw_brownie_batter
	name = "Raw brownie batter"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/egg = 2,
		/datum/reagent/consumable/coco = 5,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/raw_brownie_batter
	added_foodtypes = GRAIN|JUNKFOOD|BREAKFAST|SUGAR
	removed_foodtypes = MEAT|RAW
	category = CAT_PASTRY

/datum/crafting_recipe/food/peanut_butter_brownie_batter
	name = "Raw peanut butter brownie batter"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/egg = 2,
		/datum/reagent/consumable/coco = 5,
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/peanut_butter_brownie_batter
	added_foodtypes = GRAIN|JUNKFOOD|BREAKFAST|SUGAR|NUTS
	removed_foodtypes = MEAT|RAW
	category = CAT_PASTRY

/datum/crafting_recipe/food/crunchy_peanut_butter_tart
	name = "Crunchy peanut butter tart"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/food/grown/peanut = 1,
		/datum/reagent/consumable/cream = 5,
	)
	result = /obj/item/food/crunchy_peanut_butter_tart
	added_foodtypes = JUNKFOOD|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/chocolate_chip_cookie
	name = "Chocolate chip cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/cookie/chocolate_chip_cookie
	removed_foodtypes = JUNKFOOD
	category = CAT_PASTRY

/datum/crafting_recipe/food/snickerdoodle
	name = "Snickerdoodle"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/vanilla = 5,
	)
	result = /obj/item/food/cookie/snickerdoodle
	added_foodtypes = SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/thumbprint_cookie
	name = "Thumbprint cookie"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/cherryjelly = 5,
	)
	result = /obj/item/food/cookie/thumbprint_cookie
	added_foodtypes = FRUIT|SUGAR
	category = CAT_PASTRY

/datum/crafting_recipe/food/macaron
	name = "Macaron"
	reqs = list(
		/datum/reagent/consumable/eggwhite = 2,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/flour = 5,
	)
	result = /obj/item/food/cookie/macaron
	category = CAT_PASTRY
