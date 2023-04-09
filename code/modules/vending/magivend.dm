/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	panel_type = "panel10"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/yellow = 1,
		/obj/item/clothing/suit/wizrobe/yellow = 1,
		/obj/item/clothing/shoes/sandal/magic = 1,
		/obj/item/staff = 2,
	)
	contraband = list(/obj/item/reagent_containers/cup/bottle/wizarditis = 1) //No one can get to the machine to hack it anyways; for the lulz - Microwave
	armor_type = /datum/armor/vending_magivend
	resistance_flags = FIRE_PROOF
	default_price = 0 //Just in case, since it's primary use is storage.
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV
	light_mask = "magivend-light-mask"

/datum/armor/vending_magivend
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50
