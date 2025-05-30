/obj/item/food/space_shuttle_jelly
	name = "space shuttle jelly"
	desc = "I like Space Shuttle Jelly, Space Shuttle Jelly for me. \nI like it for dinner, I like it for tea, a little each day is a good recipe. \nThe quality’s high as the name will imply, and it’s made from pure fruits, one more good reason why- \nI like Space Shuttle Jelly, Space Shuttle Jelly for me."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "space_shuttle_jelly"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("sugar" = 1, "strawberry" = 2)
	foodtypes = SUGAR|FRUIT
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP
	food_flags = FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_LICK


/obj/item/food/space_shuttle_jelly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)


/obj/item/food/raw_dim_sim
	name = "raw dim sim"
	desc = "A raw meat and cabbage filled dumpling. Cook this baby up!"
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "raw_dim_sim"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("meat" = 3, "cabbage" = 2, "seasoning" = 1)
	foodtypes = RAW|GRAIN|MEAT|VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	food_flags = FOOD_FINGER_FOOD|FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_SMUSH

/obj/item/food/raw_dim_sim/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/dim_sim)

/obj/item/food/dim_sim
	name = "dim sim"
	desc = "A meal invented by a Martian immigrant on Io, inspired by food back home. A fried dumpling full of meat, cabbage and seasonings. Goes well with soy sauce!"
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "dim_sim"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("meat" = 3, "cabbage" = 2, "seasoning" = 1)
	foodtypes = GRAIN|MEAT|VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_CHEAP
	food_flags = FOOD_FINGER_FOOD|FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_NEAT_FIT

/obj/item/food/dim_sim/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)


/obj/item/food/democracy_sausage
	name = "democracy sausage"
	desc = "It's compulsory to vote on Io, but stands selling these \"Democracy\" sausage sandwiches outside polling stations help draw in vote dodgers and raise money."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "democracy_sausage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("meat" = 1, "ketchup" = 1)
	bite_consumption = 4
	foodtypes = GRAIN|MEAT|VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP
	food_flags = FOOD_FINGER_FOOD|FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_NEAT_FIT


/obj/item/food/democracy_sausage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/lamington
	name = "lamington"
	desc = "A dessert delight from Io, a square of sponge cake coated with chocolate sauce and rolled in coconut."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "lamington"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 35,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/coco = 2,
	)
	tastes = list("chocolate" = 1, "coconut" = 1)
	foodtypes = GRAIN|DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_NORMAL
	food_flags = FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_CRUMBLE

/obj/item/food/lamington/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/lamington/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/lamington_slice, 5, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/lamington_slice
	name = "lamington slice"
	desc = "A small piece of lamington."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "lamington_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/sugar = 0.4,
		/datum/reagent/consumable/coco = 0.4,
	)
	tastes = list("chocolate" = 1, "coconut" = 1)
	foodtypes = GRAIN|DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_SMALL
	food_flags = FOOD_FINGER_FOOD
	venue_value = FOOD_PRICE_CHEAP
	food_flags = FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_CRUMBLE

/obj/item/food/lamington_slice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)


/obj/item/food/JC_lamington
	name = "jam and cream lamington"
	desc = "A twist on the classic, adding cream and strawberry jam inbetween slices of the cake."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "jam_cream_lamington"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 45,
		/datum/reagent/consumable/nutriment/vitamin = 15,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/coco = 2,
		/datum/reagent/consumable/cream = 5,
	)
	tastes = list("chocolate" = 1, "coconut" = 1, "jam" = 1, "cream" = 1)
	foodtypes = GRAIN|DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_NORMAL
	food_flags = FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_CRUMBLE

/obj/item/food/JC_lamington/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/JC_lamington/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/JC_lamington_slice, 5, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/JC_lamington_slice
	name = "jam and cream lamington slice"
	desc = "A small piece of jam and cream lamington."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "jam_cream_lamington_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 0.4,
		/datum/reagent/consumable/coco = 0.4,
		/datum/reagent/consumable/cream = 1,
	)
	tastes = list("chocolate" = 1, "coconut" = 1, "jam" = 1, "cream" = 1)
	foodtypes = GRAIN|DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_SMALL
	food_flags = FOOD_FINGER_FOOD
	venue_value = FOOD_PRICE_CHEAP
	food_flags = FOOD_TINY_SNOUT_EDIBLE
	snout_eat_message_category = SNOUT_EAT_MESSAGE_CATEGORY_CRUMBLE

