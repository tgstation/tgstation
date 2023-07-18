/obj/effect/spawner/random/vending/snackvend
	loot = list(
		/obj/machinery/vending/imported,
		/obj/machinery/vending/imported/yangyu,
		/obj/machinery/vending/imported/mothic,
		/obj/machinery/vending/imported/tizirian,
	)

/obj/effect/spawner/random/vending/colavend //These can serve both snacks AND drinks so its kinda both of them?
	loot = list(
		/obj/machinery/vending/imported,
		/obj/machinery/vending/imported/yangyu,
		/obj/machinery/vending/imported/mothic,
		/obj/machinery/vending/imported/tizirian,
	)

/datum/supply_pack/vending/imported/fill(obj/structure/closet/crate/target_crate)
	. = ..()
	for(var/obj/vendor_refill as anything in typesof(/obj/item/vending_refill/snack/imported))
		new vendor_refill(target_crate)

/obj/machinery/vending/imported
	name = "NT Sustenance Supplier"
	desc = "A vending machine serving up only the finest of human college student food."
	icon = 'monkestation/icons/obj/machines/imported_vendors.dmi'
	icon_state = "nt_food"
	panel_type = "panel15"
	light_mask = "nt_food-light-mask"
	light_color = LIGHT_COLOR_LIGHT_CYAN
	product_slogans = "Caution, contents may be selling hot!;Look at these low prices!;Hungry? Me too- Wait, no, you didn't hear that!"
	product_categories = list(
		list(
			"name" = "Snacks",
			"icon" = "cookie",
			"products" = list(
				/obj/item/food/peanuts/random = 6,
				/obj/item/food/cnds/random = 6,
				/obj/item/food/pistachios = 6,
				/obj/item/food/cornchips/random = 6,
				/obj/item/food/sosjerky = 6,
				/obj/item/reagent_containers/cup/soda_cans/cola = 6,
				/obj/item/reagent_containers/cup/soda_cans/lemon_lime = 6,
				/obj/item/reagent_containers/cup/soda_cans/starkist = 6,
				/obj/item/reagent_containers/cup/soda_cans/pwr_game = 6,
			),
		),
		list(
			"name" = "Meals",
			"icon" = "pizza-slice",
			"products" = list(
				/obj/item/storage/box/foodpack/nt = 6,
				/obj/item/storage/box/foodpack/nt/burger = 6,
				/obj/item/storage/box/foodpack/nt/chicken_sammy = 6,
				/obj/item/food/vendor_tray_meal/side = 6,
				/obj/item/food/vendor_tray_meal/side/crackers_and_jam = 6,
				/obj/item/food/vendor_tray_meal/side/crackers_and_cheese = 6,
			),
		),
	)

	refill_canister = /obj/item/vending_refill/snack/imported
	default_price = PAYCHECK_CREW * 0.5
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES

	/// What language should this vendor speak, for flavor reasons
	var/language_to_speak = /datum/language/common

/obj/machinery/vending/imported/New()
	. = ..()
	var/datum/language_holder/vendor_languages = get_language_holder()
	grant_all_languages()
	vendor_languages.selected_language = language_to_speak

/obj/item/vending_refill/snack/imported
	machine_name = "NT Sustenance Supplier"

/obj/machinery/vending/imported/yangyu
	name = "Fudobenda"
	desc = "A vendor selling traditional Sol eastern foods of dubious quality."
	icon_state = "yangyu_food"
	light_mask = "yangyu_food-light-mask"
	light_color = LIGHT_COLOR_FLARE
	product_slogans = "Fresh farmed space carp from local space!;Imitation lobstrocity sushi choices availible!;Made with traditional recipes and care!"
	product_categories = list(
		list(
			"name" = "Snacks",
			"icon" = "cookie",
			"products" = list(
				/obj/item/reagent_containers/cup/glass/dry_ramen/prepared = 6,
				/obj/item/reagent_containers/cup/glass/dry_ramen/prepared/hell = 6,
				/obj/item/food/vendor_snacks/rice_crackers = 6,
				/obj/item/food/vendor_snacks/mochi_ice_cream = 6,
				/obj/item/food/vendor_snacks/mochi_ice_cream/matcha = 6,
				/obj/item/reagent_containers/cup/glass/waterbottle/tea = 6,
				/obj/item/reagent_containers/cup/glass/waterbottle/tea/astra = 6,
				/obj/item/reagent_containers/cup/glass/waterbottle/tea/strawberry = 6,
				/obj/item/reagent_containers/cup/glass/waterbottle/tea/nip = 6,
			),
		),
		list(
			"name" = "Meals",
			"icon" = "pizza-slice",
			"products" = list(
				/obj/item/storage/box/foodpack/yangyu = 6,
				/obj/item/storage/box/foodpack/yangyu/sushi = 6,
				/obj/item/storage/box/foodpack/yangyu/beef_rice = 6,
				/obj/item/food/vendor_tray_meal/side/miso = 6,
				/obj/item/food/vendor_tray_meal/side/rice = 6,
				/obj/item/food/vendor_tray_meal/side/pickled_vegetables = 6,
			),
		),
	)

	refill_canister = /obj/item/vending_refill/snack/imported/yangyu
	language_to_speak = /datum/language/yangyu

