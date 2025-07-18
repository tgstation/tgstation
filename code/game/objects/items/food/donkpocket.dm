////////////////////////////////////////////DONK POCKETS////////////////////////////////////////////

/obj/item/food/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("umami" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

	/// What type of donk pocket we're warmed into via baking or microwaving.
	var/warm_type = /obj/item/food/donkpocket/warm
	/// Whether baking/microwaving it yields a positive result
	var/positive_result = TRUE
	/// The lower end for how long it takes to bake
	var/baking_time_short = 25 SECONDS
	/// The upper end for how long it takes to bake
	var/baking_time_long = 30 SECONDS
	/// The amount of omnizine added when it's cooked.
	var/omnizine_to_add = 6

/obj/item/food/donkpocket/make_bakeable()
	AddComponent(/datum/component/bakeable, warm_type, rand(baking_time_short, baking_time_long), positive_result, TRUE, list(/datum/reagent/medicine/omnizine = omnizine_to_add))

/obj/item/food/donkpocket/make_microwaveable()
	AddElement(/datum/element/microwavable, warm_type, string_assoc_list(list(/datum/reagent/medicine/omnizine = omnizine_to_add)), !positive_result)

/obj/item/food/donkpocket/warm
	name = "warm Donk-pocket"
	desc = "The heated food of choice for the seasoned traitor."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 6,
	)
	tastes = list("umami" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN

	// Warmed donk pockets will burn if you leave them in the oven or microwave.
	warm_type = /obj/item/food/badrecipe
	positive_result = FALSE
	baking_time_short = 10 SECONDS
	baking_time_long = 15 SECONDS
	omnizine_to_add = 0

/obj/item/food/donkpocket/homemade
	foodtypes = MEAT|GRAIN
	tastes = list("meat" = 2, "dough" = 2, "comfiness" = 1)
	warm_type = /obj/item/food/donkpocket/warm/homemade
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/warm/homemade
	foodtypes = MEAT|GRAIN
	tastes = list("meat" = 2, "dough" = 2, "comfiness" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/dank
	name = "\improper Dank-pocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	food_reagents = list(
		/datum/reagent/toxin/lipolicide = 3,
		/datum/reagent/drug/space_drugs = 3,
		/datum/reagent/consumable/nutriment = 4,
	)
	tastes = list("weed" = 2, "dough" = 2)
	foodtypes = GRAIN|VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2
	warm_type = /obj/item/food/donkpocket/warm/dank
	omnizine_to_add = 2

/obj/item/food/donkpocket/warm/dank
	name = "warm Dank-pocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	food_reagents = list(
		/datum/reagent/toxin/lipolicide = 3,
		/datum/reagent/drug/space_drugs = 3,
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/omnizine = 2,
	)
	tastes = list("weed" = 2, "dough" = 2)
	foodtypes = GRAIN|VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/donkpocket/spicy
	name = "\improper Spicy-pocket"
	desc = "The classic snack food, now with a heat-activated spicy flair."
	icon_state = "donkpocketspicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/capsaicin = 2,
	)
	tastes = list("umami" = 2, "dough" = 2, "spice" = 1)
	foodtypes = VEGETABLES|GRAIN
	warm_type = /obj/item/food/donkpocket/warm/spicy
	omnizine_to_add = 2

/obj/item/food/donkpocket/warm/spicy
	name = "warm Spicy-pocket"
	desc = "The classic snack food, now maybe a bit too spicy."
	icon_state = "donkpocketspicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/capsaicin = 5,
	)
	tastes = list("umami" = 2, "dough" = 2, "weird spices" = 2)
	foodtypes = VEGETABLES|GRAIN

/obj/item/food/donkpocket/spicy/homemade
	tastes = list("meat" = 2, "dough" = 2, "spice" = 1)
	foodtypes = MEAT|VEGETABLES|GRAIN
	warm_type = /obj/item/food/donkpocket/warm/spicy/homemade
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/warm/spicy/homemade
	tastes = list("meat" = 2, "dough" = 2, "weird spices" = 1)
	foodtypes = MEAT|VEGETABLES|GRAIN
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/teriyaki
	name = "\improper Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("umami" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN
	warm_type = /obj/item/food/donkpocket/warm/teriyaki
	omnizine_to_add = 2

/obj/item/food/donkpocket/warm/teriyaki
	name = "warm Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack, now steamy and warm."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("umami" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/teriyaki/homemade
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = MEAT|GRAIN
	warm_type = /obj/item/food/donkpocket/warm/teriyaki/homemade
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/warm/teriyaki/homemade
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = MEAT|GRAIN
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/pizza
	name = "\improper Pizza-pocket"
	desc = "Delicious, cheesy and surprisingly filling."
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/tomatojuice = 2,
	)
	tastes = list("tomato" = 2, "dough" = 2, "cheese"= 2)
	foodtypes = VEGETABLES|GRAIN|DAIRY
	warm_type = /obj/item/food/donkpocket/warm/pizza
	omnizine_to_add = 2

/obj/item/food/donkpocket/warm/pizza
	name = "warm Pizza-pocket"
	desc = "Delicious, cheesy, and even better when hot."
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/tomatojuice = 2,
	)
	tastes = list("tomato" = 2, "dough" = 2, "melty cheese"= 2)
	foodtypes = VEGETABLES|GRAIN|DAIRY

/obj/item/food/donkpocket/honk
	name = "\improper Honk-pocket"
	desc = "The award-winning donk-pocket that won the hearts of clowns and humans alike."
	icon_state = "donkpocketbanana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/banana = 4,
	)
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtypes = GRAIN|FRUIT|SUGAR
	warm_type = /obj/item/food/donkpocket/warm/honk
	crafting_complexity = FOOD_COMPLEXITY_3
	var/static/list/honk_added_reagents = list(
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/laughter = 6,
	)
	custom_materials = null

/obj/item/food/donkpocket/honk/make_bakeable()
	AddComponent(/datum/component/bakeable, warm_type, rand(baking_time_short, baking_time_long), positive_result, TRUE, honk_added_reagents)

/obj/item/food/donkpocket/honk/make_microwaveable()
	AddElement(/datum/element/microwavable, warm_type, honk_added_reagents, positive_result)

/obj/item/food/donkpocket/warm/honk
	name = "warm Honk-pocket"
	desc = "The award-winning donk-pocket, now warm and toasty."
	icon_state = "donkpocketbanana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/banana = 4,
		/datum/reagent/consumable/laughter = 6,
	)
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtypes = GRAIN|FRUIT|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3
	custom_materials = null

/obj/item/food/donkpocket/berry
	name = "\improper Berry-pocket"
	desc = "A relentlessly sweet donk-pocket first created for use in Operation Dessert Storm."
	icon_state = "donkpocketberry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/berryjuice = 3,
	)
	tastes = list("dough" = 2, "jam" = 2)
	foodtypes = GRAIN|FRUIT|SUGAR
	warm_type = /obj/item/food/donkpocket/warm/berry
	custom_materials = null
	omnizine_to_add = 2

/obj/item/food/donkpocket/warm/berry
	name = "warm Berry-pocket"
	desc = "A relentlessly sweet donk-pocket, now warm and delicious."
	icon_state = "donkpocketberry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/berryjuice = 3,
	)
	tastes = list("dough" = 2, "warm jam" = 2)
	foodtypes = GRAIN|FRUIT|SUGAR
	custom_materials = null

/obj/item/food/donkpocket/gondola
	name = "\improper Gondola-pocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least." //Only a monster would craft this.
	icon_state = "donkpocketgondola"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/gondola_mutation_toxin = 5,
	)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtypes = GRAIN|MEAT

	warm_type = /obj/item/food/donkpocket/warm/gondola
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)
	var/static/list/gondola_added_reagents = list(
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/gondola_mutation_toxin = 5,
	)

