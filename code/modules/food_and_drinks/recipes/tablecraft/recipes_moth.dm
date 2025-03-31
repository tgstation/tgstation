/datum/crafting_recipe/food/herby_cheese
	name = "Herby cheese"
	reqs = list(
		/obj/item/food/cheese/curd_cheese = 1,
		/obj/item/food/grown/herbs = 4,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/herby_cheese
	category = CAT_MOTH

/datum/crafting_recipe/food/mothic_salad
	name = "Mothic salad"
	reqs = list(
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/onion_slice/red = 2,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/mothic_salad
	category = CAT_MOTH

/datum/crafting_recipe/food/toasted_seeds
	name = "Toasted seeds"
	reqs = list(
		/obj/item/seeds/sunflower = 1,
		/obj/item/seeds/pumpkin = 1,
		/obj/item/seeds/poppy = 1,
		/datum/reagent/consumable/nutriment/fat/oil/olive = 2
	)
	result = /obj/item/food/toasted_seeds
	category = CAT_MOTH

/datum/crafting_recipe/food/engine_fodder
	name = "Engine fodder"
	reqs = list(
		/obj/item/food/toasted_seeds = 1,
		/obj/item/food/cnds = 1,
		/obj/item/food/popcorn = 1,
		/obj/item/food/peanuts = 1,
		/obj/item/food/chips = 1
	)
	result = /obj/item/food/engine_fodder
	category = CAT_MOTH

/datum/crafting_recipe/food/squeaking_stir_fry
	name = "Skeklitmischtpoppl (Squeaking stir fry)"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/cheese/cheese_curds = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/onion_slice = 1
	)
	result = /obj/item/food/squeaking_stir_fry
	removed_foodtypes = BREAKFAST
	category = CAT_MOTH

/datum/crafting_recipe/food/sweet_chili_cabbage_wrap
	name = "Sweet chili cabbage wrap"
	reqs = list(
		/obj/item/food/grilled_cheese = 1,
		/obj/item/food/mothic_salad = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/cabbage = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/sweet_chili_cabbage_wrap
	category = CAT_MOTH

/datum/crafting_recipe/food/loaded_curds
	name = "Ozlsettitæloskekllön ede pommes (Loaded curds and fries)"
	reqs = list(
		/datum/reagent/consumable/nutriment/soup/chili_sin_carne = 10,
		/obj/item/food/cheese/cheese_curds = 1,
		/obj/item/food/onion_slice = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/fries = 1
	)
	result = /obj/item/food/loaded_curds
	category = CAT_MOTH

/datum/crafting_recipe/food/baked_cheese_platter
	name = "Stanntkraktælo (Baked cheese platter)"
	reqs = list(
		/obj/item/food/baked_cheese = 1,
		/obj/item/food/griddle_toast = 3
	)
	result = /obj/item/food/baked_cheese_platter
	category = CAT_MOTH

/datum/crafting_recipe/food/raw_green_lasagne
	reqs = list(
		/obj/item/food/pesto = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 2,
		/obj/item/food/bechamel_sauce = 1,
		/obj/item/food/cheese/firm_cheese_slice = 1
	)
	result = /obj/item/food/raw_green_lasagne
	added_foodtypes = RAW
	category = CAT_MOTH

/datum/crafting_recipe/food/raw_baked_rice
	reqs = list(
		/datum/reagent/consumable/nutriment/soup/vegetable_soup = 10,
		/obj/item/food/boiledrice = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/herbs = 1,
		/obj/item/food/grown/potato = 2,
	)
	result = /obj/item/food/raw_baked_rice
	removed_foodtypes = BREAKFAST
	added_foodtypes = RAW
	category = CAT_MOTH

/datum/crafting_recipe/food/buttered_baked_corn
	name = "Buttered baked corn"
	reqs = list(
		/obj/item/food/oven_baked_corn = 1,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/buttered_baked_corn
	category = CAT_MOTH

/datum/crafting_recipe/food/fiesta_corn_skillet
	name = "Fiesta corn skillet"
	reqs = list(
		/obj/item/food/oven_baked_corn = 1,
		/obj/item/food/cornchips = 1,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/onion_slice = 2,
		/obj/item/food/cheese/wedge = 1
	)
	result = /obj/item/food/fiesta_corn_skillet
	category = CAT_MOTH

/datum/crafting_recipe/food/ratatouille
	reqs = list(
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/onion/red = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/roasted_bell_pepper = 1
	)
	result = /obj/item/food/raw_ratatouille
	category = CAT_MOTH

/datum/crafting_recipe/food/mozzarella_sticks
	name = "Mozzarella sticks"
	reqs = list(
		/obj/item/food/cheese/mozzarella = 1,
		/obj/item/food/breadslice/plain = 2,
	)
	result = /obj/item/food/mozzarella_sticks
	added_foodtypes = FRIED
	category = CAT_MOTH

/datum/crafting_recipe/food/raw_stuffed_peppers
	name = "Voltölpapriken (Stuffed peppers)"
	reqs = list(
		/obj/item/food/grown/bell_pepper = 1,
		/obj/item/food/herby_cheese = 1,
		/obj/item/food/onion_slice = 2
	)
	result = /obj/item/food/raw_stuffed_peppers
	category = CAT_MOTH

/datum/crafting_recipe/food/fueljacks_lunch
	name = "Fueljack's lunch"
	reqs = list(
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/onion_slice = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/cheese/firm_cheese_slice = 1
	)
	result = /obj/item/food/fueljacks_lunch
	category = CAT_MOTH

/datum/crafting_recipe/food/mac_balls
	name = "Macheronirölen (Mac balls)"
	reqs = list(
		/obj/item/food/ready_donk/warm/mac_n_cheese = 1,
		/obj/item/food/tomato_sauce = 1,
		/datum/reagent/consumable/cornmeal_batter = 5
	)
	result = /obj/item/food/mac_balls
	removed_foodtypes = JUNKFOOD
	added_foodtypes = FRIED
	category = CAT_MOTH

/datum/crafting_recipe/food/hua_mulan_congee
	name = "Hua Mulan congee"
	reqs = list(
		/datum/reagent/consumable/nutriment/soup/rice_porridge = 10,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/friedegg = 2,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/bowled/hua_mulan_congee
	removed_foodtypes = BREAKFAST
	added_foodtypes = GRAIN
	category = CAT_MOTH

/datum/crafting_recipe/food/fried_eggplant_polenta
	name = "Fried eggplant and polenta"
	reqs = list(
		/datum/reagent/consumable/nutriment/soup/cornmeal_porridge = 10,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/tomato_sauce = 1,
		/obj/item/food/cheese/mozzarella = 1,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/bowled/fried_eggplant_polenta
	category = CAT_MOTH

/datum/crafting_recipe/food/caprese_salad
	name = "Caprese salad"
	reqs = list(
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/cheese/mozzarella = 1,
		/obj/item/food/grown/herbs = 1,
		/datum/reagent/consumable/nutriment/fat/oil/olive = 2,
		/datum/reagent/consumable/vinegar = 2
	)
	result = /obj/item/food/caprese_salad
	category = CAT_MOTH

/datum/crafting_recipe/food/fleet_salad
	name = "Lörtonknusksolt (Fleet salad)"
	reqs = list(
		/datum/reagent/consumable/nutriment/fat/oil/olive = 2,
		/datum/reagent/consumable/vinegar = 2,
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/grilled_cheese = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/mothic_salad = 1,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/salad/fleet_salad
	category = CAT_MOTH

/datum/crafting_recipe/food/cotton_salad
	name = "Flöfrölenknusksolt (Cotton salad)"
	reqs = list(
		/datum/reagent/consumable/nutriment/fat/oil/olive = 2,
		/datum/reagent/consumable/vinegar = 2,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/mothic_salad = 1,
		/obj/item/grown/cotton = 2,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/salad/cotton_salad
	added_foodtypes = CLOTH
	category = CAT_MOTH

/datum/crafting_recipe/food/moth_kachumbari
	name = "Kæniatknusksolt (Kenyan salad)"
	reqs = list(
		/datum/reagent/consumable/limejuice = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/herbs = 1,
		/obj/item/food/grown/onion/red = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/oven_baked_corn = 1,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/salad/moth_kachumbari
	category = CAT_MOTH

/datum/crafting_recipe/food/raw_mothic_margherita
	reqs = list(
		/obj/item/food/mothic_pizza_dough = 1,
		/obj/item/food/tomato_sauce = 1,
		/obj/item/food/cheese/mozzarella = 1,
		/obj/item/food/cheese/firm_cheese_slice = 1,
		/obj/item/food/grown/herbs = 1
	)
	result = /obj/item/food/raw_mothic_margherita
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/raw_mothic_firecracker
	reqs = list(
		/obj/item/food/mothic_pizza_dough = 1,
		/datum/reagent/consumable/bbqsauce = 10,
		/obj/item/food/cheese/firm_cheese_slice = 1,
		/obj/item/food/oven_baked_corn = 1,
		/obj/item/food/grown/ghost_chili = 1
	)
	result = /obj/item/food/raw_mothic_firecracker
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/raw_mothic_five_cheese
	reqs = list(
		/obj/item/food/mothic_pizza_dough = 1,
		/obj/item/food/tomato_sauce = 1,
		/obj/item/food/cheese/firm_cheese_slice = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/cheese/mozzarella = 1,
		/obj/item/food/herby_cheese = 1,
		/obj/item/food/cheese/cheese_curds = 1
	)
	result = /obj/item/food/raw_mothic_five_cheese
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/raw_mothic_white_pie
	reqs = list(
		/obj/item/food/mothic_pizza_dough = 1,
		/obj/item/food/bechamel_sauce = 1,
		/obj/item/food/cheese/firm_cheese_slice = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/cheese/mozzarella = 1,
		/obj/item/food/grown/herbs = 1
	)
	result = /obj/item/food/raw_mothic_white_pie
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/raw_mothic_pesto
	reqs = list(
		/obj/item/food/mothic_pizza_dough = 1,
		/obj/item/food/pesto = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/cheese/mozzarella = 1
	)
	result = /obj/item/food/raw_mothic_pesto
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/raw_mothic_garlic
	reqs = list(
		/obj/item/food/mothic_pizza_dough = 1,
		/obj/item/food/butterslice = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/herbs = 1
	)
	result = /obj/item/food/raw_mothic_garlic
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/moth_cheese_cakes
	name = "Ælorölen (Cheesecake balls)"
	reqs = list(
		/obj/item/food/cheese/curd_cheese = 1,
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/moth_cheese_cakes
	added_foodtypes = GRAIN|FRIED
	removed_foodtypes = JUNKFOOD
	category = CAT_MOTH

/datum/crafting_recipe/food/mothmallow
	name = "Mothmallows"
	reqs = list(
		/obj/item/food/grown/soybeans = 1,
		/datum/reagent/consumable/vanilla = 5,
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/ethanol/rum = 5
	)
	result = /obj/item/food/cake/mothmallow
	added_foodtypes = SUGAR
	category = CAT_MOTH

/datum/crafting_recipe/food/moffin
	name = "Moffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	result = /obj/item/food/muffin/moffin
	added_foodtypes = CLOTH|SUGAR|BREAKFAST
	category = CAT_MOTH

// Soups

/datum/crafting_recipe/food/reaction/soup/cottonball
	name = "Flöfrölenmæsch (cottonball soup)"
	reaction = /datum/chemical_reaction/food/soup/cottonball
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/cheese
	name = "Ælosterrmæsch (cheese soup)"
	reaction = /datum/chemical_reaction/food/soup/cheese
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/seed
	name = "Misklmæsch (seed soup)"
	reaction = /datum/chemical_reaction/food/soup/seed
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/beans
	name = "Prickeldröndolhaskl (spicy bean stew)"
	reaction = /datum/chemical_reaction/food/soup/beans
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/moth_oats
	name = "Häfmisklhaskl (oat stew)"
	reaction = /datum/chemical_reaction/food/soup/moth_oats
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/fire_soup
	name = "Tömpröttkrakklmæsch (heartburn soup)"
	reaction = /datum/chemical_reaction/food/soup/fire_soup
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/rice_porridge
	reaction = /datum/chemical_reaction/food/soup/rice_porridge
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/toechtauese_rice_porridge
	reaction = /datum/chemical_reaction/food/soup/toechtauese_rice_porridge
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/red_porridge
	name = "Eltsløsk ül a priktæolk (red porridge and yoghurt)"
	reaction = /datum/chemical_reaction/food/soup/red_porridge
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/cornmeal_porridge
	reaction = /datum/chemical_reaction/food/soup/cornmeal_porridge
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/cheese_porridge
	reaction = /datum/chemical_reaction/food/soup/cheese_porridge
	category = CAT_MOTH

/datum/crafting_recipe/food/reaction/soup/chili_sin_carne
	name = "Chili Sin Carne (Vegetarian Chili)"
	reaction = /datum/chemical_reaction/food/soup/chili_sin_carne
	category = CAT_MOTH
