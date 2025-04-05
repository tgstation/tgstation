// Snacks and drinks for the 'snacks' tab of vendors

/obj/item/food/vendor_snacks
	name = "\improper God's Strongest Snacks"
	desc = "You best hope you aren't a sinner. (You should never see this item please report it)"
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "foodpack_generic"
	trash_type = /obj/item/trash/vendor_trash
	bite_consumption = 10
	food_reagents = list(/datum/reagent/consumable/nutriment = INFINITY)
	junkiness = 10
	custom_price = PAYCHECK_LOWER * INFINITY
	tastes = list("the unmatched power of the sun" = 10)
	foodtypes = JUNKFOOD | CLOTH | GORE | NUTS | FRIED | FRUIT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/trash/vendor_trash
	name = "\improper God's Weakest Snacks"
	desc = "The leftovers of what was likely a great snack in a past time."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "foodpack_generic_trash"
	custom_materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)

/*
*	NT Snacks
*/

/obj/item/food/vendor_snacks/nuke_fuel
	name = "\improper Nuke Fuel sour pickle"
	desc = "Once a nutritionally inert snack food, this one has been rendered by crimes against nutritional science into a rough taste facisimile \
	of 'Nuke Fuel' sour candies. Rumored to have given a kid on Mars stomach ulcers, but only because he ate seventeen in one day."
	icon_state = "nuke_fuel"
	trash_type = /obj/item/trash/vendor_trash/nuke_fuel
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/pickle = 2)
	tastes = list("cucumber" = 1, "battery acid" = 1, "sour brine" = 1)
	foodtypes = VEGETABLES | SUGAR
	custom_price = PAYCHECK_LOWER

/obj/item/food/vendor_snacks/nuke_fuel/make_leave_trash()
	AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_POPABLE)

/obj/item/trash/vendor_trash/nuke_fuel
	name = "empty pickle bag"
	desc = "The plasticine carcass of a bleak meal."
	icon_state = "nuke_fuel_trash"

/*
*	Mothic Snacks
*/

/obj/item/food/vendor_snacks/mothmallow
	name = "mothmallow"
	desc = "A vacuum sealed bag containing a pretty crushed looking mothmallow, someone save him!"
	icon_state = "mothmallow"
	trash_type = /obj/item/trash/vendor_trash/mothmallow
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 4)
	tastes = list("vanilla" = 1, "cotton" = 1, "chocolate" = 1)
	foodtypes = VEGETABLES | SUGAR
	custom_price = PAYCHECK_LOWER

/obj/item/food/vendor_snacks/mothmallow/make_leave_trash()
	AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_POPABLE)

/obj/item/trash/vendor_trash/mothmallow
	name = "empty mothmallow bag"
	desc = "Finally he is free."
	icon_state = "mothmallow_trash"

/obj/item/food/vendor_snacks/moth_bag
	name = "engine fodder"
	desc = "A vacuum sealed bag containing a small portion of colorful engine fodder."
	icon_state = "fodder"
	trash_type = /obj/item/trash/vendor_trash/moth_bag
	food_reagents = list(/datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/salt = 2)
	tastes = list("seeds" = 1, "nuts" = 1, "chocolate" = 1, "salt" = 1, "popcorn" = 1, "potato" = 1)
	foodtypes = GRAIN | NUTS | VEGETABLES | SUGAR
	custom_price = PAYCHECK_LOWER * 1.2

/obj/item/food/vendor_snacks/moth_bag/fuel_jack
	name = "fueljack's snack"
	desc = "A vacuum sealed bag containing a smaller than usual brick of fueljack's lunch, ultimately downgrading it to a fueljack's snack."
	icon_state = "fuel_jack_snack"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 1)
	tastes = list("cabbage" = 1, "potato" = 1, "onion" = 1, "chili" = 1, "cheese" = 1)
	foodtypes = DAIRY | VEGETABLES
	custom_price = PAYCHECK_LOWER * 1.2

/obj/item/food/vendor_snacks/moth_bag/cheesecake
	name = "chocolate cheesecake cube"
	desc = "A vacuum sealed bag containing a small cube of a mothic style cheesecake, this one is covered in chocolate."
	icon_state = "choco_cheese_cake"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/sugar = 4)
	tastes = list("cheesecake" = 1, "chocolate" = 1)
	foodtypes = SUGAR | FRIED | DAIRY | GRAIN
	custom_price = PAYCHECK_LOWER * 1.4

