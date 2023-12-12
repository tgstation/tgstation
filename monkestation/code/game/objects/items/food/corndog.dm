/obj/item/food/raw_corndog
	name = "raw corndog"
	desc = "A battered hot dog brimming with potential."
	icon = 'monkestation/icons/obj/food/corndog.dmi'
	icon_state = "corndog_raw"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/cornmeal_batter = 1
	)
	tastes = list("raw meat" = 1, "raw batter" = 1)
	foodtypes = MEAT | RAW | GRAIN
	food_flags = FOOD_FINGER_FOOD
	eatverbs = list("bite", "chew", "nibble", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	venue_value = FOOD_PRICE_WORTHLESS

/obj/item/food/raw_corndog/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/corndog, rand(10 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/raw_corndog/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/corndog/microwave_corndog)

/obj/item/food/corndog
	name = "corndog"
	desc = "A crispy hot dog coated in battery goodness!" //Could be better, any funnymen please suggest something
	icon = 'monkestation/icons/obj/food/corndog.dmi'
	icon_state = "corndog"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("American freedom" = 1, "meat" = 1, "carnival food" = 1)
	foodtypes = MEAT | GRAIN
	food_flags = FOOD_FINGER_FOOD
	eatverbs = list("bite", "chew", "nibble", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/corndog/microwave_corndog
	desc = "A run-of-the-mill corndog, a staple of space-carnivals everwhere! Mustard not included."
	icon_state = "lazydog"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("American \"freedom\"" = 1, "meat" = 1, "laziness" = 1)
	venue_value = FOOD_PRICE_CHEAP

//Handles what the corndog is skewered by and makes sure it changes the icon state and what type of skewer it leaves behind
/obj/item/food/corndog/attackby(obj/item/used_item, mob/living/user, params)
	if(istype(used_item, /obj/item/stack/rods))
		trash_type = /obj/item/stack/rods
		used_item.use(1)
		name += " on a rod"
		icon_state += "_rod"
		make_leave_trash()
	if(istype(used_item, /obj/item/popsicle_stick))
		trash_type = /obj/item/popsicle_stick
		qdel(used_item)
		name += " on a stick"
		icon_state += "_stick"
		make_leave_trash()
