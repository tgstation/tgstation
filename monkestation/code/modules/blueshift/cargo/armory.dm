/datum/supply_pack/security/armory/sindano
	name = "Sindano Submachinegun Crate"
	desc = "Three entirely proprietary Sindano kits, chambered in .35 Sol Short. Each kit contains three empty magazines and a box each of incapacitator and lethal rounds."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano = 3,
	)
	crate_name = "Sindano Submachinegun Crate"

/datum/supply_pack/security/armory/renoster
	name = "Renoster Riot Shotgun Crate"
	desc = "Three Renoster 12ga riot shotguns, with matching bandoliers for each."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/obj/item/gun/ballistic/shotgun/riot/sol = 3,
		/obj/item/storage/belt/bandolier = 3,
	)
	crate_name = "Renoster Riot Shotgun Crate"

/datum/supply_pack/security/armory/kiboko
	name = "Kiboko Grenade Launcher Crate"
	desc = "Contains a single Kiboko grenade launcher for replacing the one found in the armory, alongside the equipment that comes with it."
	cost = CARGO_CRATE_VALUE * 30
	contains = list(
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/kiboko_magless = 1,
		/obj/item/ammo_box/c980grenade = 2,
		/obj/item/ammo_box/c980grenade/smoke = 1,
		/obj/item/ammo_box/c980grenade/riot = 1,
	)
	crate_name = "Kiboko Grenade Launcher Crate"

/datum/supply_pack/security/armory/short_mod_laser
	name = "Modular Laser Carbine Crate"
	desc = "Five 'Hoshi' modular laser carbines, compact energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
	)
	crate_name = "\improper Modular Laser Carbine Crate"

/datum/supply_pack/security/armory/big_mod_laser
	name = "Modular Laser Rifle Crate"
	desc = "Three 'Hyeseong' modular laser rifles, bulky energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/energy/modular_laser_rifle,
	)
	crate_name = "\improper Modular Laser Rifle Crate"
