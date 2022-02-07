//Lizard Foods, for lizards (and weird humans!)

//Meat Dishes

/obj/item/food/raw_tiziran_sausage
	name = "raw Tiziran blood sausage"
	desc = "A raw Tiziran blood sausage, ready to be cured on a drying rack."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "raw_lizard_sausage"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/blood = 3)
	tastes = list("meat" = 1, "black pudding" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/raw_tiziran_sausage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dryable, /obj/item/food/tiziran_sausage)

/obj/item/food/tiziran_sausage
	name = "\improper Tiziran blood sausage"
	desc = "A coarse dry-cured blood sausage, traditionally made by farmers in the farmlands around Zagoskeld. Similar in texture to old-Earth Spanish chorizo."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_sausage"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5)
	tastes = list("meat" = 1, "black pudding" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/raw_headcheese
	name = "raw headcheese block"
	desc = "A common food on Tizira, headcheese is traditionally made of an animal's head, with the organs removed, boiled until it falls apart, at which point it is collected, strained of moisture, salted heavily, packed into blocks, and left to dry and age for several months. The resulting hard block tastes similar to cheese."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "raw_lizard_cheese"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/salt = 5)
	tastes = list("meat" = 1, "salt" = 1)
	foodtypes = MEAT | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/raw_headcheese/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dryable,  /obj/item/food/headcheese)

/obj/item/food/headcheese
	name = "headcheese block"
	desc = "A cured block of headcheese. Delicious, if you're a lizard."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_cheese"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/salt = 5)
	tastes = list("cheese" = 1, "salt" = 1)
	foodtypes = MEAT | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/headcheese/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/headcheese_slice, 5, 30)

/obj/item/food/headcheese_slice
	name = "headcheese slice"
	desc = "A slice of headcheese, useful for making sandwiches and snacks. Or surviving the cold Tiziran winters."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_cheese_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/salt = 1)
	tastes = list("cheese" = 1, "salt" = 1)
	foodtypes = MEAT | GROSS
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/shredded_lungs
	name = "crispy shredded lung stirfry"
	desc = "Crispy lung strips, with veggies and a spicy sauce. Delicious, if you like lungs."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lung_stirfry"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/capsaicin = 1)
	tastes = list("meat" = 1, "heat" = 1, "veggies" = 1)
	foodtypes = MEAT | VEGETABLES | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/tsatsikh
	name = "tsatsikh"
	desc = "A Tiziran dish consisting of spiced ground offal, stuffed into a stomach and boiled. Pretty foul to anyone who's not used to the taste."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "tsatsikh"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5)
	tastes = list("assorted minced organs" = 1)
	foodtypes = MEAT | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/liver_pate
	name = "liver pate"
	desc = "A rich, meaty paste made from liver, meat, and a few additions for extra flavour."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "pate"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	tastes = list("liver" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/moonfish_eggs
	name = "moonfish eggs"
	desc = "The moonfish lays large, transparent white eggs which are prized in lizard cooking. Their flavour is similar to caviar, but generally is described as deeper and more complex."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "moonfish_eggs"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("caviar" = 1)
	foodtypes = SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/moonfish_caviar
	name = "moonfish caviar paste"
	desc = "A rich paste made from moonfish eggs. Generally the only way most lizards can get them, and used fairly heavily in coastal cooking."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "moonfish_caviar"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("caviar" = 1)
	foodtypes = SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/lizard_escargot
	name = "desert snail cocleas"
	desc = "Another example of cultural crossover between lizards and humans, desert snail escargot is closer to the Roman dish cocleas than the contemporary French escargot. It's a common street food in the desert cities."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_escargot"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/garlic = 1)
	tastes = list("snails" = 1, "garlic" = 1, "oil" = 1)
	foodtypes = MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/fried_blood_sausage
	name = "fried blood sausage"
	desc = "A blood sausage, battered and deep fried. Commonly served with fries as a quick and simple snack on the streets of Zagoskeld."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "fried_blood_sausage"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/salt = 1, /datum/reagent/consumable/cooking_oil = 1)
	tastes = list("black pudding" = 1, "batter" = 1, "oil" = 1)
	foodtypes = MEAT | FRIED
	w_class = WEIGHT_CLASS_SMALL

