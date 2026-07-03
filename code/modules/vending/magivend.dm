/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	panel_type = "panel10"
	product_slogans = "Колдуйте правильно с помощью MagiVend!;Станьте сами себе Гудини! Используйте MagiVend!"
	vend_reply = "Волшебного вечера!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234, ПСИХИ, ЛОЛ!;>КМК...;Завалите этих ебанашек!;ЗАБЕРИТЕ ЭТОТ ЧЕРТОВ ДИСК;ХОНК!;EI NATH;Админские драмы - вечны!;Разъебите станцию!;Устройства для искривления пространства-времени!"
	products = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/yellow = 1,
		/obj/item/clothing/suit/wizrobe/yellow = 1,
		/obj/item/clothing/head/wizard/black = 1,
		/obj/item/clothing/suit/wizrobe/black = 1,
		/obj/item/clothing/shoes/sandal/magic = 1,
		/obj/item/staff = 2,
	)
	contraband = list(/obj/item/reagent_containers/cup/bottle/wizarditis = 1) //No one can get to the machine to hack it anyways; for the lulz - Microwave
	armor_type = /datum/armor/vending_magivend
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/magivend
	default_price = 0 //Just in case, since its primary use is storage.
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

/obj/item/vending_refill/magivend
	machine_name = "MagiVend"
	icon_state = "refill_magivend"