/obj/item/food/vendor_snacks/moth_bag/cheesecake/honey
	name = "honey cheesecake cube"
	desc = "A vacuum sealed bag containing a small cube of a mothic style cheesecake, this one is covered in honey."
	icon_state = "honey_cheese_cake"
	tastes = list("cheesecake" = 1, "honey" = 1)
	foodtypes = SUGAR | FRIED | DAIRY | GRAIN

/obj/item/trash/vendor_trash/moth_bag
	name = "empty mothic snack bag"
	desc = "The clear plastic reveals that this no longer holds tasty treats for your winged friends."
	icon_state = "moth_bag_trash"

/obj/item/reagent_containers/cup/soda_cans/doppler/lemonade
	name = "\improper Gyárhajó 1023: Lemonade"
	desc = "A can of lemonade, for those who are into that kind of thing, or just have no choice."
	icon_state = "lemonade"
	list_reagents = list(/datum/reagent/consumable/lemonade = 30)
	drink_type = FRUIT

/obj/item/reagent_containers/cup/soda_cans/doppler/lemonade/examine_more(mob/user)
	. = ..()
	. += span_notice("Markings on the can indicate this one was made on <i>factory ship 1023</i> of the Grand Nomad Fleet.")
	return .

/obj/item/reagent_containers/cup/soda_cans/doppler/navy_rum
	name = "\improper Gyárhajó 1506: Navy Rum"
	desc = "A can of navy rum brewed up and imported from a detachment of the nomad fleet, or so the can says."
	icon_state = "navy_rum"
	list_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 30)
	drink_type = ALCOHOL

/obj/item/reagent_containers/cup/soda_cans/doppler/navy_rum/examine_more(mob/user)
	. = ..()
	. += span_notice("Markings on the can indicate this one was made on <i>factory ship 1506</i> of the Grand Nomad Fleet.")
	return .

/obj/item/reagent_containers/cup/soda_cans/doppler/soda_water_moth
	name = "\improper Gyárhajó 1023: Soda Water"
	desc = "A can of soda water. Why not make a rum and soda? Now that you think of it, maybe not."
	icon_state = "soda_water"
	list_reagents = list(/datum/reagent/consumable/sodawater = 30)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/soda_cans/doppler/soda_water_moth/examine_more(mob/user)
	. = ..()
	. += span_notice("Markings on the can indicate this one was made on <i>factory ship 1023</i> of the Grand Nomad Fleet.")
	return .

/obj/item/reagent_containers/cup/soda_cans/doppler/ginger_beer
	name = "\improper Gyárhajó 1023: Ginger Beer"
	desc = "A can of ginger beer, don't let the beer part mislead you, this is entirely non-alcoholic."
	icon_state = "gingie_beer"
	list_reagents = list(/datum/reagent/consumable/sol_dry = 30)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/soda_cans/doppler/ginger_beer/examine_more(mob/user)
	. = ..()
	. += span_notice("Markings on the can indicate this one was made on <i>factory ship 1023</i> of the Grand Nomad Fleet.")
	return .

/*
*	Tiziran Snacks
*/

/obj/item/food/vendor_snacks/lizard_bag
	name = "candied mushroom"
	desc = "An odd treat of the lizard empire, a mushroom dipped in caramel; unfortunately, it seems to have been bagged before the caramel fully hardened."
	icon_state = "candied_shroom"
	trash_type = /obj/item/trash/vendor_trash/lizard_bag
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/caramel = 2)
	tastes = list("savouriness" = 1, "sweetness" = 1)
	foodtypes = SUGAR | VEGETABLES
	custom_price = PAYCHECK_LOWER * 1.4 //Tiziran imports are a bit more expensive overall

/obj/item/food/vendor_snacks/lizard_bag/make_leave_trash()
	AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_POPABLE)

/obj/item/food/vendor_snacks/lizard_bag/moon_jerky
	name = "moonfish jerky"
	desc = "A fish jerky, made from what you can only hope is moonfish. It also seems to taste subtly of barbecue"
	icon_state = "moon_jerky"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/bbqsauce = 2)
	tastes = list("fish" = 1, "smokey sauce" = 1)
	foodtypes = MEAT
	custom_price = PAYCHECK_LOWER * 1.6

/obj/item/trash/vendor_trash/lizard_bag
	name = "empty tiziran snack bag"
	desc = "All that money importing tiziran snacks just to end at this?"
	icon_state = "tizira_bag_trash"