//Why does like, every language on the planet besides English call them pommes? Who knows, who cares- the lizards call them it too, because funny.
/obj/item/food/lizard_fries
	name = "loaded poms-franzisks"
	desc = "One of the many human foods to make its way to the lizards was french fries, which are called poms-franzisks in Draconic. When topped with barbecued meat and sauce, they make a hearty meal."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_fries"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/salt = 1, /datum/reagent/consumable/bbqsauce = 2)
	tastes = list("fries" = 2, "bbq sauce" = 1, "barbecued meat" = 1)
	foodtypes = MEAT | VEGETABLES | FRIED
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/brain_pate
	name = "eyeball-and-brain pate"
	desc = "A thick pink puree made from finely chopped poached eyeballs and brains, fried onions, and fat. Lizards swear it's delicious!"
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "brain_pate"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5)
	tastes = list("brains" = 2)
	foodtypes = MEAT | VEGETABLES | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/crispy_headcheese
	name = "crispy breaded headcheese"
	desc = "A delicious snack from the streets of Zagoskeld, consisting of headcheese coated in rootbread breadcrumbs. Commonly served with fries."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "crispy_headcheese"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cooking_oil = 1)
	tastes = list("cheese" = 1, "oil" = 1)
	foodtypes = MEAT | VEGETABLES | NUTS | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/kebab/picoss_skewers
	name = "picoss skewer"
	desc = "A popular Tiziran streetfood consisting of vinegar-marinated armorfish on a skewer with onion and chillis."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "picoss_skewer"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/vinegar= 1, /datum/reagent/consumable/capsaicin = 1)
	tastes = list("fish" = 1, "acid" = 1, "onion" = 1, "heat" = 1)
	foodtypes = SEAFOOD | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/nectar_larvae
	name = "nectar larvae"
	desc = "Little crispy larvae in a korta nectar based sweet and spicy sauce. Bugtastic!"
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "nectar_larvae"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/korta_nectar = 2, /datum/reagent/consumable/capsaicin = 1)
	tastes = list("meat" = 1, "sweet" = 1, "heat" = 1)
	foodtypes = GROSS | MEAT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/mushroomy_stirfry
	name = "mushroomy stirfry"
	desc = "A medley of mushrooms, made to meet your monstrous munchies. Marvelous!"
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "mushroomy_stirfry"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("marvelous mushrooms" = 1, "sublime shrooms" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

//Fish Dishes
/obj/item/food/grilled_moonfish
	name = "grilled moonfish"
	desc = "A slab of grilled moonfish. Traditionally served over scalloped roots with a wine-based sauce."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "grilled_moonfish"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment = 3)
	tastes = list("fish" = 1)
	foodtypes = SEAFOOD
	burns_on_grill = TRUE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/moonfish_demiglace
	name = "moonfish demiglace"
	desc = "A slab of beautifully seared moonfish on a bed of potatoes and carrots, with a wine and demiglace reduction on top. Simply marvelous."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "moonfish_demiglace"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment = 3)
	tastes = list("fish" = 1)
	foodtypes = SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/lizard_surf_n_turf
	name = "\improper Zagosk surf 'n' turf smorgasbord"
	desc = "A massive platter of Tizira's finest meat and seafood, typically shared by groups at the beach. Of course, nothing's stopping you eating it on your own... fatass."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "surf_n_turf"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("surf" = 1, "turf" = 1)
	foodtypes = MEAT | SEAFOOD | VEGETABLES
	w_class = WEIGHT_CLASS_BULKY

//Spaghetti Dishes

/obj/item/food/spaghetti/nizaya
	name = "nizaya pasta"
	desc = "A form of root and nut pasta originally native to the oceanside regions of Tizira. It's similar in texture and appearance to gnocchi."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "nizaya"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("gnocchi" = 1)
	foodtypes = VEGETABLES | NUTS

/obj/item/food/spaghetti/snail_nizaya
	name = "desert snail nizaya"
	desc = "A high class pasta dish from Tizira's vineyard region of Valyngia. Traditionally made with only the finest Tiziran wine... but the human swill will do, in a pinch."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "snail_nizaya"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("snails" = 1, "wine" = 1, "gnocchi" = 1)
	foodtypes = VEGETABLES | MEAT | NUTS

