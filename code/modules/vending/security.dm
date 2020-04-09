/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	light_mask = "sec-light-mask"
	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/restraints/handcuffs = 8,
					/obj/item/restraints/handcuffs/cable/zipties = 10,
					/obj/item/grenade/flashbang = 15, //FULPSTATION Improved Sec Starter Gear by Surrealistik MAR 2020 Increase of flashbangs to compensate for loss of flashbangs from Sec Officer belt (Estimating ~5) and Sec lockers (~6).
					/obj/item/assembly/flash/handheld = 5,
					/obj/item/reagent_containers/food/snacks/donut = 12,
					/obj/item/storage/box/evidence = 6,
					/obj/item/flashlight/seclite = 4,
					/obj/item/radio/headset/headset_sec/alt = 6, //FULPSTATION Improved Sec Starter Gear by Surrealistik MAR 2020 Compensate for loss of gear from sec-lockers (~6).
					/obj/item/clothing/glasses/hud/security/sunglasses = 6, //FULPSTATION Improved Sec Starter Gear by Surrealistik MAR 2020 Compensate for loss of gear from sec-lockers (~6).
					/obj/item/restraints/legcuffs/bola/energy = 7)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,
					  /obj/item/storage/fancy/donut_box = 2)
	premium = list(/obj/item/storage/belt/security/webbing = 5,
				   /obj/item/coin/antagtoken = 1,
				   /obj/item/clothing/head/helmet/blueshirt = 1,
				   /obj/item/clothing/suit/armor/vest/blueshirt = 1,
				   /obj/item/clothing/gloves/tackler = 5,
				   /obj/item/grenade/stingbang = 1)
	refill_canister = /obj/item/vending_refill/security
	default_price = 650
	extra_price = 700
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/security/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/security
	icon_state = "refill_sec"
