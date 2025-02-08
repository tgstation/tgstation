// Packaged whole meals and sides for the 'meals' tab of vendors

/* TRASH */

/obj/item/trash/empty_food_tray
	name = "empty plastic food tray"
	desc = "The condensation and what you can only hope are the leftovers of food make this a bit hard to reuse."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "foodtray_empty"
	custom_materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/item/trash/empty_side_pack
	name = "empty side wrapper"
	desc = "Unfortunately, this no longer holds any sides to distract you from the other 'food'."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "foodpack_generic_trash"
	custom_materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/item/trash/empty_side_pack/nt
	icon_state = "foodpack_nt_trash"

/obj/item/trash/empty_side_pack/moth
	icon_state = "foodpack_moth_trash"

/obj/item/trash/empty_side_pack/tizira
	icon_state = "foodpack_tizira_trash"

/obj/item/trash/empty_side_pack/marsian
	icon_state = "foodpack_marsian_trash"

/* MEALS */

/*
*	NT Meals
*/

/obj/item/food/vendor_tray_meal
	name = "\improper NT-Meal: Steak and Macaroni"
	desc = "A 'salisbury steak' drowning in something similar to a gravy, with a macaroni and cheese substitute mix sitting right beside it."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "foodtray_sad_steak"
	trash_type = /obj/item/trash/empty_food_tray
	food_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("meat?" = 2, "cheese?" = 2, "laziness" = 1)
	foodtypes = MEAT | GRAIN | DAIRY
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	///Does this food have the steam effect on it when initialized
	var/hot_and_steamy = TRUE

/obj/item/food/vendor_tray_meal/Initialize(mapload)
	. = ..()
	if(hot_and_steamy)
		overlays += mutable_appearance('icons/effects/steam.dmi', "steam_triple", ABOVE_OBJ_LAYER)

/obj/item/food/vendor_tray_meal/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse the back of the box...</i>")
	. += "\t[span_warning("Warning: Packaged in a factory where every allergen known is present.")]"
	. += "\t[span_warning("Warning: Contents might be hot.")]"
	. += "\t[span_info("Per 200g serving contains: 8g Sodium; 25g Fat, of which 22g are saturated; 2g Sugar.")]"
	return .

/obj/item/food/vendor_tray_meal/burger
	name = "\improper NT-Meal: Cheeseburger"
	desc = "A pretty sad looking burger with a kinda soggy bottom bun and highlighter yellow cheese."
	icon_state = "foodtray_burg"
	tastes = list("bread" = 2, "meat?" = 2, "cheese?" = 2, "laziness" = 1)
	foodtypes = MEAT | GRAIN | DAIRY

/obj/item/food/vendor_tray_meal/chicken_sandwich
	name = "\improper NT-Meal: Spicy Chicken Sandwich"
	desc = "A pretty sad looking chicken sandwich, the 'meat' patty is covered in so many manufactured spices that it has become an eerie red color."
	icon_state = "foodtray_chickie_sandwich"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/capsaicin = 10)
	tastes = list("bread" = 2, "chicken?" = 2, "overwhelming spice" = 2, "laziness" = 1)
	foodtypes = MEAT | GRAIN | DAIRY

/*
*	Mothic Meals
*/