/obj/item/food/spaghetti/garlic_nizaya
	name = "garlic-and-oil nizaya"
	desc = "A lizard adaptation of the Italian pasta dish, aglio e olio, made with nizaya pasta."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "garlic_nizaya"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("garlic" = 1, "oil" = 1, "gnocchi" = 1)
	foodtypes = VEGETABLES | NUTS

/obj/item/food/spaghetti/demit_nizaya
	name = "demit nizaya"
	desc = "A sweet, creamy nizaya pasta dish made with korta milk and nectar."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "demit_nizaya"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/korta_nectar = 2)
	tastes = list("peppery sweet" = 1, "veggies" = 1, "gnocchi" = 1)
	foodtypes = VEGETABLES | SUGAR | NUTS

/obj/item/food/spaghetti/mushroom_nizaya
	name = "mushroom nizaya"
	desc = "A nizaya pasta dish made with seraka mushrooms and quality oil. Has a pronounced nutty flavour."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "mushroom_nizaya"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("savouriness" = 1, "nuttiness" = 1, "gnocchi" = 1)
	foodtypes = VEGETABLES

//Dough Dishes

/obj/item/food/rootdough
	name = "root dough"
	desc = "A root based dough, made with nuts and tubers. Used in a wide range of Tiziran cooking."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "rootdough"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("potato" = 1, "earthy heat" = 1)
	foodtypes = VEGETABLES | NUTS

/obj/item/food/rootdough/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/bread/root, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/food/rootdough/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/food/flatrootdough, 1, 30)

/obj/item/food/flatrootdough
	name = "flat rootdough"
	desc = "Flattened rootdough, ready to be made into a flatbread, or cut into segments."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "flat_rootdough"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("potato" = 1, "earthy heat" = 1)
	foodtypes = VEGETABLES | NUTS

/obj/item/food/flatrootdough/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/rootdoughslice, 3, 30)

/obj/item/food/flatrootdough/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/food/root_flatbread, rand(25 SECONDS, 35 SECONDS), TRUE, TRUE)

/obj/item/food/rootdoughslice
	name = "rootdough ball"
	desc = "A ball of root dough. Perfect for making pasta or rolls."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "rootdough_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("potato" = 1, "earthy heat" = 1)
	foodtypes = VEGETABLES | NUTS

/obj/item/food/rootdoughslice/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/spaghetti/nizaya, 1, 30)

/obj/item/food/rootdoughslice/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/rootroll, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/food/root_flatbread
	name = "root flatbread"
	desc = "A plain grilled root flatbread. Can be topped with a variety of foods that lizards like to eat."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "root_flatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 7)
	tastes = list("bread" = 1, "earthy heat" = 1)
	foodtypes = VEGETABLES | NUTS
	burns_on_grill = TRUE

/obj/item/food/rootroll
	name = "rootroll"
	desc = "A dense, chewy roll, made from roots. A nice companion to a bowl of soup."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "rootroll"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("roll" = 1) // the roll tastes of roll.
	foodtypes = VEGETABLES | NUTS
	burns_in_oven = TRUE

//Bread Dishes

/obj/item/food/bread/root
	name = "rootbread"
	desc = "The lizard equivalent to bread, made from tubers like potatoes and yams mixed with ground nuts and seeds. Noticably denser than regular bread."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_bread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("bread" = 8, "nuts" = 2)
	foodtypes = VEGETABLES | NUTS
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_CHEAP
	burns_in_oven = TRUE

/obj/item/food/bread/root/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/bread/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/bread/root/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/root, 5, 30)

/obj/item/food/breadslice/root
	name = "rootbread slice"
	desc = "A slice of dense, chewy rootbread."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_breadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("bread" = 8, "nuts" = 2)
	foodtypes = VEGETABLES | NUTS
	venue_value = FOOD_PRICE_TRASH

/obj/item/food/breadslice/root/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_STACK)

