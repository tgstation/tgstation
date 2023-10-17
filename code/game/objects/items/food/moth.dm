//Moth Foods, the three C's: cheese, coleslaw, and cotton
//A large emphasis has been put on sharing and multiple portion dishes
//Additionally, where a mothic name is given, a short breakdown of what exactly it means is provided, for the curious on the internal workings of mothic: it's very onomatopoeic, and makes heavy use of combined words and accents

//Base ingredients and miscellany, generally not served on their own
/obj/item/food/herby_cheese
	name = "herby cheese"
	desc = "As a staple of mothic cuisine, cheese is often augmented with various flavours to keep variety in their diet. \
		Herbs are one such addition, and are particularly beloved."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "herby_cheese"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 6)
	tastes = list("cheese" = 1, "herbs" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/grilled_cheese
	name = "grilled cheese"
	desc = "As prescribed by Lord Alton, blessed be his name, 99.997% of the world's recipes for grilled cheese flat out lie: \
		never once is the cheese grilled, it is merely a griddled sandwich containing melted cheese. This, on the other hand, is truly grilled cheese, grillmarks and all."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "grilled_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("cheese" = 1, "char" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/mothic_salad
	name = "mothic salad"
	desc = "A basic salad of cabbage, red onion and tomato. Can serve as a perfect base for a million different salads."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mothic_salad"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("salad" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/toasted_seeds
	name = "toasted seeds"
	desc = "While they're far from filling, toasted seeds are a popular snack amongst the moths. \
		Salt, sugar, or even some more exotic flavours may be added for some extra pep."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "toasted_seeds"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("seeds" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/engine_fodder
	name = "engine fodder"
	desc = "A common snack for engineers on the mothic fleet, made of seeds, nuts, chocolate, popcorn, and potato chips- \
		designed to be dense with calories and easy to snack on when an extra boost is needed."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "engine_fodder"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/salt = 2,
	)
	tastes = list("seeds" = 1, "nuts" = 1, "chocolate" = 1, "salt" = 1, "popcorn" = 1, "potato" = 1)
	foodtypes = GRAIN | NUTS | VEGETABLES | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/mothic_pizza_dough
	name = "mothic pizza dough"
	desc = "A strong, glutenous dough, made with cornmeal and flour, designed to hold up to cheese and sauce."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mothic_pizza_dough"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("raw flour" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

//Entrees: categorising food that is 90% cheese and salad is not easy
/obj/item/food/squeaking_stir_fry
	name = "skeklitmischtpoppl" //skeklit = squeaking, mischt = stir, poppl = fry
	desc = "A mothic classic made with cheese curds and tofu (amongst other things). \
		Translated literally the name means 'squeaking stir fry', a name given due to the distinctive squeak of the proteins."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "squeaking_stir_fry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("cheese" = 1, "tofu" = 1, "veggies" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/sweet_chili_cabbage_wrap
	name = "sweet chili cabbage wrap"
	desc = "Grilled cheese and salad in a cabbage wrap, topped with delicious sweet chili sauce."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "sweet_chili_cabbage_wrap"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/capsaicin = 1,
	)
	tastes = list("cheese" = 1, "salad" = 1, "sweet chili" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/loaded_curds
	name = "ozlsettitæloskekllön ede pommes" //ozlsettit = overflowing (ozl = over, sett = flow, it = ing), ælo = cheese, skekllön = curds (skeklit = squeaking, llön = pieces/bits), ede = and, pommes = fries (hey, France!)
	desc = "What's better than cheese curds? Deep fried cheese curds! What's better than deep fried cheese curds? \
		Deep fried cheese curds with chili (and more cheese) on top! And what's better than that? Putting it on fries!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "loaded_curds"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/capsaicin = 1,
	)
	tastes = list("cheese" = 1, "oil" = 1, "chili" = 1, "fries" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/baked_cheese
	name = "baked cheese wheel"
	desc = "A baked cheese wheel, melty and delicious."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "baked_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/nutriment = 5,
	)
	tastes = list("cheese" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/baked_cheese_platter
	name = "stanntkraktælo" //stannt = oven, krakt = baked, ælo = cheese
	desc = "A baked cheese wheel: a mothic favourite for sharing. Usually served with crispy bread slices for dipping, \
		because the only thing better than good cheese is good cheese on bread."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "baked_cheese_platter"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("cheese" = 1, "bread" = 1)
	foodtypes = DAIRY | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

//Baked Green Lasagna at the Whistlestop Cafe
/obj/item/food/raw_green_lasagne
	name = "raw green lasagne al forno"
	desc = "A fine lasagne made with pesto and a herby white sauce, ready to bake. Good for multiple servings."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_green_lasagne"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 10,
	)
	tastes = list("cheese" = 1, "pesto" = 1, "pasta" = 1)
	foodtypes = VEGETABLES | GRAIN | NUTS | RAW
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_green_lasagne/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/green_lasagne, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/green_lasagne
	name = "green lasagne al forno"
	desc = "A fine lasagne made with pesto and a herby white sauce. Good for multiple servings."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "green_lasagne"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 24,
		/datum/reagent/consumable/nutriment/vitamin = 18,
	)
	tastes = list("cheese" = 1, "pesto" = 1, "pasta" = 1)
	foodtypes = VEGETABLES | GRAIN | NUTS
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/green_lasagne/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/green_lasagne_slice, 6, 3 SECONDS, table_required = TRUE,  screentip_verb = "Slice")

