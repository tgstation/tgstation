/obj/machinery/vending/donksofttoyvendor
	name = "\improper Donksoft Toy Vendor"
	desc = "Ages 8 and up approved vendor that dispenses toys."
	icon_state = "nt-donk"
	panel_type = "panel18"
	product_slogans = "Получите свои крутые игрушки уже сегодня!;Легализируйте охоту уже сегодня!;Качественное игрушечное оружие по низким ценам!;Отдайте их ГП за полный доступ!;Отдайте их ХоСу, чтобы вас отправили в перму!"
	product_ads = "Почувствуй себя робастом с нашими игрушками!;Вернитесь в детство уже сегодня!;Игрушечное оружие не убивает, но вы можете попробовать!;Кому нужна ответственность, когда есть игрушечное оружие?;Сделайте своё следующее убийство ВЕСЕЛЫМ!"
	vend_reply = "Возвращайтесь за добавкой!"
	light_mask = "donksoft-light-mask"
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
		/obj/item/storage/belt/sheath/katana/toy = 12,
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