/obj/item/food/vendor_snacks/lizard_box
	name = "tiziran dumplings"
	desc = "A three pack of tiziran style dumplings, not actually stuffed with anything."
	icon_state = "dumpling"
	trash_type = /obj/item/trash/vendor_trash/lizard_box
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("potato" = 1, "earthy heat" = 1)
	foodtypes = VEGETABLES | NUTS
	custom_price = PAYCHECK_LOWER * 1.6

/obj/item/food/vendor_snacks/lizard_box/sweet_roll
	name = "honey roll"
	desc = "Definitely don't let the guards find out that someone stole your last one."
	icon_state = "sweet_roll"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/honey = 2)
	tastes = list("bread" = 1, "honey" = 1, "fruit" = 1)
	foodtypes = VEGETABLES | NUTS | FRUIT
	custom_price = PAYCHECK_LOWER *1.8

/obj/item/trash/vendor_trash/lizard_box
	name = "empty tiziran snack box"
	desc = "Tizira, contributing to the space plastic crisis since 2530."
	icon_state = "tizira_box_trash"

/obj/item/reagent_containers/cup/glass/waterbottle/tea/mushroom
	name = "bottle of mushroom tea"
	desc = "A bottle of somewhat bitter mushroom tea, a favorite of the Tiziran empire."
	icon_state = "tea_bottle_grey"
	list_reagents = list(/datum/reagent/consumable/mushroom_tea = 40)
	custom_price = PAYCHECK_LOWER * 2

/obj/item/reagent_containers/cup/soda_cans/doppler/kortara
	name = "kortara"
	desc = "A can of kortara, alcohol brewed from korta seeds, which gives it a unique peppery spice flavor."
	icon_state = "kortara"
	list_reagents = list(/datum/reagent/consumable/ethanol/kortara = 30)
	drink_type = ALCOHOL

/*
*	Marsian Snacks
*/

/obj/item/reagent_containers/cup/soda_cans/doppler/red_beverage
	name = "\improper NULL STRENGTH Lemon-Grapefruit Fruit Cooler"
	desc = "The red and blue cans of the NULL STRENGTH line of shochu coolers became a minor memetic icon when the silly \
	commercials for Marsian holonet broadcasts were posted to the wider 'net."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "thin_can"
	list_reagents = list(/datum/reagent/consumable/ethanol/null_strength_lemon_grapefruit = 30)
	drink_type = ALCOHOL | FRUIT

/obj/item/reagent_containers/cup/soda_cans/doppler/yogurt_beverage
	name = "\improper Suannai yogurt soda"
	desc = "A refreshing, lightly carbonated yogurt drink that goes by nealy a dozen different names depending \
	on where you are. Supposedly good for your gut, but it's most commonly seen served alongside spicy food."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "yogurt_can"
	list_reagents = list(/datum/reagent/consumable/yogurt_soda = 30)
	drink_type = DAIRY

/obj/item/reagent_containers/cup/soda_cans/doppler/nevada_tea
	name = "\improper Nevada green tea"
	desc = "A staple item of fuel stations, bodegas, convenience stores, and checkout aisle coolers. Cheaper than water, \
	yet begging the question why."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "nevada_can"
	volume = 60
	list_reagents = list(/datum/reagent/consumable/icetea = 50, /datum/reagent/consumable/honey = 10)
	custom_price = PAYCHECK_LOWER

/obj/item/reagent_containers/cup/soda_cans/doppler/gakster_energy
	name = "\improper Gakster Energy™"
	desc = "First courting outrage over its commercialization of a cultural locii known to most by way of live combat footage and darkweb \
	snuff, this beverage later gained a dedicated countercultural following. Nine out of ten doctors recommend never, ever drinking this."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "gakster_energy_can"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/gakster_energy = 50)
	custom_price = PAYCHECK_COMMAND

/obj/item/reagent_containers/condiment/pack/chili
	name = "seasoning multi-pack"
	desc = "A spicy chili sauce, seasoning oil with shallots, and sweetened shoyu all in one convenient pack."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "sauce_pack"
	list_reagents = list(/datum/reagent/consumable/chili_fish_sauce = 10)
	possible_states = list(
		/datum/reagent/consumable/chili_fish_sauce = list("sauce_pack", "spicy chili sauce", "A spicy chili sauce, seasoning oil with shallots, and sweetened shoyu all in one convenient pack.")
	)

/obj/item/reagent_containers/cup/glass/dry_ramen/prepared
	name = "cup ramen"
	desc = "This one even comes with water, amazing!"
	list_reagents = list(/datum/reagent/consumable/hot_ramen = 15, /datum/reagent/consumable/salt = 3)