/obj/machinery/vending/imported/yangyu/examine_more(mob/user)
	. = ..()
	. += span_notice("Someone appears to have written <i>\"Don't trust the sushi!\"</i> in marker on the side of the vendor.")
	return .

/obj/item/vending_refill/snack/imported/yangyu
	machine_name = "Fudobenda"

/obj/machinery/vending/imported/mothic
	name = "Nomad Fleet Ration Chit Exchange"
	desc = "One of the Nomad Fleet's own ration vendors; in spite of the name engraved into it, it's been fitted to accept credits."
	icon_state = "moth_food"
	light_mask = "moth_food-light-mask"
	light_color = LIGHT_COLOR_HALOGEN
	product_slogans = "Support the fleet, conserve rations today!;Some options in reduced portion and cost!;Do your part to keep the fleet flying!"
	product_categories = list(
		list(
			"name" = "Snacks",
			"icon" = "cookie",
			"products" = list(
				/obj/item/food/vendor_snacks/mothmallow = 6,
				/obj/item/food/vendor_snacks/moth_bag = 6,
				/obj/item/food/vendor_snacks/moth_bag/fuel_jack = 6,
				/obj/item/food/vendor_snacks/moth_bag/cheesecake = 6,
				/obj/item/food/vendor_snacks/moth_bag/cheesecake/honey = 6,
				/obj/item/reagent_containers/cup/soda_cans/monkestation/lemonade = 6,
				/obj/item/reagent_containers/cup/soda_cans/monkestation/navy_rum = 6,
				/obj/item/reagent_containers/cup/soda_cans/monkestation/soda_water_moth = 6,
				/obj/item/reagent_containers/cup/soda_cans/monkestation/ginger_beer = 6,
			),
		),
		list(
			"name" = "Meals",
			"icon" = "pizza-slice",
			"products" = list(
				/obj/item/storage/box/foodpack/moth = 6,
				/obj/item/storage/box/foodpack/moth/baked_rice = 6,
				/obj/item/storage/box/foodpack/moth/fuel_jack = 6,
				/obj/item/food/vendor_tray_meal/side/moffin = 6,
				/obj/item/food/vendor_tray_meal/side/cornbread = 6,
				/obj/item/food/vendor_tray_meal/side/roasted_seeds = 6,
			),
		),
	)

	refill_canister = /obj/item/vending_refill/snack/imported/mothic
	language_to_speak = /datum/language/moffic

/obj/item/vending_refill/snack/imported/mothic
	machine_name = "Nomad Fleet Ration Chit Exchange"

/obj/machinery/vending/imported/tizirian
	name = "Tizirian Imported Delicacies"
	desc = "A vendor serving a fine collection of what is very likely knock-offs of popular Tizirian brands."
	icon_state = "tiziria_food"
	light_mask = "tiziria_food-light-mask"
	light_color = LIGHT_COLOR_FIRE
	product_slogans = "Real imports from the capital itself, we promise!;Rare selections of salt water catch!;Moonfish glaze included with all meat options!"
	product_categories = list(
		list(
			"name" = "Snacks",
			"icon" = "cookie",
			"products" = list(
				/obj/item/food/chips/shrimp = 6,
				/obj/item/food/vendor_snacks/lizard_bag = 6,
				/obj/item/food/vendor_snacks/lizard_bag/moon_jerky = 6,
				/obj/item/food/vendor_snacks/lizard_box = 6,
				/obj/item/food/vendor_snacks/lizard_box/sweet_roll = 6,
				/obj/item/reagent_containers/cup/glass/bottle/mushi_kombucha = 6,
				/obj/item/reagent_containers/cup/glass/waterbottle/tea/mushroom = 6,
				/obj/item/reagent_containers/cup/soda_cans/monkestation/kortara = 6,
			),
		),
		list(
			"name" = "Meals",
			"icon" = "pizza-slice",
			"products" = list(
				/obj/item/storage/box/foodpack/tiziria = 6,
				/obj/item/storage/box/foodpack/tiziria/roll = 6,
				/obj/item/storage/box/foodpack/tiziria/stir_fry = 6,
				/obj/item/food/vendor_tray_meal/side/root_crackers = 6,
				/obj/item/food/vendor_tray_meal/side/korta_brittle = 6,
				/obj/item/food/vendor_tray_meal/side/crispy_headcheese = 6,
			),
		),
	)

	refill_canister = /obj/item/vending_refill/snack/imported/tizirian
	language_to_speak = /datum/language/draconic

/obj/item/vending_refill/snack/imported/tizirian
	machine_name = "Tizirian Imported Delicacies"
