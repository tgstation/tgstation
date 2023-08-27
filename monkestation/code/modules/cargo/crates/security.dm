/datum/supply_pack/security/armory/secway
	name = "Secway Crate"
	desc = "Sail through the halls like the badass mallcop of your dreams with the finest in overweight officer transportation technology!"
	cost = CARGO_CRATE_VALUE * 10
	contraband = TRUE
	contains = list(/obj/vehicle/ridden/secway,
					/obj/item/key/security)
	crate_name = "secway crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/security/armory/wt550
	name = "WT-550 Autorifle Crate"
	desc = "A proper ballistic option for a proper ballistic officer."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(
		/obj/item/gun/ballistic/automatic/wt550 = 2,
		/obj/item/ammo_box/magazine/wt550m9 = 2,
	)
	crate_name = "Autorifle Crate"

/datum/supply_pack/security/armory/wt550ammo
	name = "WT-550 Ammo Crate"
	desc = "A supply of spare and exotic ammunition for the WT-550 autorifle."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9 = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtic = 2,
	)
	crate_name = "wt-550 ammo crate"

/datum/supply_pack/security/armory/combatknives
	name = "Combat Knives Crate"
	desc = "Three combat knives guaranteed to fit snugly inide any Nanotrasen standard boot. Warranty void if you stab your own ankle."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/knife/combat = 3)
	crate_name = "combat knife crate"

/datum/supply_pack/security/paco
	name = "FS HG .35 Auto \"Taco\" weapon crate"
	desc = "Did security slip and lose their handguns? in that case, this crate contains two \"Taco\" handguns with two magazines of rubber."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/paco/no_mag = 2,
		/obj/item/ammo_box/magazine/m35/rubber = 2,
		)
	crate_name = "\improper Taco handgun crate"

/datum/supply_pack/security/pacoammo
	name = "FS HG .35 Auto \"Taco\" ammo crate"
	desc = "Short on ammo? No worries, this crate contains two .35 rubber magazines, two lethally loaded .35 magazines and respective ammo boxes."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/m35 = 2,
		/obj/item/ammo_box/magazine/m35/rubber = 2,
		/obj/item/ammo_box/c35 = 1,
		/obj/item/ammo_box/c35/rubber = 1,
		)
	crate_name = ".35 Ammo crate"
