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
	)

/obj/effect/spawner/random/food_or_drink/seed_rare
	spawn_loot_count = 5
	icon_state = "seed"
	loot = list( // /obj/item/seeds/random is not a random seed, but an exotic seed.
		/obj/item/seeds/random = 30,
		/obj/item/seeds/liberty = 5,
		/obj/item/seeds/replicapod = 5,
		/obj/item/seeds/reishi = 5,
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
		/obj/item/food/soup/beet,
		/obj/item/food/soup/sweetpotato,
		/obj/item/food/soup/stew,
		/obj/item/food/soup/hotchili,
		/obj/item/food/soup/nettle,
		/obj/item/food/soup/meatball,
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
		/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 3,
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 3,
		/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 2,
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 2,
		/obj/item/reagent_containers/food/drinks/bottle/beer/light = 2,
		/obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola = 1,
	)

/obj/effect/spawner/random/food_or_drink/booze
	name = "booze spawner"
	icon_state = "beer"
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/beer = 75,
		/obj/item/reagent_containers/food/drinks/bottle/ale = 25,
		/obj/item/reagent_containers/food/drinks/bottle/beer/light = 5,
		/obj/item/reagent_containers/food/drinks/bottle/maltliquor = 5,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
		/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
		/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,
		/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
		/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
		/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
		/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
		/obj/item/reagent_containers/food/drinks/bottle/amaretto = 5,
		/obj/item/reagent_containers/food/drinks/bottle/hcider = 5,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe = 5,
		/obj/item/reagent_containers/food/drinks/bottle/sake = 5,
		/obj/item/reagent_containers/food/drinks/bottle/grappa = 5,
		/obj/item/reagent_containers/food/drinks/bottle/applejack = 5,
		/obj/item/reagent_containers/glass/bottle/ethanol = 2,
		/obj/item/reagent_containers/food/drinks/bottle/fernet = 2,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 2,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium = 2,
		/obj/item/reagent_containers/food/drinks/bottle/goldschlager = 2,
		/obj/item/reagent_containers/food/drinks/bottle/patron = 1,
		/obj/item/reagent_containers/food/drinks/bottle/kong = 1,
		/obj/item/reagent_containers/food/drinks/bottle/lizardwine = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka = 1,
		/obj/item/reagent_containers/food/drinks/bottle/trappist = 1,
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
		/obj/item/reagent_containers/food/drinks/dry_ramen = 5,
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
		/obj/item/food/larvae = 5,
		/obj/item/food/emperor_roll = 5,
		/obj/item/food/honey_roll = 5,
	)

/obj/effect/spawner/random/food_or_drink/condiment
	name = "condiment spawner"
	icon_state = "condiment"
	loot = list(
		/obj/item/reagent_containers/food/condiment/saltshaker = 3,
		/obj/item/reagent_containers/food/condiment/peppermill = 3,
		/obj/item/reagent_containers/food/condiment/pack/ketchup = 3,
		/obj/item/reagent_containers/food/condiment/pack/hotsauce = 3,
		/obj/item/reagent_containers/food/condiment/pack/astrotame = 3,
		/obj/item/reagent_containers/food/condiment/pack/bbqsauce = 3,
		/obj/item/reagent_containers/food/condiment/bbqsauce = 1,
		/obj/item/reagent_containers/food/condiment/soysauce = 1,
		/obj/item/reagent_containers/food/condiment/vinegar = 1,
		/obj/item/reagent_containers/food/condiment/peanut_butter = 1,
		/obj/item/reagent_containers/food/condiment/quality_oil = 1,
	)

/obj/effect/spawner/random/food_or_drink/cups
	name = "cup spawner"
	icon_state = "box_small"
	loot = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/storage/box/cups,
		/obj/item/storage/box/condimentbottles,
	)
