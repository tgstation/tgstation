/datum/supply_pack/imports/servicepistol
	name = "Service pistol crate"
	desc = "!&@#Some classic pistols for the classic spaceman.!%!$#"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/gun/ballistic/revolver/nagant = 2,
					/obj/item/ammo_box/n762 = 2)
	crate_name = "Emergency Crate"

/datum/supply_pack/imports/pistolmags
	name = "Service pistol ammo"
	desc = "%$!#More ammo for your beloved antique.%!#@"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/ammo_box/n762 = 6)
	crate_name = "Emergency Crate"

/datum/supply_pack/imports/wt550
	name = "WT-550 Autorifle Crate"
	desc = "A proper ballistic option for a proper ballistic officer."
	cost = CARGO_CRATE_VALUE * 30
	contains = list(
		/obj/item/gun/ballistic/automatic/wt550 = 2,
		/obj/item/ammo_box/magazine/wt550m9 = 2,
	)
	crate_name = "Autorifle Crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/wt550ammo
	name = "WT-550 Ammo Crate"
	desc = "A supply of spare and exotic ammunition for the WT-550 autorifle."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9 = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 2,
		/obj/item/ammo_box/magazine/wt550m9/wtic = 2,
	)
	crate_name = "wt-550 ammo crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon
