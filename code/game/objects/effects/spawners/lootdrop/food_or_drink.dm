/obj/effect/spawner/lootdrop/food_or_drink
	name = "food or drink loot spawner"
	desc = "Nom nom nom"

/obj/effect/spawner/lootdrop/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	lootdoubles = FALSE
	loot = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy = 1,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki = 1,
		/obj/item/storage/box/donkpockets/donkpocketpizza = 1,
		/obj/item/storage/box/donkpockets/donkpocketberry = 1,
		/obj/item/storage/box/donkpockets/donkpockethonk = 1,
	)

/obj/effect/spawner/lootdrop/food_or_drink/refreshing_beverage
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

/obj/effect/spawner/lootdrop/food_or_drink/three_course_meal
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

/obj/effect/spawner/lootdrop/food_or_drink/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()
