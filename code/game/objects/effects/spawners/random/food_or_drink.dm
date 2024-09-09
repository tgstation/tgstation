/obj/effect/spawner/random/food_or_drink
	name = "food or drink loot spawner"
	desc = "Nom nom nom"

/obj/effect/spawner/random/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	icon_state = "donkpocket"
	loot = list(
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk,
	)

/obj/effect/spawner/random/food_or_drink/donkpockets_single
	name = "single donk pocket spawner"
	icon_state = "donkpocket_single"
	loot = list(
		/obj/item/food/donkpocket,
		/obj/item/food/donkpocket/spicy,
		/obj/item/food/donkpocket/teriyaki,
		/obj/item/food/donkpocket/pizza,
		/obj/item/food/donkpocket/berry,
		/obj/item/food/donkpocket/honk,
	)

/obj/effect/spawner/random/food_or_drink/seed
	name = "seed spawner"
	icon_state = "seed"
	loot = list( // The same seeds in the Supply "Seeds Crate"
		/obj/item/seeds/chili,
		/obj/item/seeds/cotton,
		/obj/item/seeds/berry,
		/obj/item/seeds/corn,
		/obj/item/seeds/eggplant,
		/obj/item/seeds/tomato,
		/obj/item/seeds/soya,
		/obj/item/seeds/wheat,
		/obj/item/seeds/wheat/rice,
		/obj/item/seeds/carrot,
		/obj/item/seeds/sunflower,
		/obj/item/seeds/rose,
		/obj/item/seeds/chanter,
		/obj/item/seeds/potato,
		/obj/item/seeds/sugarcane,
		/obj/item/seeds/cucumber,
	)

/obj/effect/spawner/random/food_or_drink/seed_rare
	spawn_loot_count = 5
	icon_state = "seed"
	loot = list( // /obj/item/seeds/random is not a random seed, but an exotic seed.
		/obj/item/seeds/random = 30,
		/obj/item/seeds/liberty = 5,
		/obj/item/seeds/replicapod = 5,
		/obj/item/seeds/reishi = 5,
		/obj/item/seeds/seedling = 5,
		/obj/item/seeds/nettle/death = 1,
		/obj/item/seeds/plump/walkingmushroom = 1,
		/obj/item/seeds/cannabis/rainbow = 1,
		/obj/item/seeds/cannabis/death = 1,
		/obj/item/seeds/cannabis/white = 1,
		/obj/item/seeds/cannabis/ultimate = 1,
		/obj/item/seeds/kudzu = 1,
		/obj/item/seeds/angel = 1,
		/obj/item/seeds/glowshroom/glowcap = 1,
		/obj/item/seeds/glowshroom/shadowshroom = 1,
	)

/obj/effect/spawner/random/food_or_drink/soup
	name = "soup spawner"
	icon_state = "soup"
	loot = list(
		/obj/item/reagent_containers/cup/bowl/soup/hotchili,
		/obj/item/reagent_containers/cup/bowl/soup/meatball_soup,
		/obj/item/reagent_containers/cup/bowl/soup/nettle,
		/obj/item/reagent_containers/cup/bowl/soup/stew,
		/obj/item/reagent_containers/cup/bowl/soup/sweetpotato,
		/obj/item/reagent_containers/cup/bowl/soup/white_beet,
	)

/obj/effect/spawner/random/food_or_drink/salad
	name = "salad spawner"
	icon_state = "soup"
	loot = list(
		/obj/item/food/salad/herbsalad,
		/obj/item/food/salad/validsalad,
		/obj/item/food/salad/fruit,
		/obj/item/food/salad/jungle,
		/obj/item/food/salad/aesirsalad,
	)

/obj/effect/spawner/random/food_or_drink/dinner
	name = "dinner spawner"
	icon_state = "soup"
	loot = list(
		/obj/item/food/bearsteak,
		/obj/item/food/enchiladas,
		/obj/item/food/stewedsoymeat,
		/obj/item/food/burger/bigbite,
		/obj/item/food/burger/superbite,
		/obj/item/food/burger/fivealarm,
	)

/obj/effect/spawner/random/food_or_drink/three_course_meal
	name = "three course meal spawner"
	icon_state = "soup"
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/spawner/random/food_or_drink/soup,
		/obj/effect/spawner/random/food_or_drink/salad,
		/obj/effect/spawner/random/food_or_drink/dinner,
	)

/obj/effect/spawner/random/food_or_drink/refreshing_beverage
	name = "good soda spawner"
	icon_state = "can"
	loot = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola = 3,
		/obj/item/reagent_containers/cup/soda_cans/grey_bull = 3,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 2,
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 2,
		/obj/item/reagent_containers/cup/glass/bottle/beer/light = 2,
		/obj/item/reagent_containers/cup/soda_cans/shamblers = 1,
		/obj/item/reagent_containers/cup/soda_cans/pwr_game = 1,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb = 1,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 1,
		/obj/item/reagent_containers/cup/soda_cans/starkist = 1,
		/obj/item/reagent_containers/cup/soda_cans/space_up = 1,
		/obj/item/reagent_containers/cup/soda_cans/sol_dry = 1,
		/obj/item/reagent_containers/cup/soda_cans/cola = 1,
	)

