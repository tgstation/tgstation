/obj/machinery/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"
	icon_state = "syndi"
	panel_type = "panel18"
	product_slogans = "Получите крутые игрушки уже сегодня!;Запустите «Валидхантера» уже сегодня!;Качественное игрушечное оружие по низким ценам!;Подарите их ГП ради полного доступа!;Подарите их ГСБ для оформления в пермабриг!"
	product_ads = "Почувствуй себя робастом вместе со своими игрушками!;Прояви своего внутреннего ребенка прямо сейчас!;«Валидхантеры» убивают, а игрушечное оружие - нет!;Кому нужна ответственность, когда у тебя есть игрушечное оружие?;Сделай свое следующее убийство ВЕСЕЛЫМ!"
	vend_reply = "Приходите ещё!"
	products = list(
		/obj/item/card/emagfake = 4,
		/obj/item/hot_potato/harmless/toy = 4,
		/obj/item/toy/sword = 12,
		/obj/item/dualsaber/toy = 12,
		/obj/item/toy/foamblade = 12,
		/obj/item/gun/ballistic/automatic/pistol/toy/riot = 8,
		/obj/item/gun/ballistic/automatic/toy/riot = 8,
		/obj/item/gun/ballistic/shotgun/toy/riot = 8,
		/obj/item/ammo_box/foambox = 20,
	)
	contraband = list(
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/gun/ballistic/shotgun/toy/crossbow/riot = 8,
		/obj/item/storage/belt/sheath/katana/toy = 12,
	)
	premium = list(
		/obj/item/toy/cards/deck/syndicate = 12,
		/obj/item/storage/box/fakesyndiesuit = 4,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot = 4,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot = 4,
		/obj/item/ammo_box/foambox/riot = 20,
	)
	armor_type = /datum/armor/vending_toyliberationstation
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES
	light_mask = "donksoft-light-mask"
	allow_custom = FALSE

/datum/armor/vending_toyliberationstation
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50
