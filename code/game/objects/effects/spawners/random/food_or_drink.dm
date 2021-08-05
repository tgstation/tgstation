/obj/effect/spawner/random/food_or_drink
	name = "food or drink loot spawner"
	desc = "Nom nom nom"

/obj/effect/spawner/random/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	lootdoubles = FALSE
	loot = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk,
	)

/obj/effect/spawner/random/food_or_drink/seed
	name = "seed spawner"
	loot = list( // The same seeds in the Supply "Seeds Crate"
		/obj/item/seeds/chili = 1,
		/obj/item/seeds/cotton = 1,
		/obj/item/seeds/berry = 1,
		/obj/item/seeds/corn = 1,
		/obj/item/seeds/eggplant = 1,
		/obj/item/seeds/tomato = 1,
		/obj/item/seeds/soya = 1,
		/obj/item/seeds/wheat = 1,
		/obj/item/seeds/wheat/rice = 1,
		/obj/item/seeds/carrot = 1,
		/obj/item/seeds/sunflower = 1,
		/obj/item/seeds/rose = 1,
		/obj/item/seeds/chanter = 1,
		/obj/item/seeds/potato = 1,
		/obj/item/seeds/sugarcane = 1,
	)

/obj/effect/spawner/random/food_or_drink/rare_seed
	lootcount = 5
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

/obj/effect/spawner/random/food_or_drink/three_course_meal
	name = "three course meal spawner"
	lootcount = 3
	lootdoubles = FALSE
	var/soups = list(
		/obj/item/food/soup/beet,
		/obj/item/food/soup/sweetpotato,
		/obj/item/food/soup/stew,
		/obj/item/food/soup/hotchili,
		/obj/item/food/soup/nettle,
		/obj/item/food/soup/meatball,
	)
	var/salads = list(
		/obj/item/food/salad/herbsalad,
		/obj/item/food/salad/validsalad,
		/obj/item/food/salad/fruit,
		/obj/item/food/salad/jungle,
		/obj/item/food/salad/aesirsalad,
	)
	var/mains = list(
		/obj/item/food/bearsteak,
		/obj/item/food/enchiladas,
		/obj/item/food/stewedsoymeat,
		/obj/item/food/burger/bigbite,
		/obj/item/food/burger/superbite,
		/obj/item/food/burger/fivealarm,
	)

/obj/effect/spawner/random/food_or_drink/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()

/obj/effect/spawner/random/food_or_drink/refreshing_beverage
	name = "good soda spawner"
	loot = list(
		/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 3,
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 3,
		/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 2,
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 2,
		/obj/item/reagent_containers/food/drinks/beer/light = 2,
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
	loot = list(
		/obj/item/reagent_containers/food/drinks/beer = 250,
		/obj/item/reagent_containers/food/drinks/ale = 100,
		/obj/item/reagent_containers/food/drinks/beer/light = 50,
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
	loot = list(
		/obj/item/pizzabox/margherita = 3,
		/obj/item/pizzabox/meat = 3,
		/obj/item/pizzabox/mushroom = 3,
		/obj/item/pizzabox/bomb/armed = 1,
	)

/obj/effect/spawner/random/food_or_drink/seed_vault
	name = "seed vault seeds"
	loot = list(
		/obj/item/seeds/gatfruit = 10,
		/obj/item/seeds/cherry/bomb = 10,
		/obj/item/seeds/berry/glow = 10,
		/obj/item/seeds/sunflower/moonflower = 8,
	)