/obj/item/food/donkpocket/gondola/make_bakeable()
	AddComponent(/datum/component/bakeable, warm_type, rand(baking_time_short, baking_time_long), positive_result, TRUE, gondola_added_reagents)

/obj/item/food/donkpocket/gondola/make_microwaveable()
	AddElement(/datum/element/microwavable, warm_type, gondola_added_reagents, positive_result)

/obj/item/food/donkpocket/warm/gondola
	name = "warm Gondola-pocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least."
	icon_state = "donkpocketgondola"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/gondola_mutation_toxin = 10,
	)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtypes = GRAIN|MEAT
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/donkpocket/deluxe
	name = "\improper Donk-pocket Deluxe"
	desc = "Donk Co's latest product. Its recipe is a closely guarded secret."
	icon_state = "donkpocketdeluxe"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/medicine/omnizine = 2,
	)
	tastes = list("quality meat" = 2, "dough" = 2, "raw fanciness" = 1)
	foodtypes = GRAIN|MEAT|VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_4

	warm_type = /obj/item/food/donkpocket/warm/deluxe
	var/static/list/deluxe_added_reagents = list(
		/datum/reagent/medicine/omnizine = 8,
	)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 2)

/obj/item/food/donkpocket/deluxe/make_bakeable()
	AddComponent(/datum/component/bakeable, warm_type, rand(baking_time_short, baking_time_long), positive_result, TRUE, deluxe_added_reagents)

/obj/item/food/donkpocket/deluxe/make_microwaveable()
	AddElement(/datum/element/microwavable, warm_type, deluxe_added_reagents, positive_result)

/obj/item/food/donkpocket/warm/deluxe
	name = "warm Donk-pocket Deluxe"
	desc = "Donk Co's latest product. It's crispy warm and oh-so perfectly toasted. Damn, that's a good looking Donk."
	icon_state = "donkpocketdeluxe"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/medicine/omnizine = 10,
	)
	tastes = list("quality meat" = 2, "dough" = 2, "fanciness" = 1)
	foodtypes = GRAIN|MEAT|VEGETABLES|FRIED
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 2)

/obj/item/food/donkpocket/deluxe/nocarb
	name = "\improper Meat-pocket"
	desc = "The food of choice for the carnivorous traitor."
	icon_state = "donkpocketdeluxenocarb"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/medicine/omnizine = 2,
	)
	tastes = list("raw meat" = 2, "more meat" = 2, "no carbs" = 1)
	foodtypes = MEAT|RAW
	crafting_complexity = FOOD_COMPLEXITY_4
	warm_type = /obj/item/food/donkpocket/warm/deluxe/nocarb
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 4)

/obj/item/food/donkpocket/warm/deluxe/nocarb
	name = "warm Meat-pocket"
	desc = "The warm food of choice for the carnivorous traitor."
	icon_state = "donkpocketdeluxenocarb"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/medicine/omnizine = 10,
	)
	tastes = list("meat" = 2, "more meat" = 2, "no carbs" = 1)
	foodtypes = MEAT
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 4)

/obj/item/food/donkpocket/deluxe/vegan
	name = "\improper Donk-roll"
	desc = "The classic station snack, now with rice! Certified vegan and cruelty free by the Animal Liberation Front."
	icon_state = "donkpocketdeluxevegan"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/medicine/omnizine = 2,
	)
	tastes = list("rice patty" = 2, "dough" = 2, "peppery kick" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_4
	warm_type = /obj/item/food/donkpocket/warm/deluxe/vegan
	custom_materials = null

/obj/item/food/donkpocket/warm/deluxe/vegan
	name = "warm Donk-roll"
	desc = "The classic station snack, now with rice! It's been fried to perfection."
	icon_state = "donkpocketdeluxevegan"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/medicine/omnizine = 10,
	)
	tastes = list("rice patty" = 2, "fried dough" = 2, "peppery kick" = 1)
	foodtypes = GRAIN | VEGETABLES | FRIED
	custom_materials = null