//Pizza Dishes
/obj/item/food/pizza/rustic_flatbread
	name = "rustic flatbread"
	desc = "A simple Tiziran country dish, popular as a side to meat or fish dishes. Topped with herbs and oil."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "rustic_flatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("bread" = 1, "herb" = 1, "oil" = 1, "garlic" = 1)
	slice_type = null
	foodtypes = VEGETABLES | NUTS
	boxtag = "Tiziran Flatbread"

/obj/item/food/pizza/italic_flatbread
	name = "\improper Italic flatbread"
	desc = "The introduction of human foods to Tizira led to an advancement in lizard cooking- the Italic flatbread is now a common sight on the menus of takeout stores on the planet."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "italic_flatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("bread" = 1, "herb" = 1, "oil" = 1, "garlic" = 1, "tomato" = 1, "meat" = 1)
	slice_type = null
	foodtypes = VEGETABLES | NUTS | MEAT
	boxtag = "Italic Flatbread"

/obj/item/food/pizza/imperial_flatbread
	name = "\improper Imperial flatbread"
	desc = "A flatbread topped with pate, pickled vegetables, and cubed headcheese. Not very suited to anyone's tastes but the lizards."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "imperial_flatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("bread" = 1, "herb" = 1, "oil" = 1, "garlic" = 1, "tomato" = 1, "meat" = 1)
	slice_type = null
	foodtypes = VEGETABLES | MEAT | NUTS | GROSS
	boxtag = "Imperial Victory Flatbread"

//Sandwiches/Toast Dishes
/obj/item/food/emperor_roll
	name = "emperor roll"
	desc = "A popular sandwich on Tizira, named in honour of the Imperial family."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "emperor_roll"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bread" = 1, "cheese" = 1, "liver" = 1, "caviar" = 1)
	foodtypes = VEGETABLES | NUTS | MEAT | GROSS | SEAFOOD
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/honey_roll
	name = "honey sweetroll"
	desc = "A sweetened rootroll with sliced fruit, enjoyed as a seasonal dessert on Tizira."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "honey_roll"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/honey = 2)
	tastes = list("bread" = 1, "honey" = 1, "fruit" = 1)
	foodtypes = VEGETABLES | NUTS | FRUIT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

//Soup Dishes
/obj/item/food/soup/atrakor_dumplings
	name = "\improper Atrakor dumpling soup"
	desc = "A bowl of rich, meaty dumpling soup, traditionally served during the festival of Atrakor's Might on Tizira. The dumplings are shaped like the Night Sky Lord himself."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "atrakor_dumplings"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bone broth" = 1, "onion" = 1, "potato" = 1)
	foodtypes = MEAT | VEGETABLES | NUTS

/obj/item/food/soup/meatball_noodles
	name = "meatball noodle soup"
	desc = "A hearty noodle soup made from meatballs and nizaya in a rich broth. Commonly topped with a handful of chopped nuts."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "meatball_noodles"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bone broth" = 1, "meat" = 1, "gnocchi" = 1, "peanuts" = 1)
	foodtypes = MEAT | VEGETABLES | NUTS

/obj/item/food/soup/black_broth
	name = "\improper Tiziran black broth"
	desc = "A bowl of sausage, onion, blood and vinegar, served ice cold. Every bit as rough as it sounds."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "black_broth"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/blood = 5)
	tastes = list("vinegar" = 1, "metal" = 1)
	foodtypes = MEAT | VEGETABLES | GROSS

/obj/item/food/soup/jellyfish
	name = "jellyfish stew"
	desc = "A slimy bowl of jellyfish stew. It jiggles if you shake it."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "jellyfish_stew"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment = 3)
	tastes = list("slime" = 1)
	foodtypes = MEAT | VEGETABLES | GROSS

/obj/item/food/soup/rootbread_soup
	name = "rootbread soup"
	desc = "A big bowl of spicy, savoury soup made with rootbread. Heavily seasoned, and very tasty."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "rootbread_soup"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("bread" = 1, "egg" = 1, "chili" = 1, "garlic" = 1)
	foodtypes = MEAT | VEGETABLES