/obj/item/food/JC_lamington_slice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/vegemite_toast
	name = "\improper Vegemite toast"
	desc = "A slab of toast with a salty spread from Io on it. But man, thats way too much dude..."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "vegemite_toast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/vegemite = 10,
	)
	tastes = list("salt" = 1, "toast" = 1)
	foodtypes = GRAIN|VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2


/obj/item/food/vegemite_toast/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/cheese_vegemite_scroll
	name = "cheese and Vegemite scroll"
	desc = "A 'classic' Io pastry. It's like a cinnamon roll but savory, with Vegemite and cheese."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "cheese_vegemite_scroll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/fat = 2,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/vegemite = 5,
	)
	tastes = list("salt" = 1, "cheese" = 1)
	foodtypes = GRAIN|VEGETABLES|DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cheese_vegemite_scroll/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/fairy_bread
	name = "fairy bread"
	desc = "ytpmv elf voice: gay people" // change this
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "fairy_bread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sprinkles = 2,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("butter" = 1, "sugar" = 1, "gay" = 1)
	foodtypes = GRAIN|SUGAR|DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fairy_bread/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/popsicle/golden_gaytime
	name = "\improper Golden Gaytime"
	desc = "It's so hard to have a Gaytime on your own!"
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "golden_gaytime"
	food_reagents = list(
		/datum/reagent/consumable/vanilla = 2,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/hot_coco = 4,
		/datum/reagent/consumable/caramel = 4,
	)
	tastes = list("vanilla" = 1, "toffee" = 1, "cream" = 1, "sugar" = 1, "gay" = 1)
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/popsicle/golden_gaytime/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/pie_floater
	name = "pie floater"
	desc = "'Pie floaters are an iconic Southern Io street food snack. This pie floater recipe features a crispy, flaky beef pie floating in a delicious homemade mushy pea soup.' - some recipe website i found"
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "pie_floater"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/ketchup = 5,
		/datum/reagent/consumable/nutriment/soup/pea = 30,
	)
	tastes = list("peas" = 1, "meat" = 1, "tomato sauce" = 1)
	foodtypes = GRAIN|VEGETABLES|MEAT
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	trash_type = /obj/item/reagent_containers/cup/bowl
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/pie_floater/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)


/obj/item/food/vanilla_slice
	name = "vanilla slice"
	desc = "Two slabs of puff pastry with a whole lot of incredibly fluffy vanilla custard stuffed in the middle, with icing slathered on the top! Io claims this as their own, though variations exist elsewhere. Also named snot block, snot brick, and phlegm cake."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "vanilla_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/vanillapudding = 20,
		/datum/reagent/consumable/sugar = 10,
	)
	tastes = list("custard" = 1, "sugar" = 1)
	foodtypes = DAIRY|GRAIN|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/food/vanilla_slice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/vanilla_slice/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/vanilla_slice_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/vanilla_slice_slice
	name = "vanilla slice slice"
	desc = "A slice of vanilla slice. Surely there isn't a vanilla slice slice slice..."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "vanilla_slice_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/vanillapudding = 5,
		/datum/reagent/consumable/sugar = 2.5,
	)
	tastes = list("custard" = 1, "sugar" = 1)
	foodtypes = DAIRY|GRAIN|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_SMALL
	food_flags = FOOD_FINGER_FOOD
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/vanilla_slice_slice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/love_food_buff, /datum/status_effect/food/speech/io)

/obj/item/food/vanilla_slice_slice/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/vanilla_slice_slice_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/vanilla_slice_slice_slice
	name = "vanilla slice slice slice"
	desc = "this is crumbs"
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "vanilla_slice_slice_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 0.5,
		/datum/reagent/consumable/vanillapudding = 0.8,
		/datum/reagent/consumable/sugar = 0.4,
	)
	tastes = list("custard" = 1, "sugar" = 1)
	foodtypes = DAIRY|GRAIN|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD
