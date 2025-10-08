/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."
	icon_state = "liberationstation"
	product_slogans = "Liberation Station: Your one-stop shop for all things second amendment!;Be a patriot today, pick up a gun!;Quality weapons for cheap prices!;Better dead than red!"
	product_ads = "Float like an astronaut, sting like a bullet!;Express your second amendment today!;Guns don't kill people, but you can!;Who needs responsibilities when you have guns?"
	vend_reply = "Remember the name: Liberation Station!"
	panel_type = "panel17"
	products = list(
		/obj/item/food/burger/plain = 5, //O say can you see, by the dawn's early light
		/obj/item/food/burger/baseball = 3, //What so proudly we hailed at the twilight's last gleaming
		/obj/item/food/fries = 5, //Whose broad stripes and bright stars through the perilous fight
		/obj/item/reagent_containers/cup/glass/bottle/beer/light = 10, //O'er the ramparts we watched, were so gallantly streaming?
		/obj/item/gun/ballistic/automatic/pistol/deagle/gold = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle/camo = 2,
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 2,
		/obj/item/gun/ballistic/automatic/proto/unrestricted = 2,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 2,
		/obj/item/gun/ballistic/automatic/gyropistol = 1,
		/obj/item/gun/ballistic/shotgun = 2,
		/obj/item/gun/ballistic/automatic/ar = 2,
	)
	premium = list(
		/obj/item/ammo_box/magazine/smgm9mm = 2,
		/obj/item/ammo_box/magazine/m50 = 4,
		/obj/item/ammo_box/magazine/m45 = 2,
		/obj/item/ammo_box/magazine/m75 = 2,
		/obj/item/food/cheesyfries = 5,
		/obj/item/food/burger/baconburger = 5, //Premium burgers for the premium section
		)
	contraband = list(
		/obj/item/clothing/under/misc/patriotsuit = 3,
		/obj/item/bedsheet/patriot = 5,
		/obj/item/food/burger/superbite = 3,
	) //U S A
	armor_type = /datum/armor/vending_liberationstation
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/liberation
	default_price = PAYCHECK_COMMAND * 2.5
	extra_price = PAYCHECK_COMMAND * 2.5
	payment_department = ACCOUNT_SEC
	light_mask = "liberation-light-mask"

/datum/armor/vending_liberationstation
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50

/obj/item/vending_refill/liberation
	machine_name = "Liberation Station"
	icon_state = "refill_patriot"