//Egg Dishes
/obj/item/food/black_eggs
	name = "black scrambled eggs"
	desc = "A country dish from rural Tizira. Made with eggs, blood, and foraged greens. Traditionally eaten with rootbread and a spicy sauce."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "black_eggs"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("eggs" = 1, "greens" = 1, "blood" = 1)
	foodtypes = MEAT | BREAKFAST | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/patzikula
	name = "patzikula"
	desc = "A smooth and spicy tomato-based sauce topped with eggs and baked. Delicious."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "patzikula"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/capsaicin = 1)
	tastes = list("eggs" = 1, "tomato" = 1, "heat" = 1)
	foodtypes = VEGETABLES | MEAT | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL

//Cakes/Sweets

/obj/item/food/cake/korta_brittle
	name = "korta brittle slab"
	desc = "A big slab of korta nut brittle. So sugary it should be a crime!"
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "korta_brittle"
	food_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/korta_nectar = 5)
	tastes = list("peppery heat" = 1, "sweetness" = 1)
	foodtypes = NUTS | SUGAR

/obj/item/food/cake/korta_brittle/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/korta_brittle, 5, 30)

/obj/item/food/cakeslice/korta_brittle
	name = "korta brittle slice"
	desc = "A little slice of korta nut brittle. A diabetic's worst enemy."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "korta_brittle_slice"
	food_reagents = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/korta_nectar = 1)
	tastes = list("peppery heat" = 1, "sweetness" = 1)
	foodtypes = NUTS | SUGAR

/obj/item/food/snowcones/korta_ice
	name = "korta ice"
	desc = "Shaved ice, korta nectar and berries. A sweet treat to eat to beat summer heat!"
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "korta_ice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/ice = 4, /datum/reagent/consumable/berryjuice = 4)
	tastes = list("peppery sweet" = 1, "berry" = 1)
	foodtypes = NUTS | SUGAR | FRUIT

/obj/item/food/kebab/candied_mushrooms
	name = "candied mushrooms"
	desc = "A slightly bizarre dish from Tizira, consisting of seraka mushrooms coated with caramel on a skewer. Carries a pronounced 'sweet and savoury' kick."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "candied_mushrooms"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/caramel = 3)
	tastes = list("savouriness" = 1, "sweetness" = 1)
	foodtypes = SUGAR | VEGETABLES | GROSS

//Misc Dishes
/obj/item/food/sauerkraut
	name = "sauerkraut"
	desc = "Pickled cabbage, as made famous by Germans, and which has become common in lizard cooking, where it is known as Zauerkrat."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "sauerkraut"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("cabbage" = 1, "acid" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/lizard_dumplings
	name = "\improper Tiziran dumplings"
	desc = "Mashed root vegetables, mixed with korta flour and boiled to produce a large, round and slightly spicy dumpling. Commonly eaten in soup."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "lizard_dumplings"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("potato" = 1, "earthy heat" = 1)
	foodtypes = VEGETABLES | NUTS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/steeped_mushrooms
	name = "steeped seraka mushrooms"
	desc = "Seraka mushrooms that have been steeped in alkaline water to remove the extract, thereby making them completely safe to consume."
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "steeped_mushrooms"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("savouriness" = 1, "nuttiness" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/canned_jellyfish
	name = "canned gunner jellyfish"
	desc = "A can of gunner jellyfish packed in brine. Contains a mild hallucinogen which is destroyed by cooking."
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "canned_jellyfish"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/toxin/mindbreaker = 2, /datum/reagent/consumable/salt = 1)
	tastes = list("slime" = 1, "burning" = 1, "salt" = 1)
	foodtypes = SEAFOOD | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/desert_snails
	name = "canned desert snails"
	desc = "Giant snails from the Tiziran desert, packaged in brine. Shells included. Probably best not eaten raw, unless you're a lizard."
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "canned_snails"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/salt = 2)
	tastes = list("snails" = 1)
	foodtypes = MEAT | GROSS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/larvae
	name = "canned bee larva"
	desc = "A can of bee larva packaged in honey. Probably appetizing to someone."
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "canned_larvae"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/honey = 2)
	tastes = list("sweet bugs" = 1)
	foodtypes = MEAT | GROSS
	w_class = WEIGHT_CLASS_SMALL
