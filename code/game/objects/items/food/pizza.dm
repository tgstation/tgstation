// Pizza (Whole)
/obj/item/food/pizza
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	food_reagents = list(/datum/reagent/consumable/nutriment = 28, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	venue_value = FOOD_PRICE_CHEAP
	burns_in_oven = TRUE
	/// type is spawned 6 at a time and replaces this pizza when processed by cutting tool
	var/obj/item/food/pizzaslice/slice_type
	///What label pizza boxes use if this pizza spawns in them.
	var/boxtag = ""

/obj/item/food/pizza/raw
	foodtypes = GRAIN | DAIRY | VEGETABLES | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/MakeProcessable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, 6, 30)
		AddElement(/datum/element/processable, TOOL_SAW, slice_type, 6, 45)
		AddElement(/datum/element/processable, TOOL_SCALPEL, slice_type, 6, 60)

// Pizza Slice
/obj/item/food/pizzaslice
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	decomp_type = /obj/item/food/pizzaslice/moldy

/obj/item/food/pizzaslice/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/stack/sheet/pizza, 1, 10)


/obj/item/food/pizza/margherita
	name = "pizza margherita"
	desc = "The most cheezy pizza in galaxy."
	icon_state = "pizzamargherita"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/margherita
	boxtag = "Margherita Deluxe"


/obj/item/food/pizza/margherita/raw
	name = "raw pizza margherita"
	icon_state = "pizzamargherita_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/margherita/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/margherita, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/margherita/robo
	food_reagents = list(/datum/reagent/cyborg_mutation_nanomachines = 70, /datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)

/obj/item/food/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY

/obj/item/food/pizzaslice/margherita/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 12)

/obj/item/food/pizza/meat
	name = "meatpizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 8)
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT
	slice_type = /obj/item/food/pizzaslice/meat
	boxtag = "Meatlovers' Supreme"

/obj/item/food/pizza/meat/raw
	name = "raw meatpizza"
	icon_state = "meatpizza_raw"
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/meat/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/meat, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meatpizza."
	icon_state = "meatpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/food/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 28, /datum/reagent/consumable/nutriment/protein = 3,  /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mushroom
	boxtag = "Mushroom Special"

/obj/item/food/pizza/mushroom/raw
	name = "raw mushroom pizza"
	icon_state = "mushroompizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/mushroom/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mushroom, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/vegetable
	name = "vegetable pizza"
	desc = "No one of Tomatos Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/oculine = 12, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/vegetable
	boxtag = "Gourmet Vegetable"
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/pizza/vegetable/raw
	name = "raw vegetable pizza"
	icon_state = "vegetablepizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/vegetable/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/vegetable, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/omnizine = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	slice_type = /obj/item/food/pizzaslice/donkpocket
	boxtag = "Bangin' Donk"

/obj/item/food/pizza/donkpocket/raw
	name = "raw donkpocket pizza"
	icon_state = "donkpocketpizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/donkpocket/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/donkpocket, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD


/obj/item/food/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/doctor_delight = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/dank
	boxtag = "Fresh Herb"

/obj/item/food/pizza/dank/raw
	name = "raw dank pizza"
	icon_state = "dankpizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/dank/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/dank, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY


/obj/item/food/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can almost taste the sassiness."
	icon_state = "sassysagepizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	slice_type = /obj/item/food/pizzaslice/sassysage
	boxtag = "Sausage Lovers"

/obj/item/food/pizza/sassysage/raw
	name = "raw sassysage pizza"
	icon_state = "sassysagepizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/sassysage/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/sassysage, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT


/obj/item/food/pizza/pineapple
	name = "\improper Hawaiian pizza"
	desc = "The pizza equivalent of Einstein's riddle."
	icon_state = "pineapplepizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/pineapplejuice = 8)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	slice_type = /obj/item/food/pizzaslice/pineapple
	boxtag = "Honolulu Chew"

/obj/item/food/pizza/pineapple/raw
	name = "raw Hawaiian pizza"
	icon_state = "pineapplepizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/pineapple/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/pineapple, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/pineapple
	name = "\improper Hawaiian pizza slice"
	desc = "A slice of delicious controversy."
	icon_state = "pineapplepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE


