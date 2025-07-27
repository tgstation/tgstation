//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	panel_type = "panel6"
	products = list(
		/obj/item/computer_disk/medical = 10,
		/obj/item/computer_disk/engineering = 10,
		/obj/item/computer_disk/security = 10,
		/obj/item/computer_disk/ordnance = 10,
		/obj/item/computer_disk/quartermaster = 10,
		/obj/item/computer_disk/command/captain = 3,
		/obj/item/modular_computer/pda = 10,
	)
	refill_canister = /obj/item/vending_refill/cart
	default_price = PAYCHECK_COMMAND
	extra_price = PAYCHECK_COMMAND * 2.5
	payment_department = ACCOUNT_SRV
	light_mask = "cart-light-mask"
	allow_custom = TRUE

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"
