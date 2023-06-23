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