// Moldly Pizza
// Used in cytobiology.
/obj/item/food/pizzaslice/moldy
	name = "moldy pizza slice"
	desc = "This was once a perfectly good slice of pizza pie, but now it lies here, rancid and bursting with spores. What a bummer! But we should not dwell on the past, only look towards the future."
	icon_state = "moldy_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/peptides = 3, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/toxin/amatoxin = 2)
	tastes = list("stale crust" = 1, "rancid cheese" = 2, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
	preserved_food = TRUE

/obj/item/food/pizzaslice/moldy/bacteria
	name = "bacteria rich moldy pizza slice"
	desc = "Not only is this once delicious pizza encrusted with a layer of spore-spewing fungus, it also seems to shift and slide when unattended, teeming with new life."

/obj/item/food/pizzaslice/moldy/bacteria/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2, 4), 25)


// Arnold Pizza
// Has meme code.
/obj/item/food/pizza/arnold
	name = "\improper Arnold pizza"
	desc = "Hello, you've reached Arnold's pizza shop. I'm not here now, I'm out killing pepperoni."
	icon_state = "arnoldpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 9, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/iron = 10, /datum/reagent/medicine/omnizine = 30)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	slice_type = /obj/item/food/pizzaslice/arnold
	boxtag = "9mm Pepperoni"

/obj/item/food/pizza/arnold/raw
	name = "raw Arnold pizza"
	icon_state = "arnoldpizza_raw"
	foodtypes = GRAIN | DAIRY | VEGETABLES | RAW
	burns_in_oven = FALSE
	slice_type = null

/obj/item/food/pizza/arnold/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/arnold, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

//fuck it, i will leave this at the food level for now.
/obj/item/food/proc/try_break_off(mob/living/attacker, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	if(prob(50) || (attacker != user) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/obj/item/bodypart/l_arm = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = user.get_bodypart(BODY_ZONE_R_ARM)
	var/did_the_thing = (l_arm?.dismember() || r_arm?.dismember()) //not all limbs can be removed, so important to check that we did. the. thing.
	if(!did_the_thing)
		return
	to_chat(user, span_userdanger("Maybe I'll give you a pizza, maybe I'll break off your arm.")) //makes the reference more obvious
	user.visible_message(span_warning("\The [src] breaks off [user]'s arm!"), span_warning("\The [src] breaks off your arm!"))
	playsound(user, "desecration", 50, TRUE, -1)

/obj/item/food/proc/i_kill_you(obj/item/item, mob/living/user)
	if(istype(item, /obj/item/food/pineappleslice))
		to_chat(user, "<font color='red' size='7'>If you want something crazy like pineapple, I'll kill you.</font>") //this is in bigger text because it's hard to spam something that gibs you, and so that you're perfectly aware of the reason why you died
		user.gib() //if you want something crazy like pineapple, i'll kill you
	else if(istype(item, /obj/item/food/grown/mushroom) && iscarbon(user))
		to_chat(user, span_userdanger("So, if you want mushroom, shut up.")) //not as large as the pineapple text, because you could in theory spam it
		var/mob/living/carbon/shutup = user
		shutup.gain_trauma(/datum/brain_trauma/severe/mute)

/obj/item/food/pizza/arnold/attack(mob/living/target, mob/living/user)
	. = ..()
	try_break_off(target, user)

/obj/item/food/pizza/arnold/attackby(obj/item/item, mob/user)
	i_kill_you(item, user)
	. = ..()

/obj/item/food/pizzaslice/arnold
	name = "\improper Arnold pizza slice"
	desc = "I come over, maybe I give you a pizza, maybe I break off your arm."
	icon_state = "arnoldpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/food/pizzaslice/arnold/attack(mob/living/target, mob/living/user)
	. =..()
	try_break_off(target, user)

/obj/item/food/pizzaslice/arnold/attackby(obj/item/item, mob/user)
	i_kill_you(item, user)
	. = ..()

// Ant Pizza, now with more ants.
/obj/item/food/pizza/ants
	name = "\improper Ant Party pizza"
	desc = "/// Filled with bugs, remember to fix"
	icon_state = "antpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/ants = 25, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
	slice_type = /obj/item/food/pizzaslice/ants
	boxtag = "Anthill Deluxe"

/obj/item/food/pizzaslice/ants
	name = "\improper Ant Party pizza slice"
	desc = "The key to a perfect slice of pizza is not to overdo it with the ants."
	icon_state = "antpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
