// Pizza (Whole)
/obj/item/food/pizza
	name = "pizza"
	icon = 'icons/obj/food/pizza.dmi'
	abstract_type = /obj/item/food/pizza
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	icon_state = "pizzamargherita"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 28,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_CHEAP
	crafting_complexity = FOOD_COMPLEXITY_2
	/// type is spawned 6 at a time and replaces this pizza when processed by cutting tool
	var/obj/item/food/pizzaslice/slice_type = /obj/item/food/pizzaslice
	///What label pizza boxes use if this pizza spawns in them.
	var/boxtag = ""
	/// how many slices left
	var/slices_left = 6
	/// have we been sliced? like sliced and you can take it apart by hand
	var/sliced = FALSE
	/// cutting tools
	var/list/cutting_tools = list(TOOL_KNIFE, TOOL_SAW, TOOL_SCALPEL)

/obj/item/food/pizza/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	register_context()

/obj/item/food/pizza/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(istype(held_item) && (held_item.tool_behaviour in cutting_tools))
		context[SCREENTIP_CONTEXT_LMB] = "Slice"
		context[SCREENTIP_CONTEXT_RMB] = "Slice apart"
		return TRUE

	if(sliced)
		context[SCREENTIP_CONTEXT_LMB] = "Take Slice"
		return TRUE

/obj/item/food/pizza/examine(mob/user)
	. = ..()
	if(isnull(slice_type) || !sliced)
		return
	. += span_notice("You can slice this to make it possible to take out slices with an empty hand!")

/obj/item/food/pizza/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(isnull(slice_type) || !(tool.tool_behaviour in cutting_tools))
		return
	if(!sliced)
		slice(user, tool)
		return ITEM_INTERACT_SUCCESS
	user.visible_message(span_notice("[user] seperates [src] into individual slices with [tool]."))
	cut_apart()
	return ITEM_INTERACT_SUCCESS

/obj/item/food/pizza/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(isnull(slice_type) || !(tool.tool_behaviour in cutting_tools))
		return
	visible_message(span_notice("[user] seperates [src] into individual slices with [tool]."))
	cut_apart()
	return ITEM_INTERACT_SUCCESS

/obj/item/food/pizza/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!sliced)
		return
	user.visible_message(span_notice("You take a slice of [src]."), span_notice("[user] takes a slice of [src]."))
	produce_slice(user)

/obj/item/food/pizza/proc/get_slices_filter() //to not repeat code
	return alpha_mask_filter(icon = icon('icons/obj/food/pizza.dmi', "[slices_left]slices"))

/// slices this pizza. all arguments optional.
/obj/item/food/pizza/proc/slice(mob/user, obj/item/tool)
	if(sliced)
		return
	tool?.play_tool_sound(src)
	sliced = TRUE
	user?.visible_message(span_notice("[user] cuts [src] into 6 slices with [tool]."))
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP

/obj/item/food/pizza/proc/cut_apart()
	for(var/_ in 1 to slices_left)
		produce_slice(no_update = TRUE)

/// make a slice and give it to user. no_update means no filter work is done. user is optional
/obj/item/food/pizza/proc/produce_slice(mob/user, no_update = FALSE)
	var/turf/our_turf = get_turf(src)
	var/obj/item/food/pizzaslice/slice = new slice_type(our_turf)
	if(HAS_TRAIT(src, TRAIT_FOOD_SILVER))
		ADD_TRAIT(slice, TRAIT_FOOD_SILVER, INNATE_TRAIT)
	if(HAS_TRAIT(src, TRAIT_FOOD_CHEF_MADE))
		ADD_TRAIT(slice, TRAIT_FOOD_CHEF_MADE, GET_TRAIT_SOURCES(src, TRAIT_FOOD_CHEF_MADE)[1]) // wack thing to inherit first source
	slice.pixel_x += rand(-6, 6)
	slice.pixel_y += rand(-6, 6)
	user?.put_in_active_hand(slice)
	slices_left--
	if(slices_left <= 0)
		qdel(src)
		return
	if(no_update)
		return
	remove_filter("pizzaslices")
	add_filter("pizzaslices", 1, get_slices_filter())

// Raw Pizza
/obj/item/food/pizza/raw
	foodtypes = GRAIN | RAW
	slice_type = null
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

// Pizza Slice
/obj/item/food/pizzaslice
	name = "pizza slice"
	icon = 'icons/obj/food/pizza.dmi'
	abstract_type = /obj/item/food/pizzaslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	icon_state = "pizzamargheritaslice"
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	decomp_type = /obj/item/food/pizzaslice/moldy
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/stack/sheet/pizza, 1, 1 SECONDS, table_required = TRUE, screentip_verb = "Flatten")

/obj/item/food/pizza/margherita
	name = "pizza margherita"
	desc = "The most cheezy pizza in galaxy."
	icon_state = "pizzamargherita"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/margherita
	boxtag = "Margherita Deluxe"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/margherita/raw
	name = "raw pizza margherita"
	icon_state = "pizzamargherita_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/margherita/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/margherita, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/margherita/robo
	food_reagents = list(
		/datum/reagent/cyborg_mutation_nanomachines = 70,
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)

