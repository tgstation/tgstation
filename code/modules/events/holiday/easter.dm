/datum/round_event_control/easter
	name = "Easter Eggselence"
	holidayID = EASTER
	typepath = /datum/round_event/easter
	weight = -1
	max_occurrences = 1
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_HOLIDAY
	description = "Hides surprise filled easter eggs in maintenance."

/datum/round_event/easter/announce(fake)
	priority_announce(pick("Hip-hop into Easter!","Find some Bunny's stash!","Today is National 'Hunt a Wabbit' Day.","Be kind, give Chocolate Eggs!"))


/datum/round_event_control/rabbitrelease
	name = "Release the Rabbits!"
	holidayID = EASTER
	typepath = /datum/round_event/rabbitrelease
	weight = 5
	max_occurrences = 10
	category = EVENT_CATEGORY_HOLIDAY
	description = "Summons a wave of cute rabbits."

/datum/round_event/rabbitrelease/announce(fake)
	priority_announce("Unidentified furry objects detected coming aboard [station_name()]. Beware of Adorable-ness.", "Fluffy Alert", ANNOUNCER_ALIENS)


/datum/round_event/rabbitrelease/start()

	for(var/obj/effect/landmark/event_spawn/spawn_point as anything in GLOB.generic_event_spawns) //Common public bunnies
		if(prob(35))
			new /mob/living/basic/rabbit/easter(spawn_point.loc)
		CHECK_TICK

	for(var/obj/effect/landmark/event_spawn/spawn_point as anything in GLOB.generic_maintenance_landmarks) // The rare maint bunnies
		if(prob(15))
			new /mob/living/basic/rabbit/easter(spawn_point.loc)
		CHECK_TICK

	for(var/obj/effect/landmark/carpspawn/spawn_point in GLOB.landmarks_list) // The rare space bunnies
		if(prob(15))
			new /mob/living/basic/rabbit/easter/space(spawn_point.loc)
		CHECK_TICK


//Easter Baskets
/obj/item/storage/basket/easter
	name = "Easter Basket"
	storage_type = /datum/storage/basket/easter

//Bunny Suit
/obj/item/clothing/head/costume/bunnyhead
	name = "Easter Bunny head"
	icon_state = "bunnyhead"
	inhand_icon_state = null
	desc = "Considerably more cute than 'Frank'."
	slowdown = -0.3
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/costume/bunnysuit
	name = "easter bunny suit"
	desc = "Hop Hop Hop!"
	icon_state = "bunnysuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	slowdown = -0.3
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

//Bunny bag!
/obj/item/storage/backpack/satchel/bunnysatchel
	name = "easter bunny satchel"
	desc = "Good for your eyes."
	icon_state = "satchel_carrot"
	inhand_icon_state = null

//Egg prizes and egg spawns!
/obj/item/surprise_egg
	name = "wrapped egg"
	desc = "A chocolate egg containing a little something special. Unwrap and enjoy!"
	icon_state = "egg"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/food/egg.dmi'
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME

/obj/item/surprise_egg/Initialize(mapload)
	. = ..()
	var/eggcolor = pick("blue","green","mime","orange","purple","rainbow","red","yellow")
	icon_state = "egg-[eggcolor]"

/obj/item/surprise_egg/proc/dispensePrize(turf/where)
	var/static/list/prize_list = list(/obj/item/clothing/head/costume/bunnyhead,
		/obj/item/clothing/suit/costume/bunnysuit,
		/obj/item/storage/backpack/satchel/bunnysatchel,
		/obj/item/food/grown/carrot,
		/obj/item/toy/balloon,
		/obj/item/toy/gun,
		/obj/item/toy/sword,
		/obj/item/toy/talking/ai,
		/obj/item/toy/talking/owl,
		/obj/item/toy/talking/griffin,
		/obj/item/toy/minimeteor,
		/obj/item/toy/clockwork_watch,
		/obj/item/toy/toy_xeno,
		/obj/item/toy/foamblade,
		/obj/item/toy/plush/carpplushie,
		/obj/item/toy/redbutton,
		/obj/item/toy/windup_toolbox,
		/obj/item/clothing/head/collectable/rabbitears
		) + subtypesof(/obj/item/toy/mecha)
	var/won = pick(prize_list)
	new won(where)
	new/obj/item/food/chocolateegg(where)

/obj/item/surprise_egg/attack_self(mob/user)
	..()
	to_chat(user, span_notice("You unwrap [src] and find a prize inside!"))
	dispensePrize(get_turf(src))
	qdel(src)

//Easter Recipes + food
/obj/item/food/hotcrossbun
	name = "hot cross bun"
	desc = "The cross represents the Assistants that died for your sins."
	icon_state = "hotcrossbun"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/sugar = 1)
	foodtypes = SUGAR | GRAIN | BREAKFAST
	tastes = list("pastry" = 1, "easter" = 1)
	bite_consumption = 2
	crafting_complexity = FOOD_COMPLEXITY_1

/datum/crafting_recipe/food/hotcrossbun
	name = "Hot Cross Bun"
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/datum/reagent/consumable/sugar = 1
	)
	result = /obj/item/food/hotcrossbun
	added_foodtypes = SUGAR | BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/briochecake
	name = "Brioche cake"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/datum/reagent/consumable/sugar = 2
	)
	result = /obj/item/food/cake/brioche
	category = CAT_MISCFOOD

/obj/item/food/scotchegg
	name = "scotch egg"
	desc = "A boiled egg wrapped in a delicious, seasoned meatball."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "scotchegg"
	bite_consumption = 3
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	crafting_complexity = FOOD_COMPLEXITY_2
	foodtypes = MEAT

/datum/crafting_recipe/food/scotchegg
	name = "Scotch egg"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meatball = 1
	)
	result = /obj/item/food/scotchegg
	removed_foodtypes = BREAKFAST
	category = CAT_EGG

/datum/crafting_recipe/food/mammi
	name = "Mammi"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/food/bowled/mammi
	added_foodtypes = DAIRY
	category = CAT_MISCFOOD

/obj/item/food/chocolatebunny
	name = "chocolate bunny"
	desc = "Contains less than 10% real rabbit!"
	icon_state = "chocolatebunny"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	crafting_complexity = FOOD_COMPLEXITY_1
	foodtypes = JUNKFOOD | SUGAR

/datum/crafting_recipe/food/chocolatebunny
	name = "Chocolate bunny"
	reqs = list(
		/datum/reagent/consumable/sugar = 2,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chocolatebunny
	category = CAT_MISCFOOD
