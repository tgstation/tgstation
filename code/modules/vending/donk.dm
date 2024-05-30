/obj/machinery/vending/donksnack
	name = "\improper Donk Co Vendor"
	desc = "A snack machine courtesy of Donk Co."
	product_slogans = "Just microwave and eat!;The original home of the Donk Pocket!"
	product_ads = "The original!;You wanna put a bangin' Donk on it!;The best!;The seasoned traitor's food of choice!;Now with 12% more omnizine!;Eat DONK or DIE!;The galaxy's most popular microwavable snack food!*;Try our NEW Ready-Donk Meals!"
	icon_state = "snackdonk"
	panel_type = "panel18"
	light_mask = "donksoft-light-mask"
	circuit = /obj/item/circuitboard/machine/vending/donksnackvendor
	products = list(
		/obj/item/food/donkpocket = 6,
		/obj/item/food/donkpocket/berry = 6,
		/obj/item/food/donkpocket/honk = 6,
		/obj/item/food/donkpocket/pizza = 6,
		/obj/item/food/donkpocket/spicy = 6,
		/obj/item/food/donkpocket/teriyaki = 6,
		/obj/item/food/tatortot = 12,
	)
	contraband = list(
		/obj/item/food/waffles = 2,
		/obj/item/food/dankpocket = 2,
		/obj/item/food/donkpocket/gondola = 1,
	)
	premium = list(
		/obj/item/storage/box/donkpockets = 3,
		/obj/item/storage/box/donkpockets/donkpocketberry = 3,
		/obj/item/storage/box/donkpockets/donkpockethonk = 3,
		/obj/item/storage/box/donkpockets/donkpocketpizza = 3,
		/obj/item/storage/box/donkpockets/donkpocketspicy = 3,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki = 3,
		/obj/item/storage/belt/military/snack = 2,
		/obj/item/mod/module/microwave_beam = 1,
	)
	initial_language_holder = /datum/language_holder/syndicate
	refill_canister = /obj/item/vending_refill/donksnackvendor
	default_price = PAYCHECK_CREW * 1.4
	extra_price = PAYCHECK_CREW * 5
	payment_department = NO_FREEBIES

/obj/item/vending_refill/donksnackvendor
	machine_name = "Donk Co Snack Vendor"
	icon_state = "refill_donksnack"
