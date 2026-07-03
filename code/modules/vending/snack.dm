/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Попробуйте наш новый батончик с нугой!;Вдвое больше калорий за полцены!"
	product_ads = "Самые полезные!;Удостоенные наград шоколадные плитки!;Ммм! Как вкусно!;Боже мой, какой сочный!;Перекуси!;Закуски полезны для вас!;Запаситесь закусками Getmore!;Самые качественные закуски прямо с Марса.;Мы любим шоколад!;Попробуйте наше новое вяленое мясо!"
	icon_state = "snack"
	panel_type = "panel2"
	light_mask = "snack-light-mask"
	products = list(
		/obj/item/food/spacetwinkie = 6,
		/obj/item/food/cheesiehonkers = 6,
		/obj/item/food/candy = 6,
		/obj/item/food/chips = 6,
		/obj/item/food/chips/shrimp = 6,
		/obj/item/food/sosjerky = 6,
		/obj/item/food/cornchips/random = 6,
		/obj/item/food/sosjerky = 6,
		/obj/item/food/no_raisin = 6,
		/obj/item/food/peanuts = 6,
		/obj/item/food/peanuts/random = 3,
		/obj/item/food/cnds = 6,
		/obj/item/food/cnds/random = 3,
		/obj/item/food/semki = 6,
		/obj/item/reagent_containers/cup/glass/dry_ramen = 3,
		/obj/item/storage/box/gum = 3,
		/obj/item/food/energybar = 6,
		/obj/item/food/hot_shots = 6,
		/obj/item/food/sticko = 6,
		/obj/item/food/sticko/random = 3,
		/obj/item/food/shok_roks = 6,
		/obj/item/food/shok_roks/random = 3,
	)
	contraband = list(
		/obj/item/food/syndicake = 6,
		/obj/item/food/peanuts/ban_appeal = 3,
		/obj/item/food/candy/bronx = 1,
	)
	premium = list(
		/obj/item/food/spacers_sidekick = 3,
		/obj/item/food/pistachios = 3,
		/obj/item/food/swirl_lollipop = 3,
	)
	refill_canister = /obj/item/vending_refill/snack
	req_access = list(ACCESS_KITCHEN)
	default_price = PAYCHECK_CREW * 0.6
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"
	allow_custom = FALSE

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"
	allow_custom = FALSE

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"
	allow_custom = FALSE

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"
	allow_custom = FALSE
