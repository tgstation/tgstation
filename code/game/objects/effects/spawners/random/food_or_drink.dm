/obj/effect/spawner/random/food_or_drink
	name = "food or drink loot spawner"
	desc = "Nom nom nom"

/obj/effect/spawner/random/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	lootdoubles = FALSE
	loot = list(
	/obj/item/storage/box/donkpockets/donkpocketspicy = 1,
	/obj/item/storage/box/donkpockets/donkpocketteriyaki = 1,
	/obj/item/storage/box/donkpockets/donkpocketpizza = 1,
	/obj/item/storage/box/donkpockets/donkpocketberry = 1,
	/obj/item/storage/box/donkpockets/donkpockethonk = 1,
	)

/obj/effect/spawner/random/food_or_drink/refreshing_beverage
	name = "good soda spawner"
	loot = list(
	/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 15,
	/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 15,
	/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 10,
	/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 10,
	/obj/item/reagent_containers/food/drinks/beer/light = 10,
	/obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry = 5,
	/obj/item/reagent_containers/food/drinks/soda_cans/cola = 5,
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
		/obj/item/food/soup/meatball
	)
	var/salads = list(
		/obj/item/food/salad/herbsalad,
		/obj/item/food/salad/validsalad,
		/obj/item/food/salad/fruit,
		/obj/item/food/salad/jungle,
		/obj/item/food/salad/aesirsalad
	)
	var/mains = list(
		/obj/item/food/bearsteak,
		/obj/item/food/enchiladas,
		/obj/item/food/stewedsoymeat,
		/obj/item/food/burger/bigbite,
		/obj/item/food/burger/superbite,
		/obj/item/food/burger/fivealarm
	)

/obj/effect/spawner/random/food_or_drink/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()

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
