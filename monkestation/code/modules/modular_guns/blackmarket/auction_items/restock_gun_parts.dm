/datum/market_item/ammo
	category = "Ammo"
	markets = list(/datum/market/restock/guns_galore)

/datum/market_item/ammo/m10mm_ammo_box
	name = "10mm Ammo Box"
	desc = "A 10mm Ammo Box."
	item = /obj/item/ammo_box/c10mm

	price_min = CARGO_CRATE_VALUE * 1.5
	price_max = CARGO_CRATE_VALUE * 2.75
	stock_max = 3
	availability_prob = 70

/datum/market_item/ammo/m10mm_mag
	name = "10mm Mag"
	desc = "A 10mm Mag."
	item = /obj/item/ammo_box/magazine/m10mm

	price_min = CARGO_CRATE_VALUE * 3.4
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 90

/datum/market_item/ammo/m50ae_ammo_box
	name = ".50ae Ammo Box"
	desc = "A .50ae Ammo Box."
	item = /obj/item/ammo_box/c50

	price_min = CARGO_CRATE_VALUE * 1.5
	price_max = CARGO_CRATE_VALUE * 2.75
	stock_max = 3
	availability_prob = 70

/obj/item/ammo_box/c50
	name = "ammo box (.50ae)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/a50ae
	max_ammo = 15

/datum/market_item/ammo/m50_mag
	name = ".50ae Mag"
	desc = "A .50ae Mag."
	item = /obj/item/ammo_box/magazine/m50

	price_min = CARGO_CRATE_VALUE * 3.4
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 90