/obj/effect/spawner/random/food_or_drink/booze
	name = "booze spawner"
	icon_state = "beer"
	loot = list(
		/obj/item/reagent_containers/cup/glass/bottle/beer = 75,
		/obj/item/reagent_containers/cup/glass/bottle/ale = 25,
		/obj/item/reagent_containers/cup/glass/bottle/beer/light = 5,
		/obj/item/reagent_containers/cup/glass/bottle/maltliquor = 5,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey = 5,
		/obj/item/reagent_containers/cup/glass/bottle/gin = 5,
		/obj/item/reagent_containers/cup/glass/bottle/vodka = 5,
		/obj/item/reagent_containers/cup/glass/bottle/tequila = 5,
		/obj/item/reagent_containers/cup/glass/bottle/rum = 5,
		/obj/item/reagent_containers/cup/glass/bottle/vermouth = 5,
		/obj/item/reagent_containers/cup/glass/bottle/cognac = 5,
		/obj/item/reagent_containers/cup/glass/bottle/wine = 5,
		/obj/item/reagent_containers/cup/glass/bottle/kahlua = 5,
		/obj/item/reagent_containers/cup/glass/bottle/amaretto = 5,
		/obj/item/reagent_containers/cup/glass/bottle/hcider = 5,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe = 5,
		/obj/item/reagent_containers/cup/glass/bottle/sake = 5,
		/obj/item/reagent_containers/cup/glass/bottle/grappa = 5,
		/obj/item/reagent_containers/cup/glass/bottle/applejack = 5,
		/obj/item/reagent_containers/cup/glass/bottle/wine_voltaic = 5,
		/obj/item/reagent_containers/cup/bottle/ethanol = 2,
		/obj/item/reagent_containers/cup/glass/bottle/fernet = 2,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 2,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium = 2,
		/obj/item/reagent_containers/cup/glass/bottle/goldschlager = 2,
		/obj/item/reagent_containers/cup/glass/bottle/patron = 1,
		/obj/item/reagent_containers/cup/glass/bottle/kong = 1,
		/obj/item/reagent_containers/cup/glass/bottle/lizardwine = 1,
		/obj/item/reagent_containers/cup/glass/bottle/vodka/badminka = 1,
		/obj/item/reagent_containers/cup/glass/bottle/trappist = 1,
		/obj/item/reagent_containers/cup/glass/bottle/rum/aged = 1,
	)

/obj/effect/spawner/random/food_or_drink/pizzaparty
	name = "pizza bomb spawner"
	icon_state = "pizzabox"
	loot = list(
		/obj/item/pizzabox/margherita = 2,
		/obj/item/pizzabox/meat = 2,
		/obj/item/pizzabox/mushroom = 2,
		/obj/item/pizzabox/pineapple = 2,
		/obj/item/pizzabox/vegetable = 2,
		/obj/item/pizzabox/bomb/armed = 1,

	)

/obj/effect/spawner/random/food_or_drink/seed_vault
	name = "seed vault seeds"
	icon_state = "seed"
	loot = list(
		/obj/item/seeds/gatfruit = 10,
		/obj/item/seeds/cherry/bomb = 10,
		/obj/item/seeds/berry/glow = 10,
		/obj/item/seeds/sunflower/moonflower = 8,
	)

/obj/effect/spawner/random/food_or_drink/snack
	name = "snack spawner"
	icon_state = "chips"
	loot = list(
		/obj/item/food/spacetwinkie = 5,
		/obj/item/food/cheesiehonkers = 5,
		/obj/item/food/candy = 5,
		/obj/item/food/chips = 5,
		/obj/item/food/sosjerky = 5,
		/obj/item/food/no_raisin = 5,
		/obj/item/food/peanuts = 5,
		/obj/item/food/cnds = 5,
		/obj/item/food/energybar = 5,
		/obj/item/reagent_containers/cup/glass/dry_ramen = 5,
		/obj/item/food/cornchips/random = 5,
		/obj/item/food/semki = 5,
		/obj/item/food/peanuts/random = 3,
		/obj/item/food/cnds/random = 3,
		/obj/item/storage/box/gum = 3,
		/obj/item/food/syndicake = 1,
		/obj/item/food/peanuts/ban_appeal = 1,
		/obj/item/food/pistachios = 1,
		/obj/item/food/candy/bronx = 1
	)

/obj/effect/spawner/random/food_or_drink/snack/lizard
	name = "lizard snack spawner"
	loot = list(
		/obj/item/food/brain_pate = 5,
		/obj/item/food/bread/root = 1,
		/obj/item/food/breadslice/root = 5,
		/obj/item/food/kebab/candied_mushrooms = 5,
		/obj/item/food/steeped_mushrooms = 5,
		/obj/item/food/canned/larvae = 5,
		/obj/item/food/emperor_roll = 5,
		/obj/item/food/honey_roll = 5,
	)