/obj/item/food/green_lasagne_slice
	name = "green lasagne al forno slice"
	desc = "A slice of herby, pesto-y lasagne."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "green_lasagne_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("cheese" = 1, "pesto" = 1, "pasta" = 1)
	foodtypes = VEGETABLES | GRAIN | NUTS
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_baked_rice
	name = "big rice pan"
	desc = "A big pan of layered potatoes topped with rice and vegetable stock, ready to be baked into a delicious sharing meal."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_baked_rice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 10,
	)
	tastes = list("rice" = 1, "potato" = 1, "veggies" = 1)
	foodtypes = VEGETABLES | GRAIN | RAW
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_baked_rice/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/big_baked_rice, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/big_baked_rice
	name = "big baked rice"
	desc = "A mothic favourite, baked rice can be filled with a variety of vegetable fillings to make a delicious meal to share. \
		Potatoes are also often layered on the bottom of the cooking vessel to create a flavourful crust which is hotly contested amongst diners."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "big_baked_rice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 18,
		/datum/reagent/consumable/nutriment/vitamin = 42,
	)
	tastes = list("rice" = 1, "potato" = 1, "veggies" = 1)
	foodtypes = VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/big_baked_rice/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/lil_baked_rice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Cut")

/obj/item/food/lil_baked_rice
	name = "lil baked rice"
	desc = "A single portion of baked rice, perfect as a side dish, or even as a full meal."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "lil_baked_rice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 7,
	)
	tastes = list("rice" = 1, "potato" = 1, "veggies" = 1)
	foodtypes = VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/oven_baked_corn
	name = "oven-baked corn"
	desc = "A cob of corn, baked in the roasting heat of an oven until it blisters and blackens. \
		Beloved as a quick yet flavourful and filling component for dishes on the Fleet."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "oven_baked_corn"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("corn" = 1, "char" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/buttered_baked_corn
	name = "buttered baked corn"
	desc = "What's better than baked corn? Baked corn with butter!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "buttered_baked_corn"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("corn" = 1, "char" = 1)
	foodtypes = VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fiesta_corn_skillet
	name = "fiesta corn skillet"
	desc = "Sweet, spicy, saucy, and all kinds of corny."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "fiesta_corn_skillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("corn" = 1, "chili" = 1, "char" = 1)
	foodtypes = VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/raw_ratatouille
	name = "raw ratatouille" //rawtatouille?
	desc = "Sliced vegetables with a roasted pepper sauce. Delicious, for a peasant food."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_ratatouille"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("veggies" = 1, "roasted peppers" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/raw_ratatouille/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/ratatouille, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/ratatouille
	name = "ratatouille"
	desc = "The perfect dish to save your restaurant from a vindictive food critic. Bonus points if you've got a rat in your hat."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "ratatouille"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("veggies" = 1, "roasted peppers" = 1, "char" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/mozzarella_sticks
	name = "mozzarella sticks"
	desc = "Little sticks of mozzarella, breaded and fried."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mozzarella_sticks"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("creamy cheese" = 1, "breading" = 1, "oil" = 1)
	foodtypes = DAIRY | GRAIN | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/raw_stuffed_peppers
	name = "raw voltölpaprik" //voltöl = stuffed (vol = full, töl = push), paprik (from German paprika) = bell pepper
	desc = "A pepper with the top removed and a herby cheese and onion mix stuffed inside. Probably shouldn't be eaten raw."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_stuffed_pepper"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("creamy cheese" = 1, "herbs" = 1, "onion" = 1, "bell pepper" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/raw_stuffed_peppers/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/stuffed_peppers, rand(10 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/stuffed_peppers
	name = "voltölpaprik"
	desc = "A soft yet still crisp bell pepper, with a wonderful melty cheesy interior."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "stuffed_pepper"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 8,
	)
	tastes = list("creamy cheese" = 1, "herbs" = 1, "onion" = 1, "bell pepper" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/fueljacks_lunch
	name = "\improper Fueljack's lunch"
	desc = "A dish made from fried vegetables, popular amongst fueljacks- the brave moths who operate the fuel skimmers to keep the fleet running. \
		Given the constant need for fuel, and the limited windows in which the stars align for harvesting (literally), \
		they'll often take packed meals to save on trips to the mess, which they heat using the fresh canisters."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "fueljacks_lunch"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 8,
	)
	tastes = list("cabbage" = 1, "potato" = 1, "onion" = 1, "chili" = 1, "cheese" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/mac_balls
	name = "macheronirölen"
	desc = "Fried balls of macaroni cheese dipped in corn batter, served with tomato sauce. \
		A popular snack across the galaxy, and especially on the Mothic Fleet- where they tend to use Ready-Donk as the base."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mac_balls"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 10,
	)
	tastes = list("pasta" = 1, "cornbread" = 1, "cheese" = 1)
	foodtypes = DAIRY | VEGETABLES | FRIED | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/sustenance_bar
	name = "surplus fleet PSB"
	desc = "The PSB, or Prepacked Sustenance Bar, is a densely packed, nutrient rich food which is designed to hold the populace over \
		during times of food shortage. Made from soy and pea protein, each lasts 3 days if adequately rationed. While they have a long shelf life, \
		they do eventually go bad- prompting them to be sold as surplus by the fleet. This particular one is, like most artificially-flavoured moth food, mixed-herb flavoured."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "sustenance_bar"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20)
	tastes = list("herbs" = 1)
	foodtypes = VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/sustenance_bar/neapolitan
	name = "surplus fleet PSB- neapolitan flavour"
	desc = "The PSB, or Prepacked Sustenance Bar, is a densely packed, nutrient rich food which is designed to hold the populace over \
		during times of food shortage. Made from soy and pea protein, each lasts 3 days if adequately rationed. While they have a long shelf life, \
		they do eventually go bad- prompting them to be sold as surplus by the fleet. This particular one is neapolitan flavoured- strawberry, vanilla, and chocolate."
	tastes = list("strawberry" = 1, "vanilla" = 1, "chocolate" = 1)

