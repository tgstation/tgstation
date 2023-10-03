/datum/armament_entry/company_import/sol_defense
	category = SOL_DEFENSE_DEFENSE_NAME
	company_bitflag = CARGO_COMPANY_SOL_DEFENSE

// Basic armor vests

/datum/armament_entry/company_import/sol_defense/armor
	subcategory = "Light Body Armor"

/datum/armament_entry/company_import/sol_defense/armor/slim_vest
	name = "type I vest - slim"
	item_type = /obj/item/clothing/suit/armor/vest
	cost = PAYCHECK_CREW * 3

/datum/armament_entry/company_import/sol_defense/armor/normal_vest
	name = "type I vest - normal"
	item_type = /obj/item/clothing/suit/armor/vest/alt
	cost = PAYCHECK_CREW * 3

/datum/armament_entry/company_import/sol_defense/case
	subcategory = "Weapon Cases"

/datum/armament_entry/company_import/sol_defense/case/trappiste
	item_type = /obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/empty
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/sol_defense/case/carwo
	item_type = /obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/empty
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/sol_defense/sidearm
	subcategory = "Sidearms"

/datum/armament_entry/company_import/sol_defense/sidearm/eland
	item_type = /obj/item/gun/ballistic/revolver/sol
	cost = PAYCHECK_COMMAND * 4

/datum/armament_entry/company_import/sol_defense/sidearm/wespe
	item_type = /obj/item/gun/ballistic/automatic/pistol/sol
	cost = PAYCHECK_COMMAND * 4

/datum/armament_entry/company_import/sol_defense/sidearm/skild
	item_type = /obj/item/gun/ballistic/automatic/pistol/trappiste
	cost = PAYCHECK_COMMAND * 6

/datum/armament_entry/company_import/sol_defense/sidearm/takbok
	item_type = /obj/item/gun/ballistic/revolver/takbok
	cost = PAYCHECK_COMMAND * 6

// Lethal anything that's not a pistol, requires high company interest

/datum/armament_entry/company_import/sol_defense/longarm
	subcategory = "Longarms"
	restricted = TRUE

/datum/armament_entry/company_import/sol_defense/longarm/renoster
	item_type = /obj/item/gun/ballistic/shotgun/riot/sol
	cost = PAYCHECK_COMMAND * 6

/datum/armament_entry/company_import/sol_defense/longarm/sindano
	item_type = /obj/item/gun/ballistic/automatic/sol_smg
	cost = PAYCHECK_COMMAND * 6

/datum/armament_entry/company_import/sol_defense/longarm/elite
	item_type = /obj/item/gun/ballistic/automatic/sol_rifle/marksman
	cost = PAYCHECK_COMMAND * 12

/datum/armament_entry/company_import/sol_defense/longarm/infanterie
	item_type = /obj/item/gun/ballistic/automatic/sol_rifle
	cost = PAYCHECK_COMMAND * 14
	contraband = TRUE

/datum/armament_entry/company_import/sol_defense/longarm/outomaties
	item_type = /obj/item/gun/ballistic/automatic/sol_rifle/machinegun
	cost = PAYCHECK_COMMAND * 23
	contraband = TRUE

/datum/armament_entry/company_import/sol_defense/longarm/kiboko
	item_type = /obj/item/gun/ballistic/automatic/sol_grenade_launcher
	cost = PAYCHECK_COMMAND * 46
	contraband = TRUE

/datum/armament_entry/company_import/sol_defense/magazines
	subcategory = "Magazines"
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/sol_defense/magazines/c35_mag
	item_type = /obj/item/ammo_box/magazine/c35sol_pistol/starts_empty

/datum/armament_entry/company_import/sol_defense/magazines/c35_extended
	item_type = /obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty

/datum/armament_entry/company_import/sol_defense/magazines/c585_mag
	item_type = /obj/item/ammo_box/magazine/c585trappiste_pistol/spawns_empty

/datum/armament_entry/company_import/sol_defense/magazines/sol_rifle_short
	item_type = /obj/item/ammo_box/magazine/c40sol_rifle/starts_empty

/datum/armament_entry/company_import/sol_defense/magazines/sol_rifle_standard
	item_type = /obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/sol_defense/magazines/sol_rifle_drum
	item_type = /obj/item/ammo_box/magazine/c40sol_rifle/drum/starts_empty
	cost = PAYCHECK_COMMAND * 3
	contraband = TRUE

/datum/armament_entry/company_import/sol_defense/magazines/sol_grenade_standard
	item_type = /obj/item/ammo_box/magazine/c980_grenade/starts_empty
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/sol_defense/magazines/sol_grenade_drum
	item_type = /obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	cost = PAYCHECK_CREW * 3
	contraband = TRUE
