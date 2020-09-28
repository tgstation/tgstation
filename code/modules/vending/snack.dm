/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	light_mask = "snack-light-mask"
	products = list(/obj/item/food/spacetwinkie = 6,
					/obj/item/food/cheesiehonkers = 6,
					/obj/item/food/candy = 6,
		            /obj/item/food/chips = 6,
		            /obj/item/food/sosjerky = 6,
					/obj/item/food/no_raisin = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 3,
					/obj/item/storage/box/gum = 3,
					/obj/item/food/energybar = 6)
	contraband = list(/obj/item/food/syndicake = 6,
					/obj/item/food/candy/bronx = 1)
	refill_canister = /obj/item/vending_refill/snack
	canload_access_list = list(ACCESS_KITCHEN)
	default_price = 60
	extra_price = 160
	payment_department = ACCOUNT_SRV
	input_display_header = "Chef's Food Selection"

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/machinery/vending/snack/random
	name = "\improper Random Snackies"
	icon_state = "random_snack"
	desc = "Uh oh!"

/obj/machinery/vending/snack/random/Initialize()
	// No need to call parent, we're not doing anything with this machine. Just picking a new type of machine to use, spawning it and deleting ourselves.
	SHOULD_CALL_PARENT(FALSE)

	var/T = pick(subtypesof(/obj/machinery/vending/snack) - /obj/machinery/vending/snack/random)
	new T(loc)
	return INITIALIZE_HINT_QDEL

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"