/obj/item/food/sustenance_bar/cheese
	name = "surplus fleet PSB- three-cheese flavour"
	desc = "The PSB, or Prepacked Sustenance Bar, is a densely packed, nutrient rich food which is designed to hold the populace over \
		during times of food shortage. Made from soy and pea protein, each lasts 3 days if adequately rationed. While they have a long shelf life, \
		they do eventually go bad- prompting them to be sold as surplus by the fleet. This particular one is three-cheese flavoured- parmesan, mozzarella, and cheddar."
	tastes = list("parmesan" = 1, "mozzarella" = 1, "cheddar" = 1)

/obj/item/food/sustenance_bar/mint
	name = "surplus fleet PSB- mint choc chip flavour"
	desc = "The PSB, or Prepacked Sustenance Bar, is a densely packed, nutrient rich food which is designed to hold the populace over \
		during times of food shortage. Made from soy and pea protein, each lasts 3 days if adequately rationed. While they have a long shelf life, \
		they do eventually go bad- prompting them to be sold as surplus by the fleet. This particular one is mint choc chip flavoured- peppermint, \
		dark chocolate, and potato chips, showing that mothkind has no idea what mint choc chip is."
	tastes = list("peppermint" = 1, "potato chips(?)" = 1, "dark chocolate" = 1)

/obj/item/food/sustenance_bar/wonka
	name = "surplus fleet PSB- three course dinner"
	desc = "The PSB, or Prepacked Sustenance Bar, is a densely packed, nutrient rich food which is designed to hold the populace over \
		during times of food shortage. Made from soy and pea protein, each lasts 3 days if adequately rationed. While they have a long shelf life, \
		they do eventually go bad- prompting them to be sold as surplus by the fleet. This particular one is split into three flavours, \
		making up a typical meal- tomato soup, roast pumpkin, and blueberry pie." //Thankfully not made by Willy Wonka
	tastes = list("tomato soup" = 1, "roast pumpkin" = 1, "blueberry pie" = 1)

