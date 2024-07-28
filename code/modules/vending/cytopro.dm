/obj/machinery/vending/cytopro
	name = "\improper CytoPro"
	desc = "For all your cytology needs!"
	product_slogans = "Cloning? Don't be ridiculous.;Don't be uncultured, get some cells growing!;Who needs farms when we got vats?"
	product_ads = "Grow your own little creatures!;Biology, at your fingertips!"
	icon_state = "cytopro"
	icon_deny = "cytopro-deny"
	panel_type = "panel2"
	light_mask = "cytopro-light-mask"
	products = list(
		/obj/item/cultivator = 3,
		/obj/item/plant_analyzer = 4,
		/obj/item/reagent_containers/cup/bottle/nutrient/ez = 30,
		/obj/item/reagent_containers/cup/bottle/nutrient/l4z = 20,
		/obj/item/reagent_containers/cup/bottle/nutrient/rh = 10,
		/obj/item/reagent_containers/spray/pestspray = 20,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/secateurs = 3,
		/obj/item/shovel/spade = 3,
		/obj/item/storage/bag/plants = 5,
	)
	contraband = list(
		/obj/item/reagent_containers/cup/bottle/ammonia = 10,
		/obj/item/reagent_containers/cup/bottle/diethylamine = 5,
		/obj/item/reagent_containers/cup/bottle/saltpetre = 5,
	)
	refill_canister = /obj/item/vending_refill/cytopro
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/cytopro
	machine_name = "CytoPro"
	icon_state = "refill_plant"
