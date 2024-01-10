//Sprites done by Camriod_Core - Bounty Requested by Camriod_Core, financed by Iamcooldan for 2000 monkecoins

//Basically vanilla+ stuff, doesn't experiment with cooked sausage since people may want to do stuff with that/ mildly out of scope - The beginning of the corndog crafting tree
/obj/item/food/raw_sausage_stick //Does't inherit raw_sausage to avoid weird behavior with attackby()
	name = "raw sausage on a stick"
	desc = "Simply put, a sausage on a stick."
	trash_type = /obj/item/popsicle_stick
	icon = 'monkestation/icons/obj/food/corndog.dmi'
	icon_state = "rawsausage_stick"
	food_reagents = list(
	/datum/reagent/consumable/nutriment/protein = 5,
	/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	eatverbs = list("bite", "chew", "nibble", "deep throat", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/raw_sausage_stick/rod
	name = "raw sausage on a rod"
	desc = "Simply put, a sausage on a rod."
	trash_type = /obj/item/stack/rods
	icon_state = "rawsausage_rod"

/obj/item/food/raw_sausage/attackby(obj/item/used_item, mob/living/user, params)
	if(istype(used_item, /obj/item/popsicle_stick))
		qdel(used_item)
		qdel(src)
		var/sausagestick = new /obj/item/food/raw_sausage_stick
		user.put_in_hands(sausagestick)
	if(istype(used_item, /obj/item/stack/rods))
		used_item.use(1)
		qdel(src)
		var/sausagestick = new /obj/item/food/raw_sausage_stick/rod
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
	desc = "The best thing to come out of 1900s America."
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
	burns_in_oven = TRUE
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/corndog/rod
	trash_type = /obj/item/stack/rods
	icon_state = "corndog_rod"

/obj/item/food/corndog/fullcondiment //End of the corndog crafting tree, no name change so frying it doesn't give a weird name
	icon_state = "corndog_stick_km"
	desc = "The best thing to come out of 1900s America paired with the best thing to come out of 1800s America, paired with, hey- Just how old is mustard?"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/ketchup = 5
	)
	tastes = list("American superiority" = 1, "carnival food" = 1, "mustard" = 1)

/obj/item/food/corndog/fullcondiment/rod
	trash_type = /obj/item/stack/rods
	icon_state = "corndog_rod_km"

//Forbidden corndog corner
/obj/item/food/corndog/NarDog
	name = "Nar’Dog"
	icon_state = "demondog"
	food_reagents = list(
	/datum/reagent/consumable/nutriment/protein = 15,
	/datum/reagent/consumable/nutriment/vitamin = 10,
	/datum/reagent/consumable/ethanol/narsour = 10,
	/datum/reagent/brimdust = 4
	)
	desc = "A demonic corndog of occult origin, <font color=#ae0000>it glows with an unholy power...</font>"
	tastes = list("brimstone" = 1, "the souls of the damned" = 1)
	foodtypes = MEAT | GRAIN | ALCOHOL
	venue_value = FOOD_PRICE_EXOTIC