/obj/item/food/vendor_tray_meal/pesto_pizza
	name = "\improper Main Course - Type M: Pesto Pizza"
	desc = "A rectangular pizza with a suspiciously bright green pesto in place of the standard tomato sauce."
	icon_state = "foodtray_pesto_pizza"
	tastes = list("tomato?" = 2, "cheese?" = 2, "herbs" = 1, "laziness" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES

/obj/item/food/vendor_tray_meal/baked_rice
	name = "\improper Main Course - Type M: Baked Rice and Grilled Cheese"
	desc = "Some sub-par looking fleet style rice, with a very grilled chunk of cheese."
	icon_state = "foodtray_rice_n_grilled_cheese"
	tastes = list("rice" = 2, "peppers" = 2, "charred cheese" = 2, "laziness" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES

/obj/item/food/vendor_tray_meal/fueljack
	name = "\improper Main Course - Type M: Fueljack's Tray"
	desc = "A flat chunk of fueljack's lunch, seemingly missing most of the usual variety in ingredients."
	icon_state = "foodtray_fuel_jacks_meal"
	tastes = list("potato" = 2, "cabbage" = 2, "cheese?" = 2, "laziness" = 1)
	foodtypes = DAIRY | VEGETABLES

/*
*	Tiziran Meals
*/

/obj/item/food/vendor_tray_meal/moonfish_nizaya
	name = "\improper Tizira Imports: Moonfish and Nizaya"
	desc = "An almost synthetic looking cut of moonfish, paired with an equal helping of nizaya pasta."
	icon_state = "foodtray_moonfish_nizaya"
	tastes = list("fish?" = 2, "cheap noodles" = 2, "laziness" = 1)
	foodtypes = VEGETABLES | NUTS | SEAFOOD

/obj/item/food/vendor_tray_meal/emperor_roll
	name = "\improper Tizira Imports: Emperor Roll"
	desc = "A pretty sad looking emperor roll, if you can even call it that; it seems caviar wasn't in the budget."
	icon_state = "foodtray_emperor_roll"
	tastes = list("bread" = 2, "cheese?" = 2, "liver?" = 2, "laziness" = 1)
	foodtypes = VEGETABLES | NUTS | MEAT | GORE

/obj/item/food/vendor_tray_meal/mushroom_fry
	name = "\improper Tizira Imports: Mushroom Stirfry"
	desc = "A mix of what was likely mushrooms too low quality to be used in making actual food, lightly fried and tossed in a plastic container together."
	icon_state = "foodtray_shroom_fry"
	tastes = list("mushroom" = 4, "becoming rich" = 1, "laziness" = 1)
	foodtypes = VEGETABLES

/*
*	Marsian Meals
*/

/obj/effect/spawner/random/vendor_tray_meal/burger_blind_bag
	name = "random marsian burger spawner"

/obj/effect/spawner/random/vendor_tray_meal/burger_blind_bag/Initialize(mapload)
	loot = list(
		/obj/item/food/vendor_tray_meal/chappy_patty,
		/obj/item/food/vendor_tray_meal/big_blue_burger,
	)
	. = ..()

/obj/item/food/vendor_tray_meal/chappy_patty
	name = "\improper Marsian MEGA-Main Course: Chappy Patty"
	desc = "Two slices of grilled Chap with cheese, topped with a fried egg between two buns."
	icon_state = "foodtray_chappy_patty"
	tastes = list("bun" = 1, "fried pork" = 2, "egg" = 1, "cheese" = 1, "ketchup" = 1)
	foodtypes = MEAT | GRAIN | DAIRY | VEGETABLES

/obj/item/food/vendor_tray_meal/big_blue_burger
	name = "\improper Marsian MEGA-Main Course: Big Blue Burger"
	desc = "The signature burger. Two patties, cheese, onions, bacon, and pineapple between two buns."
	icon_state = "foodtray_big_blue_burger"
	tastes = list("bun" = 1, "beef" = 2, "pineapple" = 1, "cheese" = 1, "bacon" = 1)
	foodtypes = MEAT | GRAIN | DAIRY | VEGETABLES | FRUIT

/obj/item/food/vendor_tray_meal/duck_crepe
	name = "\improper Marsian MEGA-Main Course: Peking duck crepes a l'orange"
	desc = "Crispy roasted duck served with thin, savory pancakes and garnished with spring onions. Any self-respecting restaurant in \
	the Grey will have it on the menu - and its popularity has led to this lesser, pre-packaged version."
	icon_state = "foodtray_duck_crepe"
	tastes = list("meat" = 1, "crepes" = 1, "orange" = 1)
	foodtypes = MEAT | DAIRY | VEGETABLES | FRUIT

/obj/item/food/vendor_tray_meal/mi_goreng
	name = "\improper Marsian MEGA-Main Course: Mi Goreng Shanjing"
	desc = "The Red Planet's take on the popular fried noodle dish. Shallots, garlic and shredded Tian mutton - all topped off with a fried egg."
	icon_state = "foodtray_mi_goreng"
	tastes = list("noodles" = 2, "fried pork" = 2, "egg" = 1, "garlic" = 1)
	foodtypes = MEAT | GRAIN | VEGETABLES

/obj/item/food/vendor_tray_meal/sushi
	name = "\improper Marsian MEGA-Main Course: Fresh Carp Rolls"
	desc = "A pair of sushi rolls, the appearance of which would suggest that the label is lying to you."
	icon_state = "foodtray_gas_station_sushi"
	tastes = list("imitation space carp" = 2, "stale rice" = 2, "laziness" = 1)
	foodtypes = GRAIN | SEAFOOD

/obj/item/food/vendor_tray_meal/beef_rice
	name = "\improper Marsian MEGA-Main Course: Beef and Fried Rice"
	desc = "A few slices of seemingly grilled beef, paired with a disproportionately large amount of rice."
	icon_state = "foodtray_beef_n_rice"
	tastes = list("cheap beef" = 1, "rice" = 3, "laziness" = 1)
	foodtypes = GRAIN | MEAT

/* SIDES */

/obj/effect/spawner/random/vendor_meal_sides
	name = "random side spawner"
	desc = "I hope I get one that actually matches my meal."
	icon_state = "loot"

/*
*	NT Sides
*/

/obj/effect/spawner/random/vendor_meal_sides/nt
	name = "random nt side spawner"

/obj/effect/spawner/random/vendor_meal_sides/nt/Initialize(mapload)
	loot = list(
		/obj/item/food/vendor_tray_meal/side,
		/obj/item/food/vendor_tray_meal/side/crackers_and_jam,
		/obj/item/food/vendor_tray_meal/side/crackers_and_cheese,
	)
	. = ..()

/obj/item/food/vendor_tray_meal/side
	name = "\improper NT-Side: Flatbread and Peanut Butter"
	desc = "A small stack of tough flatbread, and a small spread of peanut butter for each."
	icon_state = "foodpack_nt"
	trash_type = /obj/item/trash/empty_side_pack/nt
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("tough bread" = 2, "peanut butter" = 2)
	foodtypes = GRAIN
	hot_and_steamy = FALSE
	custom_price = PAYCHECK_LOWER * 2.5

/obj/item/food/vendor_tray_meal/side/crackers_and_jam
	name = "\improper NT-Side: Flatbread and Berry Jelly"
	desc = "A small stack of tough flatbread, and a small spread of nondescript berry jelly for each."
	tastes = list("tough bread" = 2, "berries" = 2)
	foodtypes = GRAIN | FRUIT

/obj/item/food/vendor_tray_meal/side/crackers_and_cheese
	name = "\improper NT-Side: Flatbread and Cheese Spread"
	desc = "A small stack of tough flatbread, and a small spread of cheese for each."
	tastes = list("tough bread" = 2, "cheese" = 2)
	foodtypes = GRAIN | DAIRY

/*
*	Mothic Sides
*/

/obj/effect/spawner/random/vendor_meal_sides/moth
	name = "random mothic side spawner"

/obj/effect/spawner/random/vendor_meal_sides/moth/Initialize(mapload)
	loot = list(
		/obj/item/food/vendor_tray_meal/side/moffin,
		/obj/item/food/vendor_tray_meal/side/cornbread,
		/obj/item/food/vendor_tray_meal/side/roasted_seeds,
	)
	. = ..()

/obj/item/food/vendor_tray_meal/side/moffin
	name = "\improper Side Course - Type M: Moffin"
	desc = "The result of taking a perfectly fine moffin, and flattening it into a more wafer-like form."
	icon_state = "foodpack_moth"
	trash_type = /obj/item/trash/empty_side_pack/moth
	tastes = list("fabric?" = 2, "sugar" = 2)
	foodtypes = CLOTH | GRAIN | SUGAR

/obj/item/food/vendor_tray_meal/side/cornbread
	name = "\improper Side Course - Type M: Cornbread"
	desc = "A flattened cut of sweetened cornbread, goes well with butter."
	icon_state = "foodpack_moth"
	trash_type = /obj/item/trash/empty_side_pack/moth
	tastes = list("cornbread" = 2, "sweetness" = 2)
	foodtypes = GRAIN | SUGAR

/obj/item/food/vendor_tray_meal/side/roasted_seeds
	name = "\improper Side Course - Type M: Roasted Seeds"
	desc = "A packet full of various oven roasted seeds."
	icon_state = "foodpack_moth"
	trash_type = /obj/item/trash/empty_side_pack/moth
	tastes = list("seeds" = 2, "char" = 2)
	foodtypes = NUTS

/*
*	Tiziran Sides
*/

/obj/effect/spawner/random/vendor_meal_sides/tizira
	name = "random tiziran side spawner"

/obj/effect/spawner/random/vendor_meal_sides/tizira/Initialize(mapload)
	loot = list(
		/obj/item/food/vendor_tray_meal/side/root_crackers,
		/obj/item/food/vendor_tray_meal/side/korta_brittle,
		/obj/item/food/vendor_tray_meal/side/crispy_headcheese,
	)
	. = ..()

/obj/item/food/vendor_tray_meal/side/root_crackers
	name = "\improper Tizira Imports: Rootbread Crackers and Pate"
	desc = "A small stack of rootbread crackers, with a small spread of meat pate for each."
	icon_state = "foodpack_tizira"
	trash_type = /obj/item/trash/empty_side_pack/tizira
	tastes = list("tough rootbread" = 2, "pate" = 2)
	foodtypes = VEGETABLES | NUTS | MEAT

/obj/item/food/vendor_tray_meal/side/korta_brittle
	name = "\improper Tizira Imports: Korta Brittle"
	desc = "A perfectly rectangular portion of unsweetened korta brittle."
	icon_state = "foodpack_tizira"
	trash_type = /obj/item/trash/empty_side_pack/tizira
	tastes = list("peppery heat" = 2)
	foodtypes = NUTS

/obj/item/food/vendor_tray_meal/side/crispy_headcheese
	name = "\improper Tizira Imports: Crisped Headcheese"
	desc = "A processed looking block of breaded headcheese."
	icon_state = "foodpack_tizira"
	trash_type = /obj/item/trash/empty_side_pack/tizira
	tastes = list("cheese" = 1, "oil" = 1)
	foodtypes = MEAT | VEGETABLES | NUTS | GORE

/*
* Marsian Sides
*/

/obj/effect/spawner/random/vendor_meal_sides/marsian
	name = "random marsian side spawner"

/obj/effect/spawner/random/vendor_meal_sides/marsian/Initialize(mapload)
	loot = list(
		/obj/item/food/vendor_tray_meal/side/chap_potama,
		/obj/item/food/vendor_tray_meal/side/haupia,
		/obj/item/food/sticko/random,
		/obj/item/food/vendor_tray_meal/side/roast_nori,
	)
	. = ..()

/obj/item/food/vendor_tray_meal/side/chap_potama
	name = "\improper chap potama"
	desc = "A sheet of seaweed with rice, all folded over a slice of premium Chap and a sheet of egg. Ubiquitous \
	in the lunchboxes of Red Marsians working at rural air exchange towers."
	icon_state = "chap_potama"
	trash_type = /obj/item/trash/empty_side_pack/chap_potama
	tastes = list("fried pork" = 2, "rice" = 2, "egg" = 1)
	foodtypes = GRAIN | MEAT | VEGETABLES

/obj/item/food/vendor_tray_meal/side/haupia
	name = "\improper haupia"
	desc = "A staple Marsian dessert. Sweetened coconut milk thickened into a pudding and sliced into portable squares. \
	This pre-packaged version doesn't compare to the homemade stuff, but it's guaranteed to comfort a homesick Marsian."
	icon_state = "haupia"
	trash_type = /obj/item/trash/empty_side_pack/haupia
	tastes = list("condensed coconut milk" = 2, "artificial sweetener" = 2)
	foodtypes = SUGAR

/obj/item/food/vendor_tray_meal/side/roast_nori
	name = "\improper roasted nori"
	desc = "Red algae was slurried into a fibre soup and poured into sheet molds. Once dried and seasoned it makes a \
	shelf stable snack that happens to scale well with hydroponic growth facilities, making it a cheap fixture across \
	Marsian arcologies."
	icon_state = "foodpack_marsian"
	trash_type = /obj/item/trash/empty_side_pack/roast_nori
	tastes = list("salt" = 1, "roasted seaweed" = 2)
	foodtypes = VEGETABLES

/obj/item/trash/empty_side_pack/chap_potama
	icon_state = "chap_potama-trash"

/obj/item/trash/empty_side_pack/haupia
	icon_state = "haupia-trash"

/obj/item/trash/empty_side_pack/roast_nori
	icon_state = "foodpack_marsian_trash"