/obj/item/food/bowled/hua_mulan_congee
	name = "\improper Hua Mulan congee"
	desc = "Nobody is quite sure why this smiley bowl of rice porridge with eggs and bacon is named after a mythological Chinese figure- \
		it's just sorta what it's always been called."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "hua_mulan_congee"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("bacon" = 1, "eggs" = 1)
	foodtypes = MEAT | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/bowled/fried_eggplant_polenta
	name = "fried eggplant and polenta"
	desc = "Polenta loaded with cheese, served with a few discs of fried eggplant and some tomato sauce. Lække!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "fried_eggplant_polenta"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/nutriment = 10,
	)
	tastes = list("cornmeal" = 1, "cheese" = 1, "eggplant" = 1, "tomato sauce" = 1)
	foodtypes = DAIRY | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5

//Salads: the bread and butter of mothic cuisine
/obj/item/food/caprese_salad
	name = "caprese salad"
	desc = "While it's far from an original creation of the moths, caprese salad has become a favourite aboard the Fleet \
		due to how simple it is to prepare yet how tasty it is. To the moths it's known as zaileskenknusksolt: \
		two tone salad, in GalCom." //zail = two, esken = colour/tone, knuskolt = salad
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "caprese_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("mozzarella" = 1, "tomato" = 1, "balsamic" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/fleet_salad
	name = "lörtonknusksolt" //lörton = fleet, knusksolt = salad (knusk = crisp, solt = bowl)
	desc = "Lörtonknusksolt, or Fleet Salad in GalCom, is commonly seen at the snack bars and canteens aboard the Fleet. \
		The grilled cheese makes it particularly filling, while the croutons provide a crunchy kick."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "fleet_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 12,
	)
	tastes = list("cheese" = 1, "salad" = 1, "bread" = 1)
	foodtypes = DAIRY | VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/salad/cotton_salad
	name = "flöfrölenknusksolt"
	desc = "A salad with added cotton and a basic dressing. Presumably either moths are around, or the South's risen again."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "cotton_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 14,
	)
	tastes = list("cheese" = 1, "salad" = 1, "bread" = 1)
	foodtypes = VEGETABLES | CLOTH
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/salad/moth_kachumbari
	name = "\improper Kæniatknusksolt" //Kæniat = Kenyan, knusksolt = salad
	desc = "Originally a Kenyan recipe, kachumbari is yet another cross-cultural favourite from humanity that has been adopted by the moths- \
		though some ingredients have been necessarily changed."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_kachumbari"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 18,
	)
	tastes = list("onion" = 1, "tomato" = 1, "corn" = 1, "chili" = 1, "cilantro" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

//Pizza
/obj/item/food/raw_mothic_margherita
	name = "raw mothic margherita pizza"
	desc = "Another human classic adopted by the moths, mothic pizza is characterised by the use of fresh ingredients, \
		particularly fresh mozzarella, and the use of strong flour to produce a glutenous dough."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_margherita_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("dough" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_margherita/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mothic_margherita, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/mothic_margherita
	name = "mothic margherita pizza"
	desc = "A key characteristic of mothic pizza is that it's sold by weight- single slices are available for discretionary credits, while a meal ticket can buy a whole pie."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "margherita_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mothic_margherita
	boxtag = "Margherita alla Moffuchi"
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/pizzaslice/mothic_margherita
	name = "mothic margherita slice"
	desc = "A slice of mothic margherita pizza, the most humble of pizzas."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "margherita_slice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_firecracker
	name = "raw mothic firecracker pizza"
	desc = "A favourite amongst the more adventurous moths, firecracker pizza is HOT HOT HOT!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_firecracker_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/bbqsauce = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/capsaicin = 10,
	)
	tastes = list("dough" = 1, "chili" = 1, "corn" = 1, "cheese" = 1, "bbq sauce" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_firecracker/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mothic_firecracker, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/mothic_firecracker
	name = "mothic firecracker pizza"
	desc = "They're not kidding when they call this a hot pizza pie."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "firecracker_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/bbqsauce = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/capsaicin = 10,
	)
	tastes = list("crust" = 1, "chili" = 1, "corn" = 1, "cheese" = 1, "bbq sauce" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mothic_firecracker
	boxtag = "Vesuvian Firecracker"
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/pizzaslice/mothic_firecracker
	name = "mothic firecracker slice"
	desc = "A spicy slice of something quite nice."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "firecracker_slice"
	tastes = list("crust" = 1, "chili" = 1, "corn" = 1, "cheese" = 1, "bbq sauce" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_five_cheese
	name = "raw mothic five-cheese pizza"
	desc = "For centuries, scholars have asked: how much cheese is too much cheese?"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_five_cheese_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("dough" = 1, "cheese" = 1, "more cheese" = 1, "excessive amounts of cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_five_cheese/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mothic_five_cheese, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/mothic_five_cheese
	name = "mothic five-cheese pizza"
	desc = "A favourite amongst mice, rats, and English inventors."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "five_cheese_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "cheese" = 1, "more cheese" = 1, "excessive amounts of cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mothic_five_cheese
	boxtag = "Cheeseplosion"
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/pizzaslice/mothic_five_cheese
	name = "mothic five-cheese slice"
	desc = "It's the cheesiest slice in the galaxy!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "five_cheese_slice"
	tastes = list("crust" = 1, "cheese" = 1, "more cheese" = 1, "excessive amounts of cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_white_pie
	name = "raw mothic white-pie pizza"
	desc = "A pizza made for the tomato haters."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_white_pie_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("dough" = 1, "cheese" = 1, "herbs" = 1, "garlic" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_white_pie/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mothic_white_pie, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/mothic_white_pie
	name = "mothic white-pie pizza"
	desc = "You say to-may-to, I say to-mah-to, and we put neither on this pizza."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "white_pie_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "cheese" = 1, "herbs" = 1, "garlic" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mothic_white_pie
	boxtag = "Pane Bianco"
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/pizzaslice/mothic_white_pie
	name = "mothic white-pie slice"
	desc = "Cheesy, garlicky, herby, delicious!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "white_pie_slice"
	tastes = list("crust" = 1, "cheese" = 1, "more cheese" = 1, "excessive amounts of cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_pesto
	name = "raw mothic pesto pizza"
	desc = "Pesto is a popular pizza topping for moths, quite possibly because it exemplifies their favourite flavours: cheese, herbs, and veggies."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_pesto_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("dough" = 1, "pesto" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | NUTS | RAW
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_pesto/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mothic_pesto, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/mothic_pesto
	name = "mothic pesto pizza"
	desc = "Green as the grass in the garden. Not that there's many of those on mothic ships."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "pesto_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "pesto" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | NUTS | RAW
	slice_type = /obj/item/food/pizzaslice/mothic_pesto
	boxtag = "Presto Pesto"
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/pizzaslice/mothic_pesto
	name = "mothic pesto slice"
	desc = "A slice of presto pesto pizza."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "pesto_slice"
	tastes = list("crust" = 1, "pesto" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | NUTS
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/raw_mothic_garlic
	name = "raw mothic garlic pizzabread"
	desc = "Ahh, garlic. A universally loved ingredient, except possibly by vampires."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "raw_garlic_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("dough" = 1, "garlic" = 1, "butter" = 1)
	foodtypes = GRAIN | VEGETABLES | RAW
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/raw_mothic_garlic/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mothic_garlic, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/mothic_garlic
	name = "mothic garlic pizzabread"
	desc = "The best food in the galaxy, hands down."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "garlic_pizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "garlic" = 1, "butter" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | NUTS
	slice_type = /obj/item/food/pizzaslice/mothic_garlic
	boxtag = "Garlic Bread alla Moffuchi"
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizzaslice/mothic_garlic
	name = "mothic garlic pizzabread slice"
	desc = "The best combination of oily, garlicky, and crusty known to mothkind."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "garlic_slice"
	tastes = list("dough" = 1, "garlic" = 1, "butter" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_4

//Bread
/obj/item/food/bread/corn
	name = "cornbread"
	desc = "Some good down-home country-style, rootin'-tootin', revolver-shootin', dad-gum yeehaw cornbread."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "cornbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	tastes = list("cornbread" = 10)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	slice_type = /obj/item/food/breadslice/corn
	yield = 6
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/breadslice/corn
	name = "cornbread slice"
	desc = "A chunk of crispy, cowboy-style cornbread. Consume contentedly."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "cornbread_slice"
	foodtypes = GRAIN
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	crafting_complexity = FOOD_COMPLEXITY_2

//Sweets
/obj/item/food/moth_cheese_cakes
	name = "\improper ælorölen" //ælo = cheese, rölen = balls
	desc = "Ælorölen (cheese balls) are a traditional mothic dessert, made of soft cheese, powdered sugar and flour, rolled into balls, battered and then deep fried. They're often served with either chocolate sauce or honey, or sometimes both!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_cheese_cakes"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/sugar = 12,
	)
	tastes = list("cheesecake" = 1, "chocolate" = 1, "honey" = 1)
	foodtypes = SUGAR | FRIED | DAIRY | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cake/mothmallow
	name = "mothmallow tray"
	desc = "A light and fluffy vegan marshmallow flavoured with vanilla and rum and topped with soft chocolate. These are known to the moths as höllflöfstarkken: cloud squares." //höllflöf = cloud (höll = wind, flöf = cotton), starkken = squares
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mothmallow_tray"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/sugar = 20,
	)
	tastes = list("vanilla" = 1, "clouds" = 1, "chocolate" = 1)
	foodtypes = VEGETABLES | SUGAR
	slice_type = /obj/item/food/cakeslice/mothmallow
	yield = 6
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cakeslice/mothmallow
	name = "mothmallow"
	desc = "Fluffy little clouds of joy- in a strangely moth-like colour."
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mothmallow_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 4,
	)
	tastes = list("vanilla" = 1, "clouds" = 1, "chocolate" = 1)
	foodtypes = VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

//misc food
/obj/item/food/bubblegum/wake_up
	name = "wake-up gum"
	desc = "A rubbery strip of gum. It's stamped with the emblem of the Mothic Nomad Fleet."
	food_reagents = list(
		/datum/reagent/consumable/sugar = 13,
		/datum/reagent/drug/methamphetamine = 2,
	)
	tastes = list("herbs" = 1)
	color = "#567D46"

/obj/item/storage/box/gum/wake_up
	name = "\improper Activin 12 Hour medicated gum packet"
	desc = "Stay awake during long shifts in the maintenance tunnels with Activin! The approval seal of the Mothic Nomad Fleet \
		is emblazoned on the packaging, alongside a litany of health and safety disclaimers in both Mothic and Galactic Common."
	icon_state = "bubblegum_wake_up"
	custom_premium_price = PAYCHECK_CREW * 1.5

/obj/item/storage/box/gum/wake_up/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You read some of the health and safety information...</i>")
	. += "\t[span_info("For the relief of tiredness and drowsiness while working.")]"
	. += "\t[span_info("Do not chew more than one strip every 12 hours. Do not use as a complete substitute for sleep.")]"
	. += "\t[span_info("Do not give to children under 16. Do not exceed the maximum dosage. Do not ingest. Do not take for more than 3 days consecutively. Do not take in conjunction with other medication. May cause adverse reactions in patients with pre-existing heart conditions.")]"
	. += "\t[span_info("Side effects of Activin use may include twitchy antennae, overactive wings, loss of keratin sheen, loss of setae coverage, arrythmia, blurred vision, and euphoria. Cease taking the medication if side effects occur.")]"
	. += "\t[span_info("Repeated use may cause addiction.")]"
	. += "\t[span_info("If the maximum dosage is exceeded, inform a member of your assigned vessel's medical staff immediately. Do not induce vomiting.")]"
	. += "\t[span_info("Ingredients: each strip contains 500mg of Activin (dextro-methamphetamine). Other ingredients include Green Dye 450 (Verdant Meadow) and artificial herb flavouring.")]"
	. += "\t[span_info("Storage: keep in a cool dry place. Do not use after the use-by date: 32/4/350.")]"
	return .

/obj/item/storage/box/gum/wake_up/PopulateContents()
	for(var/i in 1 to 4)
		new/obj/item/food/bubblegum/wake_up(src)

/obj/item/food/spacers_sidekick
	name = "\improper Spacer's Sidekick mints"
	desc = "Spacer's Sidekick: Breathe easy with a friend at your side!"
	icon_state = "spacers_sidekick"
	trash_type = /obj/item/trash/spacers_sidekick
	food_reagents = list(
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/menthol = 1,
		/datum/reagent/medicine/salbutamol = 1,
	)
	tastes = list("strong mint" = 1)
	junkiness = 15
	foodtypes = JUNKFOOD
	w_class = WEIGHT_CLASS_SMALL