/obj/item/reagent_containers/cup/glass/dry_ramen/prepared/hell
	name = "spicy cup ramen"
	desc = "This one comes with water, AND a security checkpoint's worth of capsaicin!"
	list_reagents = list(/datum/reagent/consumable/hell_ramen = 15, /datum/reagent/consumable/salt = 3)

/obj/item/food/vendor_snacks/rice_crackers
	name = "rice crackers"
	desc = "Despite most of the package being clear, you will never truly know what flavor these are until you eat them."
	icon_state = "rice_cracka"
	trash_type = /obj/item/trash/vendor_trash/rice_crackers
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/rice = 2)
	tastes = list("incomprehensible flavoring" = 1, "rice cracker" = 2)
	foodtypes = JUNKFOOD | GRAIN
	custom_price = PAYCHECK_LOWER * 0.8

/obj/item/food/vendor_snacks/rice_crackers/make_leave_trash()
	AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_POPABLE)

/obj/item/trash/vendor_trash/rice_crackers
	name = "empty rice crackers bag"
	desc = "You never did find out what flavor that was supposed to be, did you?"
	icon_state = "rice_cracka_trash"

/obj/item/food/vendor_snacks/mochi_ice_cream
	name = "mochi ice cream balls - vanilla"
	desc = "A six pack of mochi ice cream, which is to say vanilla icecream surrounded by mochi. Comes with small plastic skewer for consumption."
	icon_state = "mochi_ice"
	trash_type = /obj/item/trash/vendor_trash/mochi_ice_cream
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/ice = 3)
	tastes = list("rice cake" = 2, "vanilla" = 2)
	foodtypes = JUNKFOOD | DAIRY | GRAIN
	custom_price = PAYCHECK_LOWER

/obj/item/food/vendor_snacks/mochi_ice_cream/matcha
	name = "mochi ice cream balls - matcha"
	desc = "A six pack of mochi ice cream - or, more specifically, matcha icecream surrounded by mochi. Comes with small plastic skewer for consumption."
	icon_state = "mochi_ice_green"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/tea = 2)
	tastes = list("rice cake" = 1, "bitter matcha" = 2)
	custom_price = PAYCHECK_LOWER * 1.2

/obj/item/food/vendor_snacks/mochi_ice_cream/matcha/examine_more(mob/user)
	. = ..()
	. += span_notice("A small label on the container specifies that this icecream is made using only culinary grade matcha grown outside of the Sol system.")
	return .

/obj/item/trash/vendor_trash/mochi_ice_cream
	name = "empty mochi ice cream tray"
	desc = "Somehow, that tiny plastic skewer it came with has gone missing."
	icon_state = "mochi_ice_trash"

/obj/item/reagent_containers/cup/glass/waterbottle/tea
	name = "bottle of tea"
	desc = "A bottle of tea brought to you in a convenient plastic bottle."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "tea_bottle"
	list_reagents = list(/datum/reagent/consumable/tea = 40)
	cap_icon_state = "bottle_cap_tea"
	flip_chance = 5
	custom_price = PAYCHECK_LOWER * 1.2
	fill_icon_state = null

/obj/item/reagent_containers/cup/glass/waterbottle/tea/astra
	name = "bottle of tea astra"
	desc = "A bottle of tea astra, known for the rather unusual tastes the leaf is known to give when brewed."
	icon_state = "tea_bottle_blue"
	list_reagents = list(
		/datum/reagent/consumable/tea = 25,
		/datum/reagent/medicine/salglu_solution = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	custom_price = PAYCHECK_LOWER * 2

/obj/item/reagent_containers/cup/glass/waterbottle/tea/strawberry
	name = "bottle of strawberry tea"
	desc = "A bottle of strawberry flavored tea; does not contain any actual strawberries."
	icon_state = "tea_bottle_pink"
	list_reagents = list(/datum/reagent/consumable/pinktea = 40)
	custom_price = PAYCHECK_LOWER * 2

/obj/item/reagent_containers/cup/glass/waterbottle/tea/nip
	name = "bottle of catnip tea"
	desc = "A bottle of catnip tea, required to be at or under a 50% concentration by the SFDA for safety purposes."
	icon_state = "tea_bottle_pink"
	list_reagents = list(
		/datum/reagent/consumable/catnip_tea = 20,
		/datum/reagent/consumable/pinkmilk = 20,
	)
	custom_price = PAYCHECK_LOWER * 2.5
