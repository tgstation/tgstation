/obj/machinery/vending/donksofttoyvendor
	name = "\improper Donksoft Toy Vendor"
	desc = "Ages 8 and up approved vendor that dispenses toys."
	icon_state = "nt-donk"
	panel_type = "panel18"
	product_slogans = "Get your cool toys today!;Trigger a valid hunter today!;Quality toy weapons for cheap prices!;Give them to HoPs for all access!;Give them to HoS to get permabrigged!"
	product_ads = "Feel robust with your toys!;Express your inner child today!;Toy weapons don't kill people, but valid hunters do!;Who needs responsibilities when you have toy weapons?;Make your next murder FUN!"
	vend_reply = "Come back for more!"
	light_mask = "donksoft-light-mask"
	circuit = /obj/item/circuitboard/machine/vending/donksofttoyvendor
	products = list(
		/obj/item/card/emagfake = 4,
		/obj/item/hot_potato/harmless/toy = 4,
		/obj/item/toy/sword = 12,
		/obj/item/toy/foamblade = 12,
		/obj/item/gun/ballistic/automatic/pistol/toy = 8,
		/obj/item/gun/ballistic/automatic/toy = 8,
		/obj/item/gun/ballistic/shotgun/toy = 8,
		/obj/item/ammo_box/foambox/mini = 20,
	)
	contraband = list(
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 8,
		/obj/item/toy/katana = 12,
		/obj/item/ammo_box/foambox/riot/mini = 20,
	)
	premium = list(
		/obj/item/dualsaber/toy = 4,
		/obj/item/storage/box/fakesyndiesuit = 4,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted = 4,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 4,
	)
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES

/obj/item/vending_refill/donksoft
	machine_name = "Donksoft Toy Vendor"
	icon_state = "refill_donksoft"
