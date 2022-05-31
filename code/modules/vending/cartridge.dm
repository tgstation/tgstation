//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	panel_type = "panel6"
	products = list(
		/obj/item/computer_hardware/hard_drive/role/medical = 10,
		/obj/item/computer_hardware/hard_drive/role/engineering = 10,
		/obj/item/computer_hardware/hard_drive/role/security = 10,
		/obj/item/computer_hardware/hard_drive/role/janitor = 10,
		/obj/item/computer_hardware/hard_drive/role/signal/ordnance = 10,
		/obj/item/modular_computer/tablet/pda/heads = 10,
		/obj/item/computer_hardware/hard_drive/role/captain = 3,
		/obj/item/computer_hardware/hard_drive/role/quartermaster = 10
	)
	refill_canister = /obj/item/vending_refill/cart
	default_price = PAYCHECK_COMMAND
	extra_price = PAYCHECK_COMMAND * 2.5
	payment_department = ACCOUNT_SRV
	light_mask="cart-light-mask"

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

