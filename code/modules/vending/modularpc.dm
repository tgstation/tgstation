/obj/machinery/vending/modularpc
	name = "\improper Deluxe Silicate Selections"
	desc = "All the parts you need to build your own custom pc."
	icon_state = "modularpc"
	icon_deny = "modularpc-deny"
	panel_type = "panel21"
	light_mask = "modular-light-mask"
	product_ads = "Get your gamer gear!;The best GPUs for all of your space-crypto needs!;The most robust cooling!;The finest RGB in space!"
	vend_reply = "Game on!"
	products = list(
		/obj/item/computer_disk = 8,
		/obj/item/modular_computer/laptop = 4,
		/obj/item/modular_computer/pda = 4,
	)
	premium = list(
		/obj/item/pai_card = 2,
	)
	refill_canister = /obj/item/vending_refill/modularpc
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SCI
	allow_custom = TRUE

/obj/item/vending_refill/modularpc
	machine_name = "Deluxe Silicate Selections"
	icon_state = "refill_engi"
