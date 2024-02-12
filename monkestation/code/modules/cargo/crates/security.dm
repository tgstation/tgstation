/datum/supply_pack/security/armory/secway
	name = "Secway Crate"
	desc = "Sail through the halls like the badass mallcop of your dreams with the finest in overweight officer transportation technology!"
	cost = CARGO_CRATE_VALUE * 10
	contraband = TRUE
	contains = list(/obj/vehicle/ridden/secway,
					/obj/item/key/security)
	crate_name = "secway crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/security/armory/combatknives
	name = "Combat Knives Crate"
	desc = "Three combat knives guaranteed to fit snugly inide any Nanotrasen standard boot. Warranty void if you stab your own ankle."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/knife/combat = 3)
	crate_name = "combat knife crate"

/datum/supply_pack/security/paco
	name = "FS HG .35 Auto \"Paco\" weapon crate"
	desc = "Did security slip and lose their handguns? in that case, this crate contains two \"Paco\" handguns with two magazines of rubber."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/paco/no_mag = 2,
		/obj/item/ammo_box/magazine/m35/rubber = 2,
		)
	crate_name = "\improper \"Paco\" handgun crate"

/datum/supply_pack/security/pacoammo
	name = "FS HG .35 Auto \"Paco\" ammo crate"
	desc = "Short on ammo? No worries, this crate contains two .35 Auto rubber magazines, two lethally loaded magazines and respective ammunition packets."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/m35 = 2,
		/obj/item/ammo_box/magazine/m35/rubber = 2,
		/obj/item/ammo_box/c35 = 1,
		/obj/item/ammo_box/c35/rubber = 1,
		)
	crate_name = ".35 Auto Ammo crate"