/obj/item/food/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizzaslice/margherita/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ingredients_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 12)

/obj/item/food/pizza/meat
	name = "meatpizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT
	slice_type = /obj/item/food/pizzaslice/meat
	boxtag = "Meatlovers' Supreme"
	crafting_complexity = FOOD_COMPLEXITY_3
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 4)

/obj/item/food/pizza/meat/raw
	name = "raw meatpizza"
	icon_state = "meatpizza_raw"
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT | RAW
	slice_type = null

/obj/item/food/pizza/meat/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/meat, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meatpizza."
	icon_state = "meatpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizzaslice/meat/pizzeria //Reward for pizzeria bitrunning domain
	name = "pizzeria meatpizza slice"
	desc = "An ostensibly nutritious slice of meatpizza from a long-closed pizzeria."
	food_reagents = null
	tastes = list("crust" = 1, "ketchup" = 1, "'cheese'" = 1, "mystery meat" = 1, "glue" = 1)
	foodtypes = null

/obj/item/food/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 28,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mushroom
	boxtag = "Mushroom Special"
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/mushroom/raw
	name = "raw mushroom pizza"
	icon_state = "mushroompizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/mushroom/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mushroom, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2


/obj/item/food/pizza/vegetable
	name = "vegetable pizza"
	desc = "No one of Tomatoes Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/vegetable
	boxtag = "Gourmet Vegetable"
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/pizza/vegetable/raw
	name = "raw vegetable pizza"
	icon_state = "vegetablepizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/vegetable/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/vegetable, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "umami" = 1, "laziness" = 1)
	foodtypes = GRAIN|VEGETABLES|DAIRY|JUNKFOOD
	slice_type = /obj/item/food/pizzaslice/donkpocket
	boxtag = "Bangin' Donk"
	crafting_complexity = FOOD_COMPLEXITY_3
	intrinsic_food_materials = list(/datum/material/meat) //default donkpockets do not contain meat but homemade ones do.

/obj/item/food/pizza/donkpocket/raw
	name = "raw donkpocket pizza"
	icon_state = "donkpocketpizza_raw"
	foodtypes = GRAIN|VEGETABLES|DAIRY|JUNKFOOD|RAW
	slice_type = null

/obj/item/food/pizza/donkpocket/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/donkpocket, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "umami" = 1, "laziness" = 1)
	foodtypes = GRAIN|VEGETABLES|DAIRY|JUNKFOOD
	intrinsic_food_materials = list(/datum/material/meat) //default donkpockets do not contain meat but homemade ones do.

/obj/item/food/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/doctor_delight = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "weed" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/dank
	boxtag = "Fresh Herb"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/dank/raw
	name = "raw dank pizza"
	icon_state = "dankpizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/dank/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/dank, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "weed" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY

/obj/item/food/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can almost taste the sassiness."
	icon_state = "sassysagepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	slice_type = /obj/item/food/pizzaslice/sassysage
	boxtag = "Sausage Lovers"
	crafting_complexity = FOOD_COMPLEXITY_3
	custom_materials = list(/datum/material/meat = MEATSLAB_MATERIAL_AMOUNT)

/obj/item/food/pizza/sassysage/raw
	name = "raw sassysage pizza"
	icon_state = "sassysagepizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | RAW
	slice_type = null

/obj/item/food/pizza/sassysage/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/sassysage, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/pineapple
	name = "\improper Hawaiian pizza"
	desc = "The pizza equivalent of Einstein's riddle."
	icon_state = "pineapplepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/pineapplejuice = 8,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	slice_type = /obj/item/food/pizzaslice/pineapple
	boxtag = "Honolulu Chew"
	crafting_complexity = FOOD_COMPLEXITY_4
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 2)

/obj/item/food/pizza/pineapple/raw
	name = "raw Hawaiian pizza"
	icon_state = "pineapplepizza_raw"
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE | RAW
	slice_type = null

/obj/item/food/pizza/pineapple/raw/make_bakeable()
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
	desc = "This was once a perfectly good slice of pizza pie, but now it lies here, rancid and bursting with spores. \
		What a bummer! But we should not dwell on the past, only look towards the future."
	icon_state = "moldy_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/peptides = 3,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/toxin/amatoxin = 2,
	)
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
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/iron = 10,
		/datum/reagent/medicine/omnizine = 30,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	slice_type = /obj/item/food/pizzaslice/arnold
	boxtag = "9mm Pepperoni"
	foodtypes = MEAT|GRAIN|DAIRY|VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_4
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8, /datum/material/meat = MEATSLAB_MATERIAL_AMOUNT)

/obj/item/food/pizza/arnold/raw
	name = "raw Arnold pizza"
	icon_state = "arnoldpizza_raw"
	foodtypes = MEAT|GRAIN|DAIRY|VEGETABLES|RAW
	slice_type = null

/obj/item/food/pizza/arnold/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/arnold, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

//fuck it, i will leave this at the food level for now.
/obj/item/food/proc/try_break_off(mob/living/attacker, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	if(prob(50) || (attacker != user) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/obj/item/bodypart/arm/left = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/arm/right = user.get_bodypart(BODY_ZONE_R_ARM)
	var/did_the_thing = (left?.dismember() || right?.dismember()) //not all limbs can be removed, so important to check that we did. the. thing.
	if(!did_the_thing)
		return
	to_chat(user, span_userdanger("Maybe I'll give you a pizza, maybe I'll break off your arm.")) //makes the reference more obvious
	user.visible_message(span_warning("\The [src] breaks off [user]'s arm!"), span_warning("\The [src] breaks off your arm!"))
	playsound(user, SFX_DESECRATION, 50, TRUE, -1)

/obj/item/food/proc/i_kill_you(obj/item/item, mob/living/user)
	if(istype(item, /obj/item/food/pineappleslice))
		to_chat(user, "<font color='red' size='7'>If you want something crazy like pineapple, I'll kill you.</font>") //this is in bigger text because it's hard to spam something that gibs you, and so that you're perfectly aware of the reason why you died
		user.investigate_log("has been gibbed by putting pineapple on an arnold pizza.", INVESTIGATE_DEATHS)
		user.gib(DROP_ALL_REMAINS) //if you want something crazy like pineapple, i'll kill you
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
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizzaslice/arnold/attack(mob/living/target, mob/living/user)
	. =..()
	try_break_off(target, user)

/obj/item/food/pizzaslice/arnold/attackby(obj/item/item, mob/user)
	i_kill_you(item, user)
	. = ..()

// Ant Pizza, now with more ants.
/obj/item/food/pizzaslice/ants
	name = "\improper Ant Party pizza slice"
	desc = "The key to a perfect slice of pizza is not to overdo it with the ants."
	icon_state = "antpizzaslice"
	food_reagents = list(
		/datum/reagent/ants = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | BUGS

// Ethereal Pizza, for when they want a slice
/obj/item/food/pizza/energy
	name = "energy pizza"
	desc = "You could probably power a RIPLEY with this. You should avoid eating this if you aren't an Ethereal."
	icon_state ="energypizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 18,
		/datum/reagent/consumable/liquidelectricity/enriched = 18,
	)
	tastes = list("pure electricity" = 4, "pizza" = 2)
	slice_type = /obj/item/food/pizzaslice/energy
	foodtypes = GRAIN|TOXIC
	boxtag = "24 Hour Energy"
	crafting_complexity = FOOD_COMPLEXITY_2
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.4, /datum/material/glass = SMALL_MATERIAL_AMOUNT)

/obj/item/food/pizza/energy/raw
	name = "raw energy pizza"
	icon_state = "energypizza_raw"
	foodtypes = GRAIN|TOXIC|RAW
	slice_type = null

/obj/item/food/pizza/energy/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/energy, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/energy
	name = "energy pizza slice"
	desc = "You're thinking about using this to power your modsuit. You should avoid eating this if you aren't an Ethereal."
	icon_state ="energypizzaslice"
	tastes = list("pure electricity" = 4, "pizza" = 2)
	foodtypes = GRAIN|TOXIC
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/raw_meat_calzone
	name = "raw meat calzone"
	desc = "A raw calzone, ready to be put in the oven."
	icon_state = "raw_calzone"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("raw dough" = 1, "raw meat" = 1, "cheese" = 1, "tomato sauce" = 1)
	foodtypes = GRAIN|VEGETABLES|DAIRY|MEAT|RAW
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	custom_materials = list(/datum/material/meat = MEATSLAB_MATERIAL_AMOUNT)

/obj/item/food/raw_meat_calzone/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/meat_calzone, rand(20 SECONDS, 40 SECONDS), TRUE, TRUE)

/obj/item/food/meat_calzone
	name = "meat calzone"
	desc = "A calzone filled with cheese, meat, and a tomato sauce. Don't burn your tongue!."
	icon_state = "meat_calzone"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("baked dough" = 1, "juicy meat" = 1, "melted cheese" = 1, "tomato sauce" = 1)
	foodtypes = GRAIN|VEGETABLES|DAIRY|MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	custom_materials = list(/datum/material/meat = MEATSLAB_MATERIAL_AMOUNT)

/obj/item/food/raw_vegetarian_calzone
	name = "raw vegetarian calzone"
	desc = "A raw calzone, ready to be put in the oven."
	icon_state = "raw_calzone"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("raw dough" = 1, "vegetables" = 1, "tomato sauce" = 1)
	foodtypes = GRAIN|VEGETABLES|RAW
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/raw_vegetarian_calzone/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/vegetarian_calzone, rand(20 SECONDS, 40 SECONDS), TRUE, TRUE)

/obj/item/food/vegetarian_calzone
	name = "vegetarian calzone"
	desc = "A calzone filled with mixed vegetables and a tomato sauce. A healthier, yet less satisfying alternative."
	icon_state = "vegetarian_calzone"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("baked dough" = 1, "baked vegetables" = 1, "tomato sauce" = 1)
	foodtypes = GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
