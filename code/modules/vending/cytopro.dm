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
		/obj/item/storage/bag/xeno = 5,
		/obj/item/reagent_containers/condiment/protein = 10,
		/obj/item/storage/box/swab = 3,
		/obj/item/storage/box/petridish = 3,
		/obj/item/storage/box/monkeycubes = 3,
		/obj/item/biopsy_tool = 3,
		/obj/item/clothing/under/rank/rnd/scientist = 5,
		/obj/item/clothing/suit/toggle/labcoat/science = 5,
		/obj/item/clothing/suit/bio_suit/scientist = 3,
		/obj/item/clothing/head/bio_hood/scientist = 3,
		/obj/item/reagent_containers/dropper = 5,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/petri_dish/random = 6,
	)
	contraband = list(
		/obj/item/knife/kitchen = 3,
	)
	refill_canister = /obj/item/vending_refill/cytopro
	default_price = PAYCHECK_CREW * 1
	extra_price = PAYCHECK_COMMAND * 0.5
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/cytopro
	machine_name = "CytoPro"
	icon_state = "refill_plant"