/obj/effect/spawner/random/food_or_drink/condiment
	name = "condiment spawner"
	icon_state = "condiment"
	loot = list(
		/obj/item/reagent_containers/condiment/saltshaker = 3,
		/obj/item/reagent_containers/condiment/peppermill = 3,
		/obj/item/reagent_containers/condiment/pack/ketchup = 3,
		/obj/item/reagent_containers/condiment/pack/hotsauce = 3,
		/obj/item/reagent_containers/condiment/pack/astrotame = 3,
		/obj/item/reagent_containers/condiment/pack/bbqsauce = 3,
		/obj/item/reagent_containers/condiment/bbqsauce = 1,
		/obj/item/reagent_containers/condiment/soysauce = 1,
		/obj/item/reagent_containers/condiment/vinegar = 1,
		/obj/item/reagent_containers/condiment/peanut_butter = 1,
		/obj/item/reagent_containers/condiment/olive_oil = 1,
		/obj/item/reagent_containers/condiment/cherryjelly = 1,
	)

/obj/effect/spawner/random/food_or_drink/cups
	name = "cup spawner"
	icon_state = "box_small"
	loot = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/storage/box/cups,
		/obj/item/storage/box/condimentbottles,
	)

///Used for the employee birthday station trait
/obj/effect/spawner/random/food_or_drink/cake_ingredients
	name = "cake ingredients spawner"
	icon_state = "cake"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/food/cakebatter,
		/obj/item/flashlight/flare/candle,
		/obj/item/reagent_containers/condiment/sugar,
		/obj/item/reagent_containers/cup/bottle/caramel,
	)

/obj/effect/spawner/random/food_or_drink/cake_ingredients/Initialize(mapload)
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_BIRTHDAY))
		spawn_loot_chance = 0
	return ..()

/obj/effect/spawner/random/food_or_drink/donuts
	name = "donut spawner"
	icon_state = "donut"
	loot = list(
		/obj/item/food/donut/apple = 3,
		/obj/item/food/donut/berry = 3,
		/obj/item/food/donut/caramel = 3,
		/obj/item/food/donut/choco = 3,
		/obj/item/food/donut/plain = 3,
		/obj/item/food/donut/blumpkin = 2,
		/obj/item/food/donut/bungo = 2,
		/obj/item/food/donut/laugh = 2,
		/obj/item/food/donut/matcha = 2,
		/obj/item/food/donut/trumpet = 2,
		/obj/item/food/donut/chaos = 1,
		/obj/item/food/donut/meat = 1,
	)

/obj/effect/spawner/random/food_or_drink/jelly_donuts
	name = "jelly donut spawner"
	icon_state = "jelly_donut"
	loot = list(
		/obj/item/food/donut/jelly/apple = 3,
		/obj/item/food/donut/jelly/berry = 3,
		/obj/item/food/donut/jelly/caramel = 3,
		/obj/item/food/donut/jelly/choco = 3,
		/obj/item/food/donut/jelly/plain = 3,
		/obj/item/food/donut/jelly/blumpkin = 2,
		/obj/item/food/donut/jelly/bungo = 2,
		/obj/item/food/donut/jelly/laugh = 2,
		/obj/item/food/donut/jelly/matcha = 2,
		/obj/item/food/donut/jelly/trumpet = 2,
	)

/obj/effect/spawner/random/food_or_drink/slime_jelly_donuts
	name = "slime jelly donut spawner"
	icon_state = "slime_jelly_donut"
	loot = list(
		/obj/item/food/donut/jelly/slimejelly/apple = 3,
		/obj/item/food/donut/jelly/slimejelly/berry = 3,
		/obj/item/food/donut/jelly/slimejelly/caramel = 3,
		/obj/item/food/donut/jelly/slimejelly/choco = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 3,
		/obj/item/food/donut/jelly/slimejelly/blumpkin = 2,
		/obj/item/food/donut/jelly/slimejelly/bungo = 2,
		/obj/item/food/donut/jelly/slimejelly/laugh = 2,
		/obj/item/food/donut/jelly/slimejelly/matcha = 2,
		/obj/item/food/donut/jelly/slimejelly/trumpet = 2,
	)

/obj/effect/spawner/random/food_or_drink/any_snack_or_beverage
	name = "any snack or beverage spawner"
	icon_state = "slime_jelly_donut"
	loot = list(
		/obj/effect/spawner/random/food_or_drink/snack = 6,
		/obj/effect/spawner/random/food_or_drink/refreshing_beverage = 6,
		/obj/effect/spawner/random/food_or_drink/donuts = 5,
		/obj/effect/spawner/random/food_or_drink/donkpockets_single = 5,
		/obj/effect/spawner/random/food_or_drink/booze = 4,
		/obj/effect/spawner/random/food_or_drink/snack/lizard = 4,
		/obj/effect/spawner/random/food_or_drink/jelly_donuts = 3,
		/obj/effect/spawner/random/food_or_drink/slime_jelly_donuts = 1,
	)
