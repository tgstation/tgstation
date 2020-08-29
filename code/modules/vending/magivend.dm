/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_reply = "Have an enchanted evening!"
	product_ads = "EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(/obj/item/clothing/head/wizard = 3,
		            /obj/item/clothing/suit/wizrobe = 3,
		            /obj/item/clothing/head/wizard/red = 3,
		            /obj/item/clothing/suit/wizrobe/red = 3,
		            /obj/item/clothing/head/wizard/yellow = 3,
		            /obj/item/clothing/suit/wizrobe/yellow = 3,
		            /obj/item/clothing/shoes/sandal/magic = 3,
		            /obj/item/staff = 3)
	contraband = list(/obj/item/staff = 2)	//An admin will probably spawn a multitool, screwdriver, and emag ALL ON ACCIDENT
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	default_price = 250
	extra_price = 500
	payment_department = ACCOUNT_SRV
	light_mask = "magivend-light-mask"
