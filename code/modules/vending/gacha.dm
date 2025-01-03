/obj/machinery/vending/gacha
	name = "StellarPon Gacha Machine"
	desc = "A small vending machine full of colorful capsules. There's a label that says 'Chance for Super-Ultra-Turbo-Rare Platinum Figure!'."
	icon_state = "clothes"
	icon_deny = "clothes-deny"
	panel_type = "panel15"
	product_slogans = "Let's go gambling!;Open a capsule today!;Now with 20% more stars!"
	vend_reply = "Good luck! You'll need it!"
	product_categories = list(
		list(
			"name" = "Capsule",
			"icon" = "hat-cowboy",
			"products" = list(/obj/item/gift/capsule/ = 50)))
	refill_canister = /obj/item/vending_refill/gacha
	default_price = PAYCHECK_CREW * 0.3 //Default of
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES
	light_mask = "wardrobe-light-mask"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN

/obj/item/vending_refill/gacha
	machine_name = "StellarPon Gacha Machine"
	icon_state = "refill_clothes"
