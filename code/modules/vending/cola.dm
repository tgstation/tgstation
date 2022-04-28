
/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	panel_type = "panel2"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(
		/obj/item/reagent_containers/food/drinks/soda_cans/cola = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry = 10,
		/obj/item/reagent_containers/food/drinks/waterbottle = 10,
		/obj/item/reagent_containers/food/drinks/bottle/mushi_kombucha = 3
	)
	contraband = list(
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 6,
		/obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 6
	)
	premium = list(
		/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/air = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 1,
		/obj/item/reagent_containers/food/drinks/bottle/rootbeer = 1
	)
	refill_canister = /obj/item/vending_refill/cola
	default_price = PAYCHECK_CREW * 0.7
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV


/obj/item/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"

/obj/machinery/vending/cola/blue
	icon_state = "Cola_Machine"
	light_mask = "cola-light-mask"
	light_color = COLOR_MODERATE_BLUE

/obj/machinery/vending/cola/black
	icon_state = "cola_black"
	light_mask = "cola-light-mask"

/obj/machinery/vending/cola/red
	icon_state = "red_cola"
	name = "\improper Space Cola Vendor"
	desc = "It vends cola, in space."
	product_slogans = "Cola in space!"
	light_mask = "red_cola-light-mask"
	light_color = COLOR_DARK_RED

/obj/machinery/vending/cola/space_up
	icon_state = "space_up"
	name = "\improper Space-up! Vendor"
	desc = "Indulge in an explosion of flavor."
	product_slogans = "Space-up! Like a hull breach in your mouth."
	light_mask = "space_up-light-mask"
	light_color = COLOR_DARK_MODERATE_LIME_GREEN

/obj/machinery/vending/cola/starkist
	icon_state = "starkist"
	name = "\improper Star-kist Vendor"
	desc = "The taste of a star in liquid form."
	product_slogans = "Drink the stars! Star-kist!"
	panel_type = "panel7"
	light_mask = "starkist-light-mask"
	light_color = COLOR_LIGHT_ORANGE

/obj/machinery/vending/cola/sodie
	icon_state = "soda"
	panel_type = "panel7"
	light_mask = "soda-light-mask"
	light_color = COLOR_WHITE

/obj/machinery/vending/cola/pwr_game
	icon_state = "pwr_game"
	name = "\improper Pwr Game Vendor"
	desc = "You want it, we got it. Brought to you in partnership with Vlad's Salads."
	product_slogans = "The POWER that gamers crave! PWR GAME!"
	light_mask = "pwr_game-light-mask"
	light_color = COLOR_STRONG_VIOLET

/obj/machinery/vending/cola/shamblers
	name = "\improper Shambler's Vendor"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"
	products = list(/obj/item/reagent_containers/food/drinks/soda_cans/cola = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 10)
	product_slogans = "~Shake me up some of that Shambler's Juice!~"
	product_ads = "Refreshing!;Jyrbv dv lg jfdv fw kyrk Jyrdscvi'j Alztv!;Over 1 trillion souls drank!;Thirsty? Nyp efk uizeb kyv uribevjj?;Kyv Jyrdscvi uizebj kyv ezxyk!;Drink up!;Krjkp."
	light_mask = "shamblers-light-mask"
	light_color = COLOR_MOSTLY_PURE_PINK
