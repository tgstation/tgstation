///A special hotdog vending machine found in the cafeteria at the museum away mission, or during the hotdog holiday.
/obj/machinery/vending/hotdog
	name = "\improper Hotdoggo-Vend"
	desc = "An outdated hotdog vending machine, its prices stuck to those of 20 or so years ago."
	icon_state = "hotdog-vendor"
	icon_deny = "hotdog-vendor-deny"
	panel_type = "panel17"
	product_slogans = "Meatier than ever!;Now with 20% more MSG!;HOTDOGS!;Now Tirizan-friendly!"
	product_ads = "Your best and only automatic hotdog dispenser!;Serving you the finest buns since 2469!;Comes in 12 different flavors!"
	vend_reply = "Have a scrumptious meal!"
	light_mask = "hotdog-vendor-light-mask"
	default_price = PAYCHECK_LOWER
	product_categories = list(
		list(
			"name" = "Hotdogs",
			"icon" = "hotdog",
			"products" = list(
				/obj/item/food/hotdog = 8,
				/obj/item/food/pigblanket = 4,
				/obj/item/food/danish_hotdog = 4,
				/obj/item/food/little_hawaii_hotdog = 4,
				/obj/item/food/butterdog = 4,
				/obj/item/food/plasma_dog_supreme = 2,
			),
		),
		list(
			name = "Sausages",
			"icon" = FA_ICON_BACON,
			"products" = list(
				/obj/item/food/sausage = 8,
				/obj/item/food/tiziran_sausage = 4,
				/obj/item/food/fried_blood_sausage = 4,
			),
		),
		list(
			"name" = "Sauces",
			"icon" = FA_ICON_BOWL_FOOD,
			"products" = list(
				/obj/item/reagent_containers/condiment/pack/ketchup = 4,
				/obj/item/reagent_containers/condiment/pack/hotsauce = 4,
				/obj/item/reagent_containers/condiment/pack/bbqsauce = 4,
				/obj/item/reagent_containers/condiment/pack/soysauce = 4,
				/obj/item/reagent_containers/condiment/pack/mayonnaise = 4,
			),
		),
	)
	refill_canister = /obj/item/vending_refill/hotdog

/obj/item/vending_refill/hotdog
	machine_name = "\improper Hotdoggo-Vend"
	icon_state = "refill_snack"

/// Cute little thing that sets it apart from the other food vending mahicnes. I mean, you don't find this every day.
/obj/machinery/vending/hotdog/on_dispense(obj/item/vended_item, dispense_returned = FALSE)
	// Only apply to newly dispensed items
	if(dispense_returned)
		return
	if(istype(vended_item, /obj/item/food))
		ADD_TRAIT(vended_item, TRAIT_FOOD_CHEF_MADE, VENDING_MACHINE_TRAIT)
