/obj/machinery/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"
	icon_state = "syndi"
	panel_type = "panel18"
	product_slogans = "Get your cool toys today!;Trigger a valid hunter today!;Quality toy weapons for cheap prices!;Give them to HoPs for all access!;Give them to HoS to get permabrigged!"
	product_ads = "Feel robust with your toys!;Express your inner child today!;Toy weapons don't kill people, but valid hunters do!;Who needs responsibilities when you have toy weapons?;Make your next murder FUN!"
	vend_reply = "Come back for more!"
	circuit = /obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	products = list(
		/obj/item/gun/ballistic/automatic/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/pistol/toy = 10,
		/obj/item/gun/ballistic/shotgun/toy/unrestricted = 10,
		/obj/item/toy/sword = 10,
		/obj/item/ammo_box/foambox = 20,
		/obj/item/toy/foamblade = 10,
		/obj/item/toy/balloon/syndicate = 10,
		/obj/item/clothing/suit/syndicatefake = 5,
		/obj/item/clothing/head/syndicatefake = 5, //OPS IN DORMS oh wait it's just an assistant
	)
	contraband = list(
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 10,   //Congrats, you unlocked the +18 setting!
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot = 10,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot = 10,
		/obj/item/ammo_box/foambox/riot = 20,
		/obj/item/toy/katana = 10,
		/obj/item/dualsaber/toy = 5,
		/obj/item/toy/cards/deck/syndicate = 10, //Gambling and it hurts, making it a +18 item
	)
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = PAYCHECK_COMMAND
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV
	light_mask = "donksoft-light-mask"
