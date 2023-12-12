//Basically vanilla+ stuff, doesn't experiment with cooked sausage since people may want to do stuff with that/ mildly out of scope - The beginning of the corndog crafting tree
/obj/item/food/raw_sausage/stick
	name = "raw sausage on a stick"
	trash_type = /obj/item/popsicle_stick
	icon = 'monkestation/icons/obj/food/corndog.dmi'
	icon_state = "rawsausage_stick"

/obj/item/food/raw_sausage/stick/rod
	name = "raw sausage on a rod"
	trash_type = /obj/item/stack/rods
	icon_state = "rawsausage_rod"

/obj/item/food/raw_sausage/attackby(obj/item/used_item, mob/living/user, params)
	if(istype(used_item, /obj/item/stack/rods))
		qdel(used_item)
		qdel(src)
		var/sausagestick = new /obj/item/food/raw_sausage/stick/rod
		user.put_in_hands(sausagestick)
	if(istype(used_item, /obj/item/popsicle_stick))
		used_item.use(1)
		qdel(src)
		var/sausagestick = new /obj/item/food/raw_sausage/stick
		user.put_in_hands(sausagestick)

//Where the real corndogging begins, CHOOSE YOUR CLASS
/obj/item/food/raw_corndog
	trash_type = /obj/item/popsicle_stick
	name = "raw corndog"
	desc = "A battered hot dog brimming with potential."
	icon = 'monkestation/icons/obj/food/corndog.dmi'
	icon_state = "corndog_raw_stick"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/cornmeal_batter = 1
	)
	tastes = list("raw meat" = 1, "raw batter" = 1, "hastiness" = 1)
	foodtypes = MEAT | RAW | GRAIN
	food_flags = FOOD_FINGER_FOOD
	eatverbs = list("bite", "chew", "nibble", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	venue_value = FOOD_PRICE_WORTHLESS

/obj/item/food/raw_corndog/rod
	trash_type = /obj/item/stack/rods
	icon_state = "corndog_raw_rod"

//Self explanatory, makes them bakeable. Sadly fryer crafting isn't a thing (atleast to my knowledge)
/obj/item/food/raw_corndog/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/corndog, rand(10 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/raw_corndog/rod/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/corndog/rod, rand(10 SECONDS, 20 SECONDS), TRUE, TRUE)

//The corndawgs themselves
/obj/item/food/corndog
	trash_type = /obj/item/popsicle_stick
	name = "corndog"
	desc = "A crispy hot dog coated in battery goodness!" //Could be better, any funnymen please suggest something
	icon = 'monkestation/icons/obj/food/corndog.dmi'
	icon_state = "corndog_stick"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("American freedom" = 1, "meat" = 1, "carnival food" = 1)
	foodtypes = MEAT | GRAIN
	food_flags = FOOD_FINGER_FOOD
	eatverbs = list("bite", "chew", "nibble", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/corndog/rod
	trash_type = /obj/item/stack/rods
	icon_state = "corndog_rod"

//Forbidden zone
/obj/item/food/corndog/akuma
	trash_type = /obj/item/stack/rods
	icon_state = "corndog_akuma"
	desc = "A demonic hotdog of occult origin." //wip
	tastes = list("EEEEEEEVIL" = 1, "meat" = 1, "the souls of the damned" = 1)
